<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\DeliveryChallan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PaymentService
{
    /**
     * Create a new payment record with validation
     */
    public function createPayment(array $data): Payment
    {
        return DB::transaction(function () use ($data) {
            // Validate challan exists and is pending
            $challan = DeliveryChallan::with('requisition')->findOrFail($data['delivery_challan_id']);
            
            if ($challan->delivery_status !== DeliveryChallan::STATUS_PENDING) {
                throw new \Exception('Can only create payment for pending challans');
            }

            // Check if payment already exists for this challan
            if ($challan->payment) {
                throw new \Exception('Payment record already exists for this challan');
            }

            // Get total amount from requisition if not provided
            if (!isset($data['total_amount'])) {
                $data['total_amount'] = $challan->requisition->total_amount;
            }

            // Set default values
            $data['amount_received'] = $data['amount_received'] ?? 0;
            $data['payment_status'] = $this->determinePaymentStatus($data['total_amount'], $data['amount_received']);

            // Allow partial payments - no validation needed for amount received vs total

            $payment = Payment::create($data);

            // Update challan status to delivered after payment is created
            $challan->update([
                'delivery_status' => DeliveryChallan::STATUS_DELIVERED,
                'delivery_date' => now()->toDateString()
            ]);

            Log::info('Payment record created', [
                'payment_id' => $payment->id,
                'challan_id' => $challan->id,
                'total_amount' => $data['total_amount']
            ]);

            Log::info('Challan status updated to delivered', [
                'challan_id' => $challan->id,
                'new_status' => DeliveryChallan::STATUS_DELIVERED
            ]);

            return $payment;
        });
    }

    /**
     * Update payment with validation and status management
     */
    public function updatePayment(Payment $payment, array $data): Payment
    {
        return DB::transaction(function () use ($payment, $data) {
            // Check if payment is approved (locked)
            if ($payment->isApproved()) {
                throw new \Exception('Cannot modify approved payment records');
            }

            // Validate amount received if provided
            if (isset($data['amount_received'])) {
                if ($data['amount_received'] > $payment->total_amount) {
                    throw new \Exception('Amount received cannot exceed total amount');
                }
                
                // Update payment status based on amount
                $data['payment_status'] = $this->determinePaymentStatus(
                    $payment->total_amount, 
                    $data['amount_received']
                );
            }

            // Validate payment status transition if provided
            if (isset($data['payment_status'])) {
                $this->validateStatusTransition($payment->payment_status, $data['payment_status']);
            }

            $payment->update($data);

            Log::info('Payment record updated', [
                'payment_id' => $payment->id,
                'updated_fields' => array_keys($data)
            ]);

            return $payment->fresh();
        });
    }

    /**
     * Approve payment and lock it from further modifications
     */
    public function approvePayment(Payment $payment, int $approvedBy): Payment
    {
        return DB::transaction(function () use ($payment, $approvedBy) {
            if ($payment->isApproved()) {
                throw new \Exception('Payment is already approved');
            }

            if (!$payment->isFullyPaid()) {
                throw new \Exception('Can only approve fully paid payments');
            }

            $payment->update([
                'payment_status' => Payment::STATUS_APPROVED,
                'approved_by' => $approvedBy,
                'approved_at' => now(),
            ]);

            Log::info('Payment approved', [
                'payment_id' => $payment->id,
                'approved_by' => $approvedBy
            ]);

            return $payment->fresh();
        });
    }

    /**
     * Determine payment status based on amounts
     */
    protected function determinePaymentStatus(float $totalAmount, float $amountReceived): string
    {
        if ($amountReceived == 0) {
            return Payment::STATUS_PENDING;
        } elseif ($amountReceived < $totalAmount) {
            return Payment::STATUS_PARTIAL;
        } else {
            return Payment::STATUS_PAID;
        }
    }

    /**
     * Validate payment status transitions
     */
    protected function validateStatusTransition(string $currentStatus, string $newStatus): void
    {
        $validTransitions = [
            Payment::STATUS_PENDING => [Payment::STATUS_PARTIAL, Payment::STATUS_PAID, Payment::STATUS_OVERDUE],
            Payment::STATUS_PARTIAL => [Payment::STATUS_PAID, Payment::STATUS_OVERDUE],
            Payment::STATUS_PAID => [Payment::STATUS_APPROVED],
            Payment::STATUS_OVERDUE => [Payment::STATUS_PARTIAL, Payment::STATUS_PAID],
            Payment::STATUS_APPROVED => [], // Final state - no transitions allowed
        ];

        if (!isset($validTransitions[$currentStatus]) || 
            !in_array($newStatus, $validTransitions[$currentStatus])) {
            throw new \Exception("Invalid status transition from {$currentStatus} to {$newStatus}");
        }
    }

    /**
     * Calculate outstanding amounts for reporting
     */
    public function calculateOutstandingAmounts(): array
    {
        $summary = Payment::selectRaw('
            payment_status,
            COUNT(*) as count,
            SUM(total_amount) as total_amount,
            SUM(amount_received) as amount_received,
            SUM(total_amount - amount_received) as outstanding_amount
        ')
        ->groupBy('payment_status')
        ->get()
        ->keyBy('payment_status');

        return [
            'pending' => $summary->get(Payment::STATUS_PENDING, (object)[
                'count' => 0, 'total_amount' => 0, 'amount_received' => 0, 'outstanding_amount' => 0
            ]),
            'partial' => $summary->get(Payment::STATUS_PARTIAL, (object)[
                'count' => 0, 'total_amount' => 0, 'amount_received' => 0, 'outstanding_amount' => 0
            ]),
            'paid' => $summary->get(Payment::STATUS_PAID, (object)[
                'count' => 0, 'total_amount' => 0, 'amount_received' => 0, 'outstanding_amount' => 0
            ]),
            'approved' => $summary->get(Payment::STATUS_APPROVED, (object)[
                'count' => 0, 'total_amount' => 0, 'amount_received' => 0, 'outstanding_amount' => 0
            ]),
            'overdue' => $summary->get(Payment::STATUS_OVERDUE, (object)[
                'count' => 0, 'total_amount' => 0, 'amount_received' => 0, 'outstanding_amount' => 0
            ]),
        ];
    }

    /**
     * Get payment summary for dashboard
     */
    public function getPaymentSummary(): array
    {
        $outstanding = $this->calculateOutstandingAmounts();
        
        $totalOutstanding = array_sum(array_map(function($status) {
            return $status->outstanding_amount;
        }, $outstanding));

        $totalReceived = array_sum(array_map(function($status) {
            return $status->amount_received;
        }, $outstanding));

        return [
            'total_outstanding' => $totalOutstanding,
            'total_received' => $totalReceived,
            'by_status' => $outstanding,
        ];
    }

    /**
     * Generate daily financial report
     */
    public function generateDailyReport(string $date): array
    {
        $payments = Payment::with(['deliveryChallan.requisition'])
            ->whereDate('payment_date', $date)
            ->get();

        $summary = [
            'date' => $date,
            'total_orders' => $payments->count(),
            'total_expected' => $payments->sum('total_amount'),
            'total_received' => $payments->sum('amount_received'),
            'total_outstanding' => $payments->sum(function($payment) {
                return $payment->total_amount - $payment->amount_received;
            }),
            'by_status' => $payments->groupBy('payment_status')->map(function($group, $status) {
                return [
                    'count' => $group->count(),
                    'total_amount' => $group->sum('total_amount'),
                    'amount_received' => $group->sum('amount_received'),
                    'outstanding' => $group->sum(function($payment) {
                        return $payment->total_amount - $payment->amount_received;
                    }),
                ];
            }),
            'payments' => $payments,
        ];

        return $summary;
    }

    /**
     * Generate date range financial report
     */
    public function generateRangeReport(string $fromDate, string $toDate): array
    {
        $payments = Payment::with(['deliveryChallan.requisition'])
            ->whereBetween('payment_date', [$fromDate, $toDate])
            ->get();

        $summary = [
            'from_date' => $fromDate,
            'to_date' => $toDate,
            'total_orders' => $payments->count(),
            'total_expected' => $payments->sum('total_amount'),
            'total_received' => $payments->sum('amount_received'),
            'total_outstanding' => $payments->sum(function($payment) {
                return $payment->total_amount - $payment->amount_received;
            }),
            'by_status' => $payments->groupBy('payment_status')->map(function($group, $status) {
                return [
                    'count' => $group->count(),
                    'total_amount' => $group->sum('total_amount'),
                    'amount_received' => $group->sum('amount_received'),
                    'outstanding' => $group->sum(function($payment) {
                        return $payment->total_amount - $payment->amount_received;
                    }),
                ];
            }),
            'daily_breakdown' => $payments->groupBy(function($payment) {
                return $payment->payment_date ? $payment->payment_date->format('Y-m-d') : 'no_date';
            })->map(function($group, $date) {
                return [
                    'date' => $date,
                    'count' => $group->count(),
                    'total_amount' => $group->sum('total_amount'),
                    'amount_received' => $group->sum('amount_received'),
                    'outstanding' => $group->sum(function($payment) {
                        return $payment->total_amount - $payment->amount_received;
                    }),
                ];
            }),
            'payments' => $payments,
        ];

        return $summary;
    }

    /**
     * Get payment history for audit trail
     */
    public function getPaymentHistory(int $paymentId): array
    {
        // This would typically involve an audit log table
        // For now, return basic information
        $payment = Payment::with(['deliveryChallan.requisition', 'approvedBy'])->findOrFail($paymentId);
        
        return [
            'created_at' => $payment->created_at,
            'updated_at' => $payment->updated_at,
            'approved_at' => $payment->approved_at,
            'approved_by' => $payment->approvedBy?->name,
            'current_status' => $payment->payment_status,
            'total_amount' => $payment->total_amount,
            'amount_received' => $payment->amount_received,
            'remaining_amount' => $payment->remaining_amount,
        ];
    }
}