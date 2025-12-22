<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Responses\BaseApiResponse;
use App\Http\Resources\UserResource;
use App\Http\Resources\UserCollection;
use App\Models\User;
use App\Exceptions\PriceChangeException;
use App\Exceptions\UnauthorizedRoleException;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

/**
 * Example controller demonstrating the new standardized API response system
 * This shows how existing controllers can be updated to use BaseApiResponse and Resources
 */
class ExampleUpdatedController extends Controller
{
    /**
     * Example of using BaseApiResponse for success with data
     */
    public function getUserWithNewResponse(int $id): JsonResponse
    {
        try {
            $user = User::with(['role', 'department'])->findOrFail($id);
            
            // Using the new UserResource for consistent data formatting
            return BaseApiResponse::success(
                new UserResource($user),
                'User retrieved successfully'
            );
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            // The global exception handler will catch this and return standardized response
            throw $e;
        }
    }

    /**
     * Example of using BaseApiResponse for collections
     */
    public function getUsersWithNewResponse(): JsonResponse
    {
        $users = User::with(['role', 'department'])->get();
        
        // Using UserCollection for consistent collection formatting
        return BaseApiResponse::success(
            new UserCollection($users),
            'Users retrieved successfully'
        );
    }

    /**
     * Example of throwing custom business rule exceptions
     */
    public function demonstratePriceChangeException(): JsonResponse
    {
        // This would be thrown in a service when price validation fails
        throw PriceChangeException::withPriceDetails(150.0, 100.0);
    }

    /**
     * Example of throwing authorization exceptions
     */
    public function demonstrateAuthorizationException(): JsonResponse
    {
        // This would be thrown when user doesn't have required role
        throw UnauthorizedRoleException::withRoleDetails('Admin', 'Sales Executive');
    }

    /**
     * Example of using BaseApiResponse for validation errors
     */
    public function demonstrateValidationError(): JsonResponse
    {
        $errors = [
            'email' => ['The email field is required.'],
            'password' => ['The password field is required.']
        ];
        
        return BaseApiResponse::validationError($errors);
    }

    /**
     * Example of using BaseApiResponse for different HTTP status codes
     */
    public function demonstrateCreatedResponse(): JsonResponse
    {
        $userData = ['id' => 1, 'email' => 'new@example.com'];
        
        return BaseApiResponse::success(
            $userData,
            'User created successfully',
            201 // HTTP_CREATED
        );
    }

    /**
     * Example of using BaseApiResponse for simple success without data
     */
    public function demonstrateSimpleSuccess(): JsonResponse
    {
        return BaseApiResponse::success(
            null,
            'Operation completed successfully'
        );
    }
}