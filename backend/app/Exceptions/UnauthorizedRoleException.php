<?php

namespace App\Exceptions;

use Illuminate\Http\Response;

class UnauthorizedRoleException extends BusinessRuleViolationException
{
    public function __construct(string $message = 'Insufficient permissions for this operation', array $errors = [])
    {
        $defaultErrors = [
            'authorization' => ['Insufficient permissions for this operation']
        ];
        
        $mergedErrors = array_merge($defaultErrors, $errors);
        
        parent::__construct($message, $mergedErrors, Response::HTTP_FORBIDDEN);
    }

    /**
     * Create exception with role details.
     */
    public static function withRoleDetails(string $requiredRole, string $userRole): self
    {
        $message = "This operation requires '{$requiredRole}' role. Current role: '{$userRole}'";
        $errors = [
            'authorization' => [$message],
            'required_role' => $requiredRole,
            'user_role' => $userRole,
        ];

        return new self($message, $errors);
    }

    /**
     * Create exception for multiple required roles.
     */
    public static function withMultipleRoles(array $requiredRoles, string $userRole): self
    {
        $rolesString = implode(', ', $requiredRoles);
        $message = "This operation requires one of the following roles: {$rolesString}. Current role: '{$userRole}'";
        $errors = [
            'authorization' => [$message],
            'required_roles' => $requiredRoles,
            'user_role' => $userRole,
        ];

        return new self($message, $errors);
    }
}