<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CreateBrickTypeRequest;
use App\Http\Requests\UpdateBrickTypeRequest;
use App\Models\BrickType;
use App\Services\BrickTypeService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class BrickTypeController extends Controller
{
    protected BrickTypeService $brickTypeService;

    public function __construct(BrickTypeService $brickTypeService)
    {
        $this->brickTypeService = $brickTypeService;
    }

    /**
     * Display a listing of brick types.
     * For admin: shows all brick types
     * For sales executives: shows only active brick types
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        
        // If user is Sales Executive, only show active brick types
        if ($user->role->name === 'Sales Executive') {
            $brickTypes = BrickType::active()->orderBy('id')->get();
        } else {
            // Admin can see all brick types
            $brickTypes = BrickType::orderBy('id')->get();
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Brick types retrieved successfully',
            'data' => [
                'brick_types' => $brickTypes
            ]
        ]);
    }

    /**
     * Store a newly created brick type.
     */
    public function store(CreateBrickTypeRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $brickType = $this->brickTypeService->createBrickType($validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Brick type created successfully',
            'data' => [
                'brick_type' => $brickType
            ]
        ], 201);
    }

    /**
     * Display the specified brick type.
     */
    public function show(BrickType $brickType): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'message' => 'Brick type retrieved successfully',
            'data' => [
                'brick_type' => $brickType
            ]
        ]);
    }

    /**
     * Update the specified brick type.
     */
    public function update(UpdateBrickTypeRequest $request, BrickType $brickType): JsonResponse
    {
        $validated = $request->validated();

        $updatedBrickType = $this->brickTypeService->updateBrickType($brickType, $validated);

        return response()->json([
            'status' => 'success',
            'message' => 'Brick type updated successfully',
            'data' => [
                'brick_type' => $updatedBrickType
            ]
        ]);
    }

    /**
     * Remove the specified brick type (soft delete by setting status to inactive).
     */
    public function destroy(BrickType $brickType): JsonResponse
    {
        $this->brickTypeService->deactivateBrickType($brickType);

        return response()->json([
            'status' => 'success',
            'message' => 'Brick type deactivated successfully'
        ]);
    }

    /**
     * Update the status of a brick type (activate/deactivate).
     */
    public function updateStatus(Request $request, BrickType $brickType): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|in:active,inactive'
        ]);

        $updatedBrickType = $this->brickTypeService->updateStatus($brickType, $validated['status']);

        return response()->json([
            'status' => 'success',
            'message' => 'Brick type status updated successfully',
            'data' => [
                'brick_type' => $updatedBrickType
            ]
        ]);
    }

    /**
     * Get active brick types for selection lists (used by Sales Executives).
     */
    public function active(): JsonResponse
    {
        $activeBrickTypes = BrickType::active()->orderBy('id')->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Active brick types retrieved successfully',
            'data' => [
                'brick_types' => $activeBrickTypes
            ]
        ]);
    }
}