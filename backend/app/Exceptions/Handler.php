<?php

namespace App\Exceptions;

use App\Http\Responses\BaseApiResponse;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Throwable;

class Handler extends ExceptionHandler
{
    /**
     * A list of exception types with their corresponding custom log levels.
     *
     * @var array<class-string<\Throwable>, \Psr\Log\LogLevel::*>
     */
    protected $levels = [
        //
    ];

    /**
     * A list of the exception types that are not reported.
     *
     * @var array<int, class-string<\Throwable>>
     */
    protected $dontReport = [
        BusinessRuleViolationException::class,
        PriceChangeException::class,
        CalculationMismatchException::class,
        PaymentAmountExceedsOrderException::class,
        RecordImmutableException::class,
        UnauthorizedRoleException::class,
    ];

    /**
     * A list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });

        // Handle business rule violations
        $this->renderable(function (BusinessRuleViolationException $e, Request $request) {
            if ($request->expectsJson()) {
                return $e->render();
            }
        });

        // Handle validation exceptions with standardized format
        $this->renderable(function (ValidationException $e, Request $request) {
            if ($request->expectsJson()) {
                return BaseApiResponse::validationError($e->errors(), 'Validation failed');
            }
        });

        // Handle authentication exceptions
        $this->renderable(function (AuthenticationException $e, Request $request) {
            if ($request->expectsJson()) {
                return BaseApiResponse::unauthorized('Authentication required');
            }
        });

        // Handle model not found exceptions
        $this->renderable(function (ModelNotFoundException $e, Request $request) {
            if ($request->expectsJson()) {
                $modelName = class_basename($e->getModel());
                return BaseApiResponse::notFound("{$modelName} not found");
            }
        });

        // Handle 404 exceptions
        $this->renderable(function (NotFoundHttpException $e, Request $request) {
            if ($request->expectsJson()) {
                return BaseApiResponse::notFound('Resource not found');
            }
        });

        // Handle access denied exceptions
        $this->renderable(function (AccessDeniedHttpException $e, Request $request) {
            if ($request->expectsJson()) {
                return BaseApiResponse::forbidden('Access denied');
            }
        });

        // Handle general exceptions for API requests
        $this->renderable(function (Throwable $e, Request $request) {
            if ($request->expectsJson()) {
                // Log the error for debugging
                \Log::error('API Exception: ' . $e->getMessage(), [
                    'exception' => $e,
                    'request' => $request->all(),
                    'user' => $request->user()?->id,
                ]);

                // Return standardized error response
                if (config('app.debug')) {
                    return BaseApiResponse::error(
                        'Internal server error: ' . $e->getMessage(),
                        ['trace' => $e->getTraceAsString()]
                    );
                }

                return BaseApiResponse::error('Internal server error');
            }
        });
    }

    /**
     * Convert an authentication exception into a response.
     */
    protected function unauthenticated($request, AuthenticationException $exception): JsonResponse
    {
        if ($request->expectsJson()) {
            return BaseApiResponse::unauthorized('Authentication required');
        }

        return redirect()->guest($exception->redirectTo() ?? route('login'));
    }
}
