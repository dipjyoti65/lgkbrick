<?php

namespace App\Exceptions;

use Illuminate\Http\Response;

class RecordImmutableException extends BusinessRuleViolationException
{
    public function __construct(string $message = 'Record cannot be modified in its current state', array $errors = [])
    {
        $defaultErrors = [
            'record_status' => ['Record cannot be modified in its current state']
        ];
        
        $mergedErrors = array_merge($defaultErrors, $errors);
        
        parent::__construct($message, $mergedErrors, Response::HTTP_FORBIDDEN);
    }

    /**
     * Create exception for approved payment records.
     */
    public static function forApprovedPayment(): self
    {
        $message = 'Approved payment records cannot be modified';
        $errors = [
            'payment_status' => ['Approved payment records cannot be modified']
        ];

        return new self($message, $errors);
    }

    /**
     * Create exception for submitted requisitions.
     */
    public static function forSubmittedRequisition(): self
    {
        $message = 'Submitted requisitions cannot be modified';
        $errors = [
            'requisition_status' => ['Submitted requisitions cannot be modified']
        ];

        return new self($message, $errors);
    }

    /**
     * Create exception for delivered challans.
     */
    public static function forDeliveredChallan(): self
    {
        $message = 'Delivered challans cannot be modified';
        $errors = [
            'delivery_status' => ['Delivered challans cannot be modified']
        ];

        return new self($message, $errors);
    }
}