<?php

namespace App\Exceptions;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class PriceChangeException extends BusinessRuleViolationException
{
    public function __construct(string $message = 'Brick price has changed. Please refresh and try again.', array $errors = [])
    {
        $defaultErrors = [
            'brick_price' => ['Brick price has changed. Please refresh and try again.']
        ];
        
        $mergedErrors = array_merge($defaultErrors, $errors);
        
        parent::__construct($message, $mergedErrors, Response::HTTP_UNPROCESSABLE_ENTITY);
    }

    /**
     * Create exception with current and submitted prices for detailed error message.
     */
    public static function withPriceDetails(float $currentPrice, float $submittedPrice): self
    {
        $message = "Brick price has changed from {$submittedPrice} to {$currentPrice}. Please refresh and try again.";
        $errors = [
            'brick_price' => [$message],
            'current_price' => $currentPrice,
            'submitted_price' => $submittedPrice,
        ];

        return new self($message, $errors);
    }
}