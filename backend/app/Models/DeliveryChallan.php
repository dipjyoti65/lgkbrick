<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class DeliveryChallan extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'challan_number',
        'requisition_id',
        'order_number',
        'date',
        'vehicle_number',
        'driver_name',
        'vehicle_type',
        'location',
        'remarks',
        'delivery_status',
        'delivery_date',
        'print_count',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'date' => 'date',
        'delivery_date' => 'date',
        'print_count' => 'integer',
    ];

    /**
     * Delivery status enum values for workflow tracking.
     */
    public const STATUS_PENDING = 'pending';
    public const STATUS_ASSIGNED = 'assigned';
    public const STATUS_IN_TRANSIT = 'in_transit';
    public const STATUS_DELIVERED = 'delivered';
    public const STATUS_FAILED = 'failed';

    /**
     * Get all available delivery status values.
     *
     * @return array
     */
    public static function getDeliveryStatusValues(): array
    {
        return [
            self::STATUS_PENDING,
            self::STATUS_ASSIGNED,
            self::STATUS_IN_TRANSIT,
            self::STATUS_DELIVERED,
            self::STATUS_FAILED,
        ];
    }

    /**
     * Get the requisition that this challan belongs to.
     */
    public function requisition(): BelongsTo
    {
        return $this->belongsTo(Requisition::class);
    }

    /**
     * Get the payment record for this challan.
     */
    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    /**
     * Scope a query to only include challans with a specific delivery status.
     */
    public function scopeWithDeliveryStatus($query, $status)
    {
        return $query->where('delivery_status', $status);
    }

    /**
     * Scope a query to only include pending challans.
     */
    public function scopePending($query)
    {
        return $query->where('delivery_status', self::STATUS_PENDING);
    }

    /**
     * Scope a query to only include assigned challans.
     */
    public function scopeAssigned($query)
    {
        return $query->where('delivery_status', self::STATUS_ASSIGNED);
    }

    /**
     * Scope a query to only include in-transit challans.
     */
    public function scopeInTransit($query)
    {
        return $query->where('delivery_status', self::STATUS_IN_TRANSIT);
    }

    /**
     * Scope a query to only include delivered challans.
     */
    public function scopeDelivered($query)
    {
        return $query->where('delivery_status', self::STATUS_DELIVERED);
    }

    /**
     * Scope a query to only include failed challans.
     */
    public function scopeFailed($query)
    {
        return $query->where('delivery_status', self::STATUS_FAILED);
    }

    /**
     * Check if the challan is in a specific delivery status.
     *
     * @param string $status
     * @return bool
     */
    public function hasDeliveryStatus(string $status): bool
    {
        return $this->delivery_status === $status;
    }

    /**
     * Check if the challan is pending.
     *
     * @return bool
     */
    public function isPending(): bool
    {
        return $this->hasDeliveryStatus(self::STATUS_PENDING);
    }

    /**
     * Check if the challan is assigned.
     *
     * @return bool
     */
    public function isAssigned(): bool
    {
        return $this->hasDeliveryStatus(self::STATUS_ASSIGNED);
    }

    /**
     * Check if the challan is in transit.
     *
     * @return bool
     */
    public function isInTransit(): bool
    {
        return $this->hasDeliveryStatus(self::STATUS_IN_TRANSIT);
    }

    /**
     * Check if the challan is delivered.
     *
     * @return bool
     */
    public function isDelivered(): bool
    {
        return $this->hasDeliveryStatus(self::STATUS_DELIVERED);
    }

    /**
     * Check if the challan delivery failed.
     *
     * @return bool
     */
    public function isFailed(): bool
    {
        return $this->hasDeliveryStatus(self::STATUS_FAILED);
    }

    /**
     * Update the delivery status to the next workflow stage.
     *
     * @param string $newStatus
     * @return bool
     */
    public function updateDeliveryStatus(string $newStatus): bool
    {
        if (!in_array($newStatus, self::getDeliveryStatusValues())) {
            return false;
        }

        // Validate status transition logic
        if (!$this->canTransitionTo($newStatus)) {
            return false;
        }

        $this->delivery_status = $newStatus;
        
        // Set delivery date when status changes to delivered
        if ($newStatus === self::STATUS_DELIVERED && !$this->delivery_date) {
            $this->delivery_date = now()->toDateString();
        }

        return true;
    }

    /**
     * Check if the challan can transition to a new delivery status.
     *
     * @param string $newStatus
     * @return bool
     */
    public function canTransitionTo(string $newStatus): bool
    {
        $validTransitions = [
            self::STATUS_PENDING => [self::STATUS_ASSIGNED, self::STATUS_FAILED],
            self::STATUS_ASSIGNED => [self::STATUS_IN_TRANSIT, self::STATUS_FAILED],
            self::STATUS_IN_TRANSIT => [self::STATUS_DELIVERED, self::STATUS_FAILED],
            self::STATUS_DELIVERED => [], // Final state
            self::STATUS_FAILED => [self::STATUS_ASSIGNED], // Can retry
        ];

        return isset($validTransitions[$this->delivery_status]) && 
               in_array($newStatus, $validTransitions[$this->delivery_status]);
    }

    /**
     * Increment the print count when challan is printed.
     *
     * @return void
     */
    public function incrementPrintCount(): void
    {
        $this->increment('print_count');
    }

    /**
     * Get the print count for tracking purposes.
     *
     * @return int
     */
    public function getPrintCount(): int
    {
        return $this->print_count ?? 0;
    }

    /**
     * Check if the challan has been printed.
     *
     * @return bool
     */
    public function hasBeenPrinted(): bool
    {
        return $this->print_count > 0;
    }

    /**
     * Get formatted challan information for display.
     *
     * @return array
     */
    public function getFormattedInfo(): array
    {
        return [
            'challan_number' => $this->challan_number,
            'order_number' => $this->order_number,
            'date' => $this->date->format('Y-m-d'),
            'vehicle_info' => [
                'number' => $this->vehicle_number,
                'driver' => $this->driver_name,
                'type' => $this->vehicle_type,
            ],
            'location' => $this->location,
            'delivery_status' => $this->delivery_status,
            'delivery_date' => $this->delivery_date?->format('Y-m-d'),
            'print_count' => $this->print_count,
            'remarks' => $this->remarks,
        ];
    }
}
