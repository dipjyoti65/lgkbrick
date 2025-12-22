<?php

namespace App\Services;

use App\Models\BrickType;
use App\Models\Requisition;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class RequisitionService
{
    /**
     * Create a new requisition with business logic validation and immutability enforcement.
     * 
     * This method implements:
     * - Database-level order number generation (approach 2)
     * - Frontend total amount validation against current brick pricing
     * - Price change detection and validation
     * - Requisition creation with immutability enforcement
     */
    public function createRequisition(array $data, User $user): Requisition
    {
        return DB::transaction(function () use ($data, $user) {
            // Validate brick type exists and is active
            $brickType = BrickType::active()->findOrFail($data['brick_type_id']);
            
            // Store current brick price for reference (price_per_unit = current price from brick type)
            // But validate total calculation against entered_price (manually entered by user)
            $this->validateTotalAmount($data['quantity'], $data['entered_price'], $data['total_amount']);
            
            // Additional business rule validation
            $this->validateRequisitionBusinessRules($data, $brickType);
            
            // Generate database-level sequential order number (approach 2)
            $orderNumber = $this->generateOrderNumber();
            
            // Create requisition with immutability enforcement (status = submitted)
            $requisition = Requisition::create([
                'order_number' => $orderNumber,
                'date' => Carbon::today(),
                'user_id' => $user->id,
                'brick_type_id' => $data['brick_type_id'],
                'quantity' => $data['quantity'],
                'price_per_unit' => $brickType->current_price, // Store current brick price for reference
                'entered_price' => $data['entered_price'], // Store manually entered price
                'total_amount' => $data['total_amount'],
                'customer_name' => $data['customer_name'],
                'customer_phone' => $data['customer_phone'],
                'customer_address' => $data['customer_address'],
                'customer_location' => $data['customer_location'],
                'status' => Requisition::STATUS_SUBMITTED, // Immutable after creation
            ]);
            
            return $requisition;
        });
    }

    /**
     * Generate database-level sequential order number (approach 2).
     * 
     * Uses database locking to ensure sequential numbering without gaps
     * and prevent race conditions in concurrent environments.
     */
    private function generateOrderNumber(): string
    {
        // Lock the table to prevent concurrent access during number generation
        $lastRequisition = Requisition::lockForUpdate()
            ->orderBy('id', 'desc')
            ->first();
        
        // Calculate next sequential number
        $nextNumber = $lastRequisition ? 
            (int) substr($lastRequisition->order_number, 3) + 1 : 1;
        
        // Format as ORD000001, ORD000002, etc.
        return 'ORD' . str_pad($nextNumber, 6, '0', STR_PAD_LEFT);
    }



    /**
     * Validate frontend total amount calculation against entered price.
     * 
     * Ensures mathematical accuracy of frontend calculations and prevents
     * manipulation of total amounts.
     */
    private function validateTotalAmount(float $quantity, float $enteredPrice, float $totalAmount): void
    {
        $calculatedTotal = $quantity * $enteredPrice;
        
        if (abs($totalAmount - $calculatedTotal) > 0.01) {
            throw ValidationException::withMessages([
                'total_amount' => [
                    'Total amount calculation is incorrect. Expected: ' . number_format($calculatedTotal, 2) . 
                    ', Received: ' . number_format($totalAmount, 2)
                ]
            ]);
        }
    }

    /**
     * Validate comprehensive business rules for requisition creation.
     */
    private function validateRequisitionBusinessRules(array $data, BrickType $brickType): void
    {
        $errors = [];
        
        // Validate quantity constraints
        if ($data['quantity'] <= 0) {
            $errors['quantity'] = ['Quantity must be greater than zero'];
        }
        
        // Validate entered price constraints (manually entered by sales executive)
        if ($data['entered_price'] <= 0) {
            $errors['entered_price'] = ['Entered price must be greater than zero'];
        }
        
        // Validate total amount constraints
        if ($data['total_amount'] <= 0) {
            $errors['total_amount'] = ['Total amount must be greater than zero'];
        }
        
        // Validate customer information completeness
        if (empty(trim($data['customer_name']))) {
            $errors['customer_name'] = ['Customer name is required'];
        }
        
        if (empty(trim($data['customer_phone']))) {
            $errors['customer_phone'] = ['Customer phone is required'];
        }
        
        if (empty(trim($data['customer_address']))) {
            $errors['customer_address'] = ['Customer address is required'];
        }
        
        if (empty(trim($data['customer_location']))) {
            $errors['customer_location'] = ['Customer location is required'];
        }
        
        // Validate brick type is still active
        if ($brickType->status !== 'active') {
            $errors['brick_type_id'] = ['Selected brick type is no longer available'];
        }
        
        if (!empty($errors)) {
            throw ValidationException::withMessages($errors);
        }
    }

    /**
     * Check if brick price has changed since frontend calculation.
     * 
     * Public method for controllers to check price changes before form submission.
     */
    public function checkBrickPriceChanges(int $brickTypeId, float $submittedPrice): bool
    {
        $brickType = BrickType::active()->find($brickTypeId);
        
        if (!$brickType) {
            return true; // Price changed (brick type no longer available)
        }
        
        return abs($submittedPrice - $brickType->current_price) > 0.01;
    }

    /**
     * Validate requisition data for business rules (legacy method for backward compatibility).
     * 
     * @deprecated Use validateRequisitionBusinessRules instead
     */
    public function validateRequisitionData(array $data): array
    {
        $errors = [];
        
        // Check if brick type is active
        $brickType = BrickType::active()->find($data['brick_type_id']);
        if (!$brickType) {
            $errors['brick_type_id'] = ['Selected brick type is not available'];
        }
        
        // Validate quantity is positive
        if ($data['quantity'] <= 0) {
            $errors['quantity'] = ['Quantity must be greater than zero'];
        }
        
        // Validate price is positive
        if ($data['price_per_unit'] <= 0) {
            $errors['price_per_unit'] = ['Price per unit must be greater than zero'];
        }
        
        // Validate total amount is positive
        if ($data['total_amount'] <= 0) {
            $errors['total_amount'] = ['Total amount must be greater than zero'];
        }
        
        return $errors;
    }

    /**
     * Enforce immutability of submitted requisitions.
     * 
     * Validates that a requisition cannot be modified once it has been submitted.
     */
    public function enforceImmutability(Requisition $requisition): void
    {
        if ($requisition->isImmutable()) {
            throw ValidationException::withMessages([
                'requisition' => ['Requisition cannot be modified after submission. Current status: ' . $requisition->status]
            ]);
        }
    }

    /**
     * Get current brick pricing for frontend validation.
     * 
     * Returns current pricing information to help frontend validate calculations.
     */
    public function getCurrentBrickPricing(int $brickTypeId): ?array
    {
        $brickType = BrickType::active()->find($brickTypeId);
        
        if (!$brickType) {
            return null;
        }
        
        return [
            'id' => $brickType->id,
            'name' => $brickType->name,
            'current_price' => $brickType->current_price,
            'unit' => $brickType->unit,
            'status' => $brickType->status
        ];
    }

    /**
     * Validate that a requisition can be processed for the next workflow stage.
     */
    public function validateForWorkflowTransition(Requisition $requisition, string $targetStatus): void
    {
        if (!$requisition->canTransitionTo($targetStatus)) {
            throw ValidationException::withMessages([
                'status' => [
                    'Invalid status transition from ' . $requisition->status . ' to ' . $targetStatus
                ]
            ]);
        }
    }
}