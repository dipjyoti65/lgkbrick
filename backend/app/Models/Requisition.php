<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Requisition extends Model
{
    use HasFactory;

    /**
     * The "booted" method of the model.
     *
     * @return void
     */
    protected static function booted()
    {
        // Automatically calculate total amount when saving
        static::saving(function ($requisition) {
            $requisition->recalculateTotal();
        });
    }

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_number',
        'date',
        'user_id',
        'brick_type_id',
        'quantity',
        'price_per_unit',
        'entered_price',
        'total_amount',
        'customer_name',
        'customer_phone',
        'customer_address',
        'customer_location',
        'status',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'date' => 'date',
        'quantity' => 'decimal:2',
        'price_per_unit' => 'decimal:2',
        'entered_price' => 'decimal:2',
        'total_amount' => 'decimal:2',
    ];

    /**
     * Status enum values for workflow tracking.
     */
    public const STATUS_SUBMITTED = 'submitted';
    public const STATUS_ASSIGNED = 'assigned';
    public const STATUS_DELIVERED = 'delivered';
    public const STATUS_PAID = 'paid';
    public const STATUS_COMPLETE = 'complete';

    /**
     * Get all available status values.
     *
     * @return array
     */
    public static function getStatusValues(): array
    {
        return [
            self::STATUS_SUBMITTED,
            self::STATUS_ASSIGNED,
            self::STATUS_DELIVERED,
            self::STATUS_PAID,
            self::STATUS_COMPLETE,
        ];
    }

    /**
     * Get the user (Sales Executive) who created this requisition.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the brick type for this requisition.
     */
    public function brickType(): BelongsTo
    {
        return $this->belongsTo(BrickType::class);
    }

    /**
     * Get the delivery challan for this requisition.
     */
    public function deliveryChallan(): HasOne
    {
        return $this->hasOne(DeliveryChallan::class);
    }

    /**
     * Calculate the total amount based on quantity and entered price.
     *
     * @return float
     */
    public function calculateTotalAmount(): float
    {
        // Use entered_price for calculation, fallback to price_per_unit if not set
        $priceToUse = $this->entered_price ?? $this->price_per_unit;
        return (float) ($this->quantity * $priceToUse);
    }

    /**
     * Automatically set the total amount based on quantity and price per unit.
     *
     * @return void
     */
    public function setTotalAmount(): void
    {
        $this->total_amount = $this->calculateTotalAmount();
    }

    /**
     * Verify if the stored total amount matches the calculated amount.
     *
     * @return bool
     */
    public function verifyTotalAmount(): bool
    {
        return abs($this->total_amount - $this->calculateTotalAmount()) < 0.01;
    }

    /**
     * Update the total amount if quantity, price per unit, or entered price changes.
     *
     * @return void
     */
    public function recalculateTotal(): void
    {
        if ($this->isDirty(['quantity', 'price_per_unit', 'entered_price'])) {
            $this->setTotalAmount();
        }
    }

    /**
     * Scope a query to only include requisitions by a specific user.
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope a query to only include requisitions with a specific status.
     */
    public function scopeWithStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    /**
     * Scope a query to only include submitted requisitions.
     */
    public function scopeSubmitted($query)
    {
        return $query->where('status', self::STATUS_SUBMITTED);
    }

    /**
     * Scope a query to only include pending requisitions (not yet assigned).
     */
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_SUBMITTED);
    }

    /**
     * Scope a query to only include assigned requisitions.
     */
    public function scopeAssigned($query)
    {
        return $query->where('status', self::STATUS_ASSIGNED);
    }

    /**
     * Scope a query to only include delivered requisitions.
     */
    public function scopeDelivered($query)
    {
        return $query->where('status', self::STATUS_DELIVERED);
    }

    /**
     * Scope a query to only include paid requisitions.
     */
    public function scopePaid($query)
    {
        return $query->where('status', self::STATUS_PAID);
    }

    /**
     * Scope a query to only include complete requisitions.
     */
    public function scopeComplete($query)
    {
        return $query->where('status', self::STATUS_COMPLETE);
    }

    /**
     * Check if the requisition can be modified.
     *
     * @return bool
     */
    public function canBeModified(): bool
    {
        return $this->status === self::STATUS_SUBMITTED;
    }

    /**
     * Check if the requisition is immutable (cannot be modified).
     *
     * @return bool
     */
    public function isImmutable(): bool
    {
        return !$this->canBeModified();
    }

    /**
     * Update the status to the next workflow stage.
     *
     * @param string $newStatus
     * @return bool
     */
    public function updateStatus(string $newStatus): bool
    {
        if (!in_array($newStatus, self::getStatusValues())) {
            return false;
        }

        // Validate status transition logic
        if (!$this->canTransitionTo($newStatus)) {
            return false;
        }

        $this->status = $newStatus;
        return true;
    }

    /**
     * Check if the requisition can transition to a new status.
     *
     * @param string $newStatus
     * @return bool
     */
    public function canTransitionTo(string $newStatus): bool
    {
        $validTransitions = [
            self::STATUS_SUBMITTED => [self::STATUS_ASSIGNED],
            self::STATUS_ASSIGNED => [self::STATUS_DELIVERED],
            self::STATUS_DELIVERED => [self::STATUS_PAID],
            self::STATUS_PAID => [self::STATUS_COMPLETE],
        ];

        return isset($validTransitions[$this->status]) && 
               in_array($newStatus, $validTransitions[$this->status]);
    }

    /**
     * Check if the requisition is in a specific status.
     *
     * @param string $status
     * @return bool
     */
    public function hasStatus(string $status): bool
    {
        return $this->status === $status;
    }

    /**
     * Check if the requisition is submitted.
     *
     * @return bool
     */
    public function isSubmitted(): bool
    {
        return $this->hasStatus(self::STATUS_SUBMITTED);
    }

    /**
     * Check if the requisition is assigned.
     *
     * @return bool
     */
    public function isAssigned(): bool
    {
        return $this->hasStatus(self::STATUS_ASSIGNED);
    }

    /**
     * Check if the requisition is delivered.
     *
     * @return bool
     */
    public function isDelivered(): bool
    {
        return $this->hasStatus(self::STATUS_DELIVERED);
    }

    /**
     * Check if the requisition is paid.
     *
     * @return bool
     */
    public function isPaid(): bool
    {
        return $this->hasStatus(self::STATUS_PAID);
    }

    /**
     * Check if the requisition is complete.
     *
     * @return bool
     */
    public function isComplete(): bool
    {
        return $this->hasStatus(self::STATUS_COMPLETE);
    }
}
