<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Requisition;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class OrderHistoryController extends Controller
{
    /**
     * Get order history with filtering and pagination
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Requisition::with([
                'user:id,name,email',
                'user.role:id,name',
                'user.department:id,name',
                'brickType:id,name,current_price,unit',
                'deliveryChallan:id,requisition_id,challan_number,delivery_status,delivery_date,driver_name,vehicle_number',
                'deliveryChallan.payment:id,delivery_challan_id,payment_status,total_amount,amount_received,payment_date,payment_method,approved_by,approved_at',
                'deliveryChallan.payment.approvedBy:id,name'
            ]);

            // Apply filters
            if ($request->filled('payment_status')) {
                $query->whereHas('deliveryChallan.payment', function ($q) use ($request) {
                    $q->where('payment_status', $request->payment_status);
                });
            }

            if ($request->filled('order_status')) {
                $query->where('status', $request->order_status);
            }

            if ($request->filled('from_date') && $request->filled('to_date')) {
                $query->whereBetween('created_at', [
                    Carbon::parse($request->from_date)->startOfDay(),
                    Carbon::parse($request->to_date)->endOfDay()
                ]);
            }

            if ($request->filled('search')) {
                $search = $request->search;
                $query->where(function ($q) use ($search) {
                    $q->where('order_number', 'like', "%{$search}%")
                      ->orWhere('customer_name', 'like', "%{$search}%")
                      ->orWhere('customer_phone', 'like', "%{$search}%")
                      ->orWhereHas('user', function ($userQuery) use ($search) {
                          $userQuery->where('name', 'like', "%{$search}%");
                      });
                });
            }

            // Order by latest first
            $query->orderBy('created_at', 'desc');

            // Paginate results
            $perPage = $request->get('per_page', 20);
            $orders = $query->paginate($perPage);

            // Transform data for frontend
            $transformedOrders = $orders->getCollection()->map(function ($order) {
                return $this->transformOrderData($order);
            });

            return response()->json([
                'status' => 'success',
                'message' => 'Order history retrieved successfully',
                'data' => [
                    'orders' => $transformedOrders,
                    'pagination' => [
                        'current_page' => $orders->currentPage(),
                        'last_page' => $orders->lastPage(),
                        'per_page' => $orders->perPage(),
                        'total' => $orders->total(),
                        'from' => $orders->firstItem(),
                        'to' => $orders->lastItem(),
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Order History Index Error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve order history',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get detailed order information
     */
    public function show(int $id): JsonResponse
    {
        try {
            $order = Requisition::with([
                'user:id,name,email',
                'user.role:id,name',
                'user.department:id,name',
                'brickType:id,name,description,current_price,unit,category',
                'deliveryChallan:id,requisition_id,challan_number,delivery_status,delivery_date,driver_name,vehicle_number,vehicle_type,remarks',
                'deliveryChallan.payment:id,delivery_challan_id,payment_status,total_amount,amount_received,payment_date,payment_method,reference_number,remarks,approved_by,approved_at',
                'deliveryChallan.payment.approvedBy:id,name,email'
            ])->findOrFail($id);

            return response()->json([
                'status' => 'success',
                'message' => 'Order details retrieved successfully',
                'data' => [
                    'order' => $this->transformDetailedOrderData($order)
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve order details',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get order statistics for dashboard
     */
    public function statistics(Request $request): JsonResponse
    {
        try {
            $fromDate = $request->get('from_date', Carbon::now()->startOfMonth()->format('Y-m-d H:i:s'));
            $toDate = $request->get('to_date', Carbon::now()->endOfMonth()->format('Y-m-d H:i:s'));

            // Use Eloquent instead of raw SQL for better error handling
            $totalOrders = Requisition::whereBetween('created_at', [$fromDate, $toDate])->count();
            $totalValue = Requisition::whereBetween('created_at', [$fromDate, $toDate])->sum('total_amount') ?? 0;

            // Get payment statistics
            $paymentStats = Payment::whereHas('deliveryChallan.requisition', function ($query) use ($fromDate, $toDate) {
                $query->whereBetween('created_at', [$fromDate, $toDate]);
            })->selectRaw('
                COUNT(CASE WHEN payment_status = "pending" THEN 1 END) as pending_payments,
                COUNT(CASE WHEN payment_status = "partial" THEN 1 END) as partial_payments,
                COUNT(CASE WHEN payment_status = "paid" THEN 1 END) as paid_orders,
                COUNT(CASE WHEN payment_status = "approved" THEN 1 END) as approved_orders,
                SUM(CASE WHEN payment_status IN ("pending", "partial") THEN (total_amount - amount_received) ELSE 0 END) as outstanding_amount,
                SUM(amount_received) as total_received
            ')->first();

            $statistics = [
                'total_orders' => $totalOrders,
                'total_value' => (string) $totalValue,
                'pending_payments' => $paymentStats->pending_payments ?? 0,
                'partial_payments' => $paymentStats->partial_payments ?? 0,
                'paid_orders' => $paymentStats->paid_orders ?? 0,
                'approved_orders' => $paymentStats->approved_orders ?? 0,
                'outstanding_amount' => (string) ($paymentStats->outstanding_amount ?? 0),
                'total_received' => (string) ($paymentStats->total_received ?? 0),
            ];

            return response()->json([
                'status' => 'success',
                'message' => 'Order statistics retrieved successfully',
                'data' => [
                    'statistics' => $statistics,
                    'date_range' => [
                        'from' => $fromDate,
                        'to' => $toDate
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            \Log::error('Order History Statistics Error: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
                'request' => $request->all()
            ]);
            
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve statistics',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Export orders to Excel
     */
    public function exportExcel(Request $request): JsonResponse
    {
        try {
            // This would typically generate and return a downloadable Excel file
            // For now, return the data that would be exported
            
            $query = Requisition::with([
                'user:id,name,email',
                'user.role:id,name',
                'brickType:id,name,current_price,unit',
                'deliveryChallan:id,requisition_id,challan_number,delivery_status,delivery_date',
                'deliveryChallan.payment:id,delivery_challan_id,payment_status,total_amount,amount_received,payment_date'
            ]);

            // Apply same filters as index method
            if ($request->filled('payment_status')) {
                $query->whereHas('deliveryChallan.payment', function ($q) use ($request) {
                    $q->where('payment_status', $request->payment_status);
                });
            }

            if ($request->filled('from_date') && $request->filled('to_date')) {
                $query->whereBetween('created_at', [
                    Carbon::parse($request->from_date)->startOfDay(),
                    Carbon::parse($request->to_date)->endOfDay()
                ]);
            }

            $orders = $query->orderBy('created_at', 'desc')->get();

            $exportData = $orders->map(function ($order) {
                return [
                    'Order Number' => $order->order_number,
                    'Customer Name' => $order->customer_name,
                    'Customer Phone' => $order->customer_phone,
                    'Sales Executive' => $order->user->name ?? 'N/A',
                    'Brick Type' => $order->brickType->name ?? 'N/A',
                    'Quantity' => $order->quantity,
                    'Total Amount' => $order->total_amount,
                    'Order Date' => $order->created_at->format('Y-m-d'),
                    'Delivery Status' => $order->deliveryChallan->delivery_status ?? 'Not Assigned',
                    'Payment Status' => $order->deliveryChallan->payment->payment_status ?? 'No Payment',
                    'Amount Received' => $order->deliveryChallan->payment->amount_received ?? 0,
                    'Outstanding' => ($order->deliveryChallan->payment->total_amount ?? $order->total_amount) - ($order->deliveryChallan->payment->amount_received ?? 0),
                ];
            });

            return response()->json([
                'status' => 'success',
                'message' => 'Export data prepared successfully',
                'data' => [
                    'export_data' => $exportData,
                    'filename' => 'orders_export_' . Carbon::now()->format('Y_m_d_H_i_s') . '.xlsx'
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to prepare export data',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Generate PDF for order details
     */
    public function generatePdf(int $id): JsonResponse
    {
        try {
            $order = Requisition::with([
                'user:id,name,email',
                'user.role:id,name',
                'user.department:id,name',
                'brickType:id,name,description,current_price,unit',
                'deliveryChallan',
                'deliveryChallan.payment'
            ])->findOrFail($id);

            // This would typically generate a PDF and return download URL
            // For now, return the data that would be in the PDF
            
            return response()->json([
                'status' => 'success',
                'message' => 'PDF data prepared successfully',
                'data' => [
                    'pdf_data' => $this->transformDetailedOrderData($order),
                    'filename' => 'order_' . $order->order_number . '.pdf'
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to generate PDF',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Transform order data for list view
     */
    private function transformOrderData($order): array
    {
        $payment = $order->deliveryChallan->payment ?? null;
        
        return [
            'id' => $order->id,
            'order_number' => $order->order_number,
            'customer_name' => $order->customer_name,
            'customer_phone' => $order->customer_phone,
            'brick_type' => $order->brickType->name ?? 'N/A',
            'quantity' => (string) $order->quantity,
            'total_amount' => (string) $order->total_amount,
            'order_date' => $order->created_at->format('Y-m-d H:i'),
            'order_status' => $order->status,
            'delivery_status' => $order->deliveryChallan->delivery_status ?? 'not_assigned',
            'payment_status' => $payment->payment_status ?? 'no_payment',
            'amount_received' => (string) ($payment->amount_received ?? 0),
            'outstanding_amount' => (string) (($payment->total_amount ?? $order->total_amount) - ($payment->amount_received ?? 0)),
            'sales_executive' => $order->user->name ?? 'N/A',
        ];
    }

    /**
     * Transform detailed order data
     */
    private function transformDetailedOrderData($order): array
    {
        $challan = $order->deliveryChallan;
        $payment = $challan->payment ?? null;
        
        return [
            'id' => $order->id,
            'order_number' => $order->order_number,
            'order_date' => $order->created_at->format('Y-m-d H:i:s'),
            'status' => $order->status,
            
            // Customer Details
            'customer' => [
                'name' => $order->customer_name,
                'phone' => $order->customer_phone,
                'address' => $order->customer_address ?? $order->delivery_address ?? '',
            ],
            
            // Order Details
            'order_details' => [
                'brick_type' => [
                    'name' => $order->brickType->name ?? 'N/A',
                    'description' => $order->brickType->description ?? '',
                    'unit' => $order->brickType->unit ?? '',
                    'category' => $order->brickType->category ?? '',
                ],
                'quantity' => (string) $order->quantity,
                'price_per_unit' => (string) $order->price_per_unit,
                'total_amount' => (string) $order->total_amount,
                'special_instructions' => $order->special_instructions ?? '',
            ],
            
            // Sales Details
            'sales_details' => [
                'executive_name' => $order->user->name ?? 'N/A',
                'executive_email' => $order->user->email ?? 'N/A',
                'executive_phone' => 'N/A', // Phone not available in users table
                'department' => $order->user->department->name ?? 'N/A',
                'role' => $order->user->role->name ?? 'N/A',
            ],
            
            // Logistics Details (if available)
            'logistics_details' => $challan ? [
                'challan_number' => $challan->challan_number,
                'delivery_status' => $challan->delivery_status,
                'delivery_date' => $challan->delivery_date,
                'delivery_time' => null, // Field doesn't exist in table
                'driver_name' => $challan->driver_name,
                'vehicle_number' => $challan->vehicle_number,
                'vehicle_type' => $challan->vehicle_type,
                'remarks' => $challan->remarks,
            ] : null,
            
            // Payment Details (if available)
            'payment_details' => $payment ? [
                'payment_status' => $payment->payment_status,
                'total_amount' => (string) $payment->total_amount,
                'amount_received' => (string) $payment->amount_received,
                'remaining_amount' => (string) ($payment->total_amount - $payment->amount_received),
                'payment_date' => $payment->payment_date,
                'payment_method' => $payment->payment_method,
                'reference_number' => $payment->reference_number,
                'remarks' => $payment->remarks,
            ] : null,
            
            // Account Details (if approved)
            'account_details' => ($payment && $payment->payment_status === 'approved') ? [
                'approved_by' => $payment->approvedBy->name ?? 'N/A',
                'approved_by_email' => $payment->approvedBy->email ?? 'N/A',
                'approved_at' => $payment->approved_at?->format('Y-m-d H:i:s'),
            ] : null,
        ];
    }
}