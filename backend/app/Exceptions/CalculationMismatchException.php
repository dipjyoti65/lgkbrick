<?php

namespace App\Exceptions;

use Illuminate\Http\Response;

class CalculationMismatchException extends BusinessRuleViolationException
{
    public function __construct(string $message = 'Total amount calculation is incorrect', array $errors = [])
    {
        $defaultErrors = [
            'total_amount' => ['Total amount calculation is incorrect']
        ];
        
        $mergedErrors = array_merge($defaultErrors, $errors);
        
        parent::__construct($message, $mergedErrors, Response::HTTP_UNPROCESSABLE_ENTITY);
    }

    /**
     * Create exception with calculation details for debugging.
     */
    public static function withCalculationDetails(float $expectedTotal, float $submittedTotal, float $quantity, float $pricePerUnit): self
    {
        $message = "Total amount calculation is incorrect. Expected: {$expectedTotal}, Submitted: {$submittedTotal}";
        $errors = [
            'total_amount' => [$message],
            'expected_total' => $expectedTotal,
            'submitted_total' => $submittedTotal,
            'quantity' => $quantity,
            'price_per_unit' => $pricePerUnit,
        ];

        return new self($message, $errors);
    }
}