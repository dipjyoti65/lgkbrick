<?php

namespace App\Services;

use App\Models\BrickType;
use Illuminate\Database\Eloquent\Collection;

class BrickTypeService
{
    /**
     * Create a new brick type.
     */
    public function createBrickType(array $data): BrickType
    {
        // Set default status to active if not provided
        $data['status'] = $data['status'] ?? 'active';

        return BrickType::create($data);
    }

    /**
     * Update an existing brick type.
     * Handles price changes that should only apply to future requisitions.
     */
    public function updateBrickType(BrickType $brickType, array $data): BrickType
    {
        // Check if price is being updated
        if (isset($data['current_price']) && $data['current_price'] != $brickType->current_price) {
            // Log price change for audit purposes
            \Log::info('Brick type price updated', [
                'brick_type_id' => $brickType->id,
                'old_price' => $brickType->current_price,
                'new_price' => $data['current_price'],
                'updated_by' => auth()->id()
            ]);
        }

        $brickType->update($data);
        return $brickType->fresh();
    }

    /**
     * Update the status of a brick type.
     */
    public function updateStatus(BrickType $brickType, string $status): BrickType
    {
        $brickType->update(['status' => $status]);
        
        // Log status change for audit purposes
        \Log::info('Brick type status updated', [
            'brick_type_id' => $brickType->id,
            'new_status' => $status,
            'updated_by' => auth()->id()
        ]);

        return $brickType->fresh();
    }

    /**
     * Deactivate a brick type (soft delete).
     */
    public function deactivateBrickType(BrickType $brickType): BrickType
    {
        return $this->updateStatus($brickType, 'inactive');
    }

    /**
     * Activate a brick type.
     */
    public function activateBrickType(BrickType $brickType): BrickType
    {
        return $this->updateStatus($brickType, 'active');
    }

    /**
     * Get active brick types for Sales Executive dropdowns.
     * This ensures only active brick types are available for selection.
     */
    public function getActiveBrickTypes(): Collection
    {
        return BrickType::active()->get();
    }

    /**
     * Get all brick types (for Admin view).
     */
    public function getAllBrickTypes(): Collection
    {
        return BrickType::all();
    }

    /**
     * Check if a brick type can be deactivated.
     * A brick type should not be deactivated if it has pending requisitions.
     */
    public function canDeactivate(BrickType $brickType): bool
    {
        // Check if there are any pending requisitions using this brick type
        $pendingRequisitions = $brickType->requisitions()
            ->whereIn('status', ['submitted', 'assigned'])
            ->count();

        return $pendingRequisitions === 0;
    }

    /**
     * Validate brick type data before creation or update.
     */
    public function validateBrickTypeData(array $data, ?BrickType $existingBrickType = null): array
    {
        $errors = [];

        // Validate price is positive
        if (isset($data['current_price']) && $data['current_price'] < 0) {
            $errors['current_price'] = ['Price must be a positive number'];
        }

        // Validate name uniqueness
        if (isset($data['name'])) {
            $query = BrickType::where('name', $data['name']);
            if ($existingBrickType) {
                $query->where('id', '!=', $existingBrickType->id);
            }
            if ($query->exists()) {
                $errors['name'] = ['Brick type name must be unique'];
            }
        }

        return $errors;
    }

    /**
     * Get brick types filtered by status.
     */
    public function getBrickTypesByStatus(string $status): Collection
    {
        return BrickType::where('status', $status)->get();
    }

    /**
     * Search brick types by name or category.
     */
    public function searchBrickTypes(string $search, ?string $status = null): Collection
    {
        $query = BrickType::where(function ($q) use ($search) {
            $q->where('name', 'like', "%{$search}%")
              ->orWhere('category', 'like', "%{$search}%")
              ->orWhere('description', 'like', "%{$search}%");
        });

        if ($status) {
            $query->where('status', $status);
        }

        return $query->get();
    }
}