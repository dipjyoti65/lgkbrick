<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeliveryChallanResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'challan_number' => $this->challan_number,
            'order_number' => $this->order_number,
            'date' => $this->date,
            'vehicle_number' => $this->vehicle_number,
            'driver_name' => $this->driver_name,
            'vehicle_type' => $this->vehicle_type,
            'location' => $this->location,
            'remarks' => $this->remarks,
            'delivery_status' => $this->delivery_status,
            'delivery_date' => $this->delivery_date,
            'print_count' => $this->print_count,
            'requisition' => new RequisitionResource($this->whenLoaded('requisition')),
            'payment' => new PaymentResource($this->whenLoaded('payment')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }

    /**
     * Get additional data that should be returned with the resource array.
     *
     * @return array<string, mixed>
     */
    public function with(Request $request): array
    {
        return [
            'status' => 'success',
            'message' => 'Delivery challan retrieved successfully',
        ];
    }
}