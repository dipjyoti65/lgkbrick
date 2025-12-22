<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BrickType;
use App\Models\Requisition;
use App\Services\RequisitionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class RequisitionController extends Controller
{
    protected RequisitionService $requisitionService;

    public function __construct(RequisitionService $requisitionService)
    {
        $this->requisitionService = $requisitionService;
    }

    /**
     * Display a listing of requisitions with user-based filtering.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            $query = Requisition::with(['user', 'brickType']);

            // Filter by user role - Sales Executives see only their own requisitions
            if ($user->role->name === 'Sales Executive') {
                $query->byUser($user->id);
            }

            // Apply status filter if provided
            if ($request->has('status')) {
                $query->withStatus($request->status);
            }

            // Apply date filter if provided
            if ($request->has('date')) {
                $query->whereDate('date', $request->date);
            }

            $requisitions = $query->orderBy('created_at', 'desc')->paginate(15);

            return response()->json([
                'status' => 'success',
                'message' => 'Requisitions retrieved successfully',
                'data' => $requisitions
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve requisitions',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Store a newly created requisition with frontend total validation.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            // Validate input - allow string inputs that can be converted to numbers
            $validatedData = $request->validate([
                'brick_type_id' => 'required|integer|exists:brick_types,id',
                'quantity' => 'required|string',
                'price_per_unit' => 'required|string',
                'entered_price' => 'required|string',
                'total_amount' => 'required|string',
                'customer_name' => 'required|string|max:255',
                'customer_phone' => 'required|string|max:20',
                'customer_address' => 'required|string',
                'customer_location' => 'required|string|max:255',
            ]);

            // Convert string values to numeric and validate ranges
            $validatedData['quantity'] = (float) $validatedData['quantity'];
            $validatedData['price_per_unit'] = (float) $validatedData['price_per_unit'];
            $validatedData['entered_price'] = (float) $validatedData['entered_price'];
            $validatedData['total_amount'] = (float) $validatedData['total_amount'];

            // Validate numeric ranges after conversion
            if ($validatedData['quantity'] <= 0) {
                throw ValidationException::withMessages(['quantity' => ['Quantity must be greater than zero']]);
            }
            if ($validatedData['price_per_unit'] < 0) {
                throw ValidationException::withMessages(['price_per_unit' => ['Price per unit cannot be negative']]);
            }
            if ($validatedData['entered_price'] <= 0) {
                throw ValidationException::withMessages(['entered_price' => ['Entered price must be greater than zero']]);
            }
            if ($validatedData['total_amount'] <= 0) {
                throw ValidationException::withMessages(['total_amount' => ['Total amount must be greater than zero']]);
            }

            // Create requisition using service
            $requisition = $this->requisitionService->createRequisition($validatedData, Auth::user());

            return response()->json([
                'status' => 'success',
                'message' => 'Requisition created successfully',
                'data' => $requisition->load(['user', 'brickType'])
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
                'message' => 'Failed to create requisition',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Display the specified requisition.
     */
    public function show(string $id): JsonResponse
    {
        try {
            $user = Auth::user();
            $query = Requisition::with(['user', 'brickType']);

            // Filter by user role - Sales Executives can only see their own requisitions
            if ($user->role->name === 'Sales Executive') {
                $query->byUser($user->id);
            }

            $requisition = $query->findOrFail($id);

            return response()->json([
                'status' => 'success',
                'message' => 'Requisition retrieved successfully',
                'data' => $requisition
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Requisition not found',
                'errors' => ['general' => [$e->getMessage()]]
            ], 404);
        }
    }

    /**
     * Get pending requisitions for Logistics users.
     */
    public function pending(): JsonResponse
    {
        try {
            $pendingRequisitions = Requisition::with(['user', 'brickType'])
                ->pending()
                ->orderBy('created_at', 'asc')
                ->get();

            return response()->json([
                'status' => 'success',
                'message' => 'Pending requisitions retrieved successfully',
                'data' => $pendingRequisitions
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to retrieve pending requisitions',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Get current brick price for frontend validation.
     */
    public function getBrickPrice(string $brickTypeId): JsonResponse
    {
        try {
            $brickType = BrickType::active()->findOrFail($brickTypeId);

            return response()->json([
                'status' => 'success',
                'message' => 'Brick price retrieved successfully',
                'data' => [
                    'brick_type_id' => $brickType->id,
                    'name' => $brickType->name,
                    'current_price' => $brickType->current_price,
                    'unit' => $brickType->unit
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Brick type not found or inactive',
                'errors' => ['general' => [$e->getMessage()]]
            ], 404);
        }
    }

    /**
     * Update and destroy methods are not implemented as requisitions are immutable after submission.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        return response()->json([
            'status' => 'fail',
            'message' => 'Requisitions cannot be modified after submission',
            'errors' => ['general' => ['Requisitions are immutable once submitted']]
        ], 403);
    }

    public function destroy(string $id): JsonResponse
    {
        return response()->json([
            'status' => 'fail',
            'message' => 'Requisitions cannot be deleted after submission',
            'errors' => ['general' => ['Requisitions are immutable once submitted']]
        ], 403);
    }
}
