<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeliveryChallan;
use App\Models\Requisition;
use App\Services\ChallanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class DeliveryChallanController extends Controller
{
    protected ChallanService $challanService;

    public function __construct(ChallanService $challanService)
    {
        $this->challanService = $challanService;
    }

    /**
     * Display a listing of delivery challans.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = DeliveryChallan::with(['requisition.user', 'requisition.brickType']);

            // Apply delivery status filter if provided
            if ($request->has('delivery_status')) {
                $query->withDeliveryStatus($request->delivery_status);
            }

            // Apply date filter if provided
            if ($request->has('date')) {
                $query->whereDate('date', $request->date);
            }

            $challans = $query->orderBy('created_at', 'desc')->paginate(15);

            return response()->json([
                'status' => 'success',
                'message' => 'Delivery challans retrieved successfully',
                'data' => $challans
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve delivery challans',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Store a newly created delivery challan from a requisition.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            // Validate input
            $validatedData = $request->validate([
                'requisition_id' => 'required|exists:requisitions,id',
                'vehicle_number' => 'required|string|max:255',
                'driver_name' => 'nullable|string|max:255',
                'vehicle_type' => 'nullable|string|max:255',
                'location' => 'required|string|max:255',
                'remarks' => 'nullable|string',
            ]);

            // Get the requisition
            $requisition = Requisition::findOrFail($validatedData['requisition_id']);

            // Create challan using service
            $challan = $this->challanService->createChallanFromRequisition($validatedData, $requisition);

            return response()->json([
                'status' => 'success',
                'message' => 'Delivery challan created successfully',
                'data' => $challan->load(['requisition.user', 'requisition.brickType'])
            ], 201);

        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to create delivery challan',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Display the specified delivery challan.
     */
    public function show(string $id): JsonResponse
    {
        try {
            $challan = DeliveryChallan::with(['requisition.user', 'requisition.brickType'])
                ->findOrFail($id);

            return response()->json([
                'status' => 'success',
                'message' => 'Delivery challan retrieved successfully',
                'data' => $challan
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Delivery challan not found',
                'errors' => ['general' => [$e->getMessage()]]
            ], 404);
        }
    }

    /**
     * Update the delivery status of the specified challan.
     */
    public function updateStatus(Request $request, string $id): JsonResponse
    {
        try {
            // Validate input
            $validatedData = $request->validate([
                'delivery_status' => 'required|in:' . implode(',', DeliveryChallan::getDeliveryStatusValues()),
                'remarks' => 'nullable|string',
            ]);

            $challan = DeliveryChallan::findOrFail($id);

            // Update delivery status using service
            $success = $this->challanService->updateDeliveryStatus($challan, $validatedData['delivery_status']);

            if (!$success) {
                return response()->json([
                    'status' => 'fail',
                    'message' => 'Failed to update delivery status',
                    'errors' => ['delivery_status' => ['Invalid status transition']]
                ], 422);
            }

            // Update remarks if provided
            if (isset($validatedData['remarks'])) {
                $challan->remarks = $validatedData['remarks'];
                $challan->save();
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Delivery status updated successfully',
                'data' => $challan->load(['requisition.user', 'requisition.brickType'])
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to update delivery status',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get pending orders queue for Logistics users.
     */
    public function pendingOrders(): JsonResponse
    {
        try {
            $pendingOrders = $this->challanService->getPendingOrdersQueue();

            return response()->json([
                'status' => 'success',
                'message' => 'Pending orders retrieved successfully',
                'data' => $pendingOrders
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve pending orders',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Generate printable challan document.
     */
    public function print(string $id): JsonResponse
    {
        try {
            $challan = DeliveryChallan::with(['requisition.user', 'requisition.brickType'])
                ->findOrFail($id);

            // Generate printable document data
            $printableData = $this->challanService->generatePrintableDocument($challan);

            // Mark as printed and increment count
            $this->challanService->markAsPrinted($challan);

            return response()->json([
                'status' => 'success',
                'message' => 'Printable challan generated successfully',
                'data' => $printableData
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to generate printable challan',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Update method for general challan updates (vehicle info, etc.).
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            // Validate input
            $validatedData = $request->validate([
                'vehicle_number' => 'sometimes|required|string|max:255',
                'driver_name' => 'sometimes|nullable|string|max:255',
                'vehicle_type' => 'sometimes|nullable|string|max:255',
                'location' => 'sometimes|required|string|max:255',
                'remarks' => 'nullable|string',
            ]);

            $challan = DeliveryChallan::findOrFail($id);

            // Only allow updates if challan is not delivered
            if ($challan->isDelivered()) {
                return response()->json([
                    'status' => 'fail',
                    'message' => 'Cannot update delivered challan',
                    'errors' => ['general' => ['Delivered challans cannot be modified']]
                ], 403);
            }

            $challan->update($validatedData);

            return response()->json([
                'status' => 'success',
                'message' => 'Delivery challan updated successfully',
                'data' => $challan->load(['requisition.user', 'requisition.brickType'])
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to update delivery challan',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Delivery challans cannot be deleted as they are part of audit trail.
     */
    public function destroy(string $id): JsonResponse
    {
        return response()->json([
            'status' => 'fail',
            'message' => 'Delivery challans cannot be deleted',
            'errors' => ['general' => ['Delivery challans are part of audit trail and cannot be deleted']]
        ], 403);
    }
}
