<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'report_type' => $this->resource['report_type'] ?? 'financial_summary',
            'date_range' => [
                'start_date' => $this->resource['start_date'] ?? null,
                'end_date' => $this->resource['end_date'] ?? null,
            ],
            'summary' => [
                'total_orders' => $this->resource['total_orders'] ?? 0,
                'total_delivered' => $this->resource['total_delivered'] ?? 0,
                'total_expected_amount' => $this->resource['total_expected_amount'] ?? 0,
                'total_received_amount' => $this->resource['total_received_amount'] ?? 0,
                'total_outstanding_amount' => $this->resource['total_outstanding_amount'] ?? 0,
            ],
            'breakdown_by_status' => $this->resource['breakdown_by_status'] ?? [],
            'details' => $this->resource['details'] ?? [],
            'generated_at' => $this->resource['generated_at'] ?? now()->toISOString(),
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
            'message' => 'Report generated successfully',
        ];
    }
}