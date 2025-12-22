<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\DeliveryChallan;
use App\Services\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class PaymentController extends Controller
{
    protected PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
        
        // Apply role-based middleware - only Accounts users can access payments
        $this->middleware(['auth:sanctum', 'role:Accounts']);
    }

    /**
     * Display payment tracking dashboard with delivered challans
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Payment::with(['deliveryChallan.requisition.brickType', 'approvedBy'])
                ->orderBy('created_at', 'desc');

            // Filter by payment status if provided
            if ($request->has('status')) {
                $query->where('payment_status', $request->status);
            }

            // Filter by date range if provided
            if ($request->has('from_date')) {
                $query->whereDate('payment_date', '>=', $request->from_date);
            }
            if ($request->has('to_date')) {
                $query->whereDate('payment_date', '<=', $request->to_date);
            }

            $payments = $query->paginate(15);

            return response()->json([
                'status' => 'success',
                'message' => 'Payment dashboard data retrieved successfully',
                'data' => [
                    'payments' => $payments->items(),
                    'pagination' => [
                        'current_page' => $payments->currentPage(),
                        'last_page' => $payments->lastPage(),
                        'per_page' => $payments->perPage(),
                        'total' => $payments->total(),
                    ],
                    'summary' => $this->paymentService->getPaymentSummary(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve payment dashboard data',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get pending challans that need payment processing
     */
    public function getPendingChallans(): JsonResponse
    {
        try {
            \Log::info('getDeliveredChallans called by user: ' . auth()->id());
            
            // Get challans with pending delivery status that need payment processing
            $pendingChallans = DeliveryChallan::with(['requisition.brickType', 'requisition.user'])
                ->where('delivery_status', DeliveryChallan::STATUS_PENDING)
                ->whereDoesntHave('payment')
                ->orderBy('date', 'desc')
                ->get();

            \Log::info('Found pending challans count: ' . $pendingChallans->count());

            return response()->json([
                'status' => 'success',
                'message' => 'Pending challans retrieved successfully',
                'data' => [
                    'challans' => $pendingChallans
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Error in getDeliveredChallans: ' . $e->getMessage());
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve pending challans',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get all challans with filtering and pagination
     */
    public function getAllChallans(Request $request): JsonResponse
    {
        try {
            $query = DeliveryChallan::with(['requisition.brickType', 'requisition.user', 'payment']);

            // Filter by status
            $status = $request->get('status', 'all');
            if ($status === 'pending') {
                $query->where('delivery_status', '!=', DeliveryChallan::STATUS_DELIVERED)
                      ->orWhere(function($q) {
                          $q->where('delivery_status', DeliveryChallan::STATUS_DELIVERED)
                            ->whereDoesntHave('payment');
                      });
            } elseif ($status === 'completed') {
                $query->where('delivery_status', DeliveryChallan::STATUS_DELIVERED)
                      ->whereHas('payment');
            }

            // Filter by date range
            if ($request->has('start_date')) {
                $query->whereDate('date', '>=', $request->start_date);
            }
            if ($request->has('end_date')) {
                $query->whereDate('date', '<=', $request->end_date);
            }

            // Default to today's challans if no date filter
            if (!$request->has('start_date') && !$request->has('end_date')) {
                $query->whereDate('date', today());
            }

            // Order by date descending
            $query->orderBy('date', 'desc')->orderBy('created_at', 'desc');

            // Paginate results
            $perPage = min($request->get('per_page', 10), 50); // Max 50 items per page
            $challans = $query->paginate($perPage);

            return response()->json([
                'status' => 'success',
                'message' => 'Challans retrieved successfully',
                'data' => [
                    'challans' => $challans->items(),
                    'current_page' => $challans->currentPage(),
                    'last_page' => $challans->lastPage(),
                    'per_page' => $challans->perPage(),
                    'total' => $challans->total(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve challans',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Create payment record for a delivered challan
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'delivery_challan_id' => 'required|exists:delivery_challans,id',
            'total_amount' => 'required|numeric|min:0',
            'amount_received' => 'nullable|numeric|min:0',
            'payment_date' => 'nullable|date',
            'payment_method' => ['nullable', Rule::in(Payment::getPaymentMethods())],
            'reference_number' => 'nullable|string|max:255',
            'remarks' => 'nullable|string|max:1000',
        ]);

        try {
            $payment = $this->paymentService->createPayment($request->all());

            return response()->json([
                'status' => 'success',
                'message' => 'Payment record created successfully',
                'data' => [
                    'payment' => $payment->load(['deliveryChallan.requisition', 'approvedBy'])
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to create payment record',
                'errors' => ['general' => [$e->getMessage()]]
            ], 400);
        }
    }

    /**
     * Display payment details and history
     */
    public function show(Payment $payment): JsonResponse
    {
        try {
            $payment->load(['deliveryChallan.requisition.brickType', 'deliveryChallan.requisition.user', 'approvedBy']);

            return response()->json([
                'status' => 'success',
                'message' => 'Payment details retrieved successfully',
                'data' => [
                    'payment' => $payment,
                    'history' => $this->paymentService->getPaymentHistory($payment->id)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve payment details',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Update payment status and amounts with validation
     */
    public function update(Request $request, Payment $payment): JsonResponse
    {
        $request->validate([
            'payment_status' => ['nullable', Rule::in(Payment::getPaymentStatuses())],
            'amount_received' => 'nullable|numeric|min:0',
            'payment_date' => 'nullable|date',
            'payment_method' => ['nullable', Rule::in(Payment::getPaymentMethods())],
            'reference_number' => 'nullable|string|max:255',
            'remarks' => 'nullable|string|max:1000',
        ]);

        try {
            $updatedPayment = $this->paymentService->updatePayment($payment, $request->all());

            return response()->json([
                'status' => 'success',
                'message' => 'Payment updated successfully',
                'data' => [
                    'payment' => $updatedPayment->load(['deliveryChallan.requisition', 'approvedBy'])
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to update payment',
                'errors' => ['general' => [$e->getMessage()]]
            ], 400);
        }
    }

    /**
     * Approve payment (locks the record)
     */
    public function approve(Payment $payment): JsonResponse
    {
        try {
            $approvedPayment = $this->paymentService->approvePayment($payment, auth()->id());

            return response()->json([
                'status' => 'success',
                'message' => 'Payment approved successfully',
                'data' => [
                    'payment' => $approvedPayment->load(['deliveryChallan.requisition', 'approvedBy'])
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to approve payment',
                'errors' => ['general' => [$e->getMessage()]]
            ], 400);
        }
    }

    /**
     * Get payment reports
     */
    public function reports(Request $request): JsonResponse
    {
        $request->validate([
            'type' => 'required|in:daily,range',
            'date' => 'required_if:type,daily|date',
            'from_date' => 'required_if:type,range|date',
            'to_date' => 'required_if:type,range|date|after_or_equal:from_date',
        ]);

        try {
            if ($request->type === 'daily') {
                $report = $this->paymentService->generateDailyReport($request->date);
            } else {
                $report = $this->paymentService->generateRangeReport($request->from_date, $request->to_date);
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Payment report generated successfully',
                'data' => [
                    'report' => $report
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to generate payment report',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }
}
