<?php

namespace App\Services;

use App\Models\DeliveryChallan;
use App\Models\Requisition;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ChallanService
{
    /**
     * Create a delivery challan from a requisition.
     *
     * @param array $data
     * @param Requisition $requisition
     * @return DeliveryChallan
     * @throws ValidationException
     */
    public function createChallanFromRequisition(array $data, Requisition $requisition): DeliveryChallan
    {
        // Validate requisition eligibility
        $this->validateRequisitionForChallan($requisition);

        return DB::transaction(function () use ($data, $requisition) {
            // Generate challan number using database-level approach
            $challanNumber = $this->generateChallanNumber();

            // Auto-fill data from requisition
            $challanData = array_merge($data, [
                'challan_number' => $challanNumber,
                'requisition_id' => $requisition->id,
                'order_number' => $requisition->order_number,
                'date' => now()->toDateString(),
                'delivery_status' => DeliveryChallan::STATUS_PENDING,
                'print_count' => 0,
            ]);

            // Create the challan
            $challan = DeliveryChallan::create($challanData);

            // Update requisition status to assigned
            $requisition->updateStatus(Requisition::STATUS_ASSIGNED);
            $requisition->save();

            return $challan;
        });
    }

    /**
     * Validate if a requisition is eligible for challan creation.
     *
     * @param Requisition $requisition
     * @throws ValidationException
     */
    public function validateRequisitionForChallan(Requisition $requisition): void
    {
        if (!$requisition->isSubmitted()) {
            throw ValidationException::withMessages([
                'requisition' => ['Only submitted requisitions can have delivery challans created.']
            ]);
        }

        if ($requisition->deliveryChallan) {
            throw ValidationException::withMessages([
                'requisition' => ['This requisition already has a delivery challan.']
            ]);
        }
    }

    /**
     * Generate a unique challan number using database-level approach.
     *
     * @return string
     */
    protected function generateChallanNumber(): string
    {
        return DB::transaction(function () {
            // Get the next sequence number
            $lastChallan = DeliveryChallan::lockForUpdate()
                ->orderBy('id', 'desc')
                ->first();

            $nextNumber = $lastChallan ? 
                (int) substr($lastChallan->challan_number, 3) + 1 : 1;

            return 'CH-' . str_pad($nextNumber, 6, '0', STR_PAD_LEFT);
        });
    }

    /**
     * Update delivery status with workflow validation.
     *
     * @param DeliveryChallan $challan
     * @param string $newStatus
     * @return bool
     * @throws ValidationException
     */
    public function updateDeliveryStatus(DeliveryChallan $challan, string $newStatus): bool
    {
        if (!$challan->canTransitionTo($newStatus)) {
            throw ValidationException::withMessages([
                'delivery_status' => ["Cannot transition from {$challan->delivery_status} to {$newStatus}."]
            ]);
        }

        $success = $challan->updateDeliveryStatus($newStatus);
        
        if ($success) {
            $challan->save();
            
            // Update related requisition status if challan is delivered
            if ($newStatus === DeliveryChallan::STATUS_DELIVERED) {
                $requisition = $challan->requisition;
                $requisition->updateStatus(Requisition::STATUS_DELIVERED);
                $requisition->save();
            }
        }

        return $success;
    }

    /**
     * Generate printable document data for a challan.
     *
     * @param DeliveryChallan $challan
     * @return array
     */
    public function generatePrintableDocument(DeliveryChallan $challan): array
    {
        $requisition = $challan->requisition;
        $brickType = $requisition->brickType;
        $salesExecutive = $requisition->user;

        return [
            'challan_info' => [
                'challan_number' => $challan->challan_number,
                'order_number' => $challan->order_number,
                'date' => $challan->date->format('d/m/Y'),
                'delivery_status' => ucfirst(str_replace('_', ' ', $challan->delivery_status)),
            ],
            'order_details' => [
                'brick_type' => $brickType->name,
                'quantity' => $requisition->quantity,
                'unit' => $brickType->unit,
                'price_per_unit' => $requisition->price_per_unit,
                'total_amount' => $requisition->total_amount,
            ],
            'customer_details' => [
                'name' => $requisition->customer_name,
                'phone' => $requisition->customer_phone,
                'address' => $requisition->customer_address,
                'location' => $requisition->customer_location,
            ],
            'vehicle_details' => [
                'vehicle_number' => $challan->vehicle_number,
                'driver_name' => $challan->driver_name,
                'vehicle_type' => $challan->vehicle_type,
                'location' => $challan->location,
            ],
            'sales_executive' => [
                'name' => $salesExecutive->name ?? $salesExecutive->email,
                'email' => $salesExecutive->email,
            ],
            'delivery_info' => [
                'delivery_date' => $challan->delivery_date?->format('d/m/Y'),
                'remarks' => $challan->remarks,
            ],
            'print_info' => [
                'print_count' => $challan->print_count + 1, // Will be incremented after printing
                'generated_at' => now()->format('d/m/Y H:i:s'),
            ]
        ];
    }

    /**
     * Mark challan as printed and increment print count.
     *
     * @param DeliveryChallan $challan
     * @return void
     */
    public function markAsPrinted(DeliveryChallan $challan): void
    {
        $challan->incrementPrintCount();
    }

    /**
     * Get pending orders queue for Logistics users.
     *
     * @return \Illuminate\Database\Eloquent\Collection
     */
    public function getPendingOrdersQueue()
    {
        return Requisition::with(['user', 'brickType'])
            ->submitted()
            ->whereDoesntHave('deliveryChallan')
            ->orderBy('created_at', 'asc')
            ->get();
    }
}