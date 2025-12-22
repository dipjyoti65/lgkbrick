<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RequisitionResource extends JsonResource
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
            'order_number' => $this->order_number,
            'date' => $this->date,
            'quantity' => $this->quantity,
            'price_per_unit' => $this->price_per_unit,
            'total_amount' => $this->total_amount,
            'customer_name' => $this->customer_name,
            'customer_phone' => $this->customer_phone,
            'customer_address' => $this->customer_address,
            'customer_location' => $this->customer_location,
            'status' => $this->status,
            'user' => new UserResource($this->whenLoaded('user')),
            'brick_type' => new BrickTypeResource($this->whenLoaded('brickType')),
            'delivery_challan' => new DeliveryChallanResource($this->whenLoaded('deliveryChallan')),
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
            'message' => 'Requisition retrieved successfully',
        ];
    }
}