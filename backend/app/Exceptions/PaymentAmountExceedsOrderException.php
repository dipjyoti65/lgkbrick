<?php

namespace App\Exceptions;

use Illuminate\Http\Response;

class PaymentAmountExceedsOrderException extends BusinessRuleViolationException
{
    public function __construct(string $message = 'Payment amount exceeds order total', array $errors = [])
    {
        $defaultErrors = [
            'amount_received' => ['Payment amount cannot exceed the order total']
        ];
        
        $mergedErrors = array_merge($defaultErrors, $errors);
        
        parent::__construct($message, $mergedErrors, Response::HTTP_UNPROCESSABLE_ENTITY);
    }

    /**
     * Create exception with payment details.
     */
    public static function withPaymentDetails(float $orderTotal, float $attemptedPayment, float $alreadyReceived = 0): self
    {
        $remainingAmount = $orderTotal - $alreadyReceived;
        $message = "Payment amount ({$attemptedPayment}) exceeds remaining order amount ({$remainingAmount})";
        
        $errors = [
            'amount_received' => [$message],
            'order_total' => $orderTotal,
            'attempted_payment' => $attemptedPayment,
            'already_received' => $alreadyReceived,
            'remaining_amount' => $remainingAmount,
        ];

        return new self($message, $errors);
    }
}