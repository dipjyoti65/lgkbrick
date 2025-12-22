<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'delivery_challan_id',
        'payment_status',
        'total_amount',
        'amount_received',
        'payment_date',
        'payment_method',
        'reference_number',
        'remarks',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'total_amount' => 'decimal:2',
        'amount_received' => 'decimal:2',
        'remaining_amount' => 'decimal:2',
        'payment_date' => 'date',
        'approved_at' => 'datetime',
    ];

    /**
     * Payment status constants
     */
    const STATUS_PENDING = 'pending';
    const STATUS_PARTIAL = 'partial';
    const STATUS_PAID = 'paid';
    const STATUS_APPROVED = 'approved';
    const STATUS_OVERDUE = 'overdue';

    /**
     * Payment method constants
     */
    const METHOD_CASH = 'cash';
    const METHOD_CHEQUE = 'cheque';
    const METHOD_BANK_TRANSFER = 'bank_transfer';
    const METHOD_UPI = 'upi';

    /**
     * Get the delivery challan that owns the payment.
     */
    public function deliveryChallan(): BelongsTo
    {
        return $this->belongsTo(DeliveryChallan::class);
    }

    /**
     * Get the user who approved the payment.
     */
    public function approvedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    /**
     * Check if payment is approved and locked
     */
    public function isApproved(): bool
    {
        return $this->payment_status === self::STATUS_APPROVED;
    }

    /**
     * Check if payment is fully paid
     */
    public function isFullyPaid(): bool
    {
        return $this->amount_received >= $this->total_amount;
    }

    /**
     * Check if payment is partial
     */
    public function isPartial(): bool
    {
        return $this->amount_received > 0 && $this->amount_received < $this->total_amount;
    }

    /**
     * Get remaining amount (computed field)
     */
    public function getRemainingAmountAttribute(): float
    {
        return $this->total_amount - $this->amount_received;
    }

    /**
     * Validate payment amount doesn't exceed total
     */
    public function validatePaymentAmount(float $amount): bool
    {
        return $amount <= $this->total_amount;
    }

    /**
     * Get available payment statuses
     */
    public static function getPaymentStatuses(): array
    {
        return [
            self::STATUS_PENDING,
            self::STATUS_PARTIAL,
            self::STATUS_PAID,
            self::STATUS_APPROVED,
            self::STATUS_OVERDUE,
        ];
    }

    /**
     * Get available payment methods
     */
    public static function getPaymentMethods(): array
    {
        return [
            self::METHOD_CASH,
            self::METHOD_CHEQUE,
            self::METHOD_BANK_TRANSFER,
            self::METHOD_UPI,
        ];
    }

    /**
     * Boot method to add model events
     */
    protected static function boot()
    {
        parent::boot();

        // Prevent updates if payment is approved (locking mechanism)
        static::updating(function ($payment) {
            if ($payment->getOriginal('payment_status') === self::STATUS_APPROVED) {
                throw new \Exception('Cannot modify approved payment records');
            }
        });

        // Prevent deletion if payment is approved
        static::deleting(function ($payment) {
            if ($payment->payment_status === self::STATUS_APPROVED) {
                throw new \Exception('Cannot delete approved payment records');
            }
        });
    }
}
