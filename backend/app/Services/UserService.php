<?php

namespace App\Services;

use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class UserService
{
    /**
     * Create a new user with audit trail.
     *
     * @param array $userData
     * @param User $creator
     * @return User
     * @throws ValidationException
     */
    public function createUser(array $userData, User $creator): User
    {
        // Validate role assignment
        $this->validateRoleAssignment($userData['role_id']);

        // Hash password if provided
        if (isset($userData['password'])) {
            $userData['password'] = Hash::make($userData['password']);
        }

        // Add audit trail
        $userData['created_by'] = $creator->id;

        // Create user
        $user = User::create($userData);

        // Load relationships for response
        $user->load(['role', 'department', 'creator']);

        return $user;
    }

    /**
     * Update an existing user.
     *
     * @param User $user
     * @param array $userData
     * @return User
     * @throws ValidationException
     */
    public function updateUser(User $user, array $userData): User
    {
        // Validate role assignment if role is being changed
        if (isset($userData['role_id'])) {
            $this->validateRoleAssignment($userData['role_id']);
        }

        // Hash password if provided
        if (isset($userData['password'])) {
            $userData['password'] = Hash::make($userData['password']);
        }

        // Update user
        $user->update($userData);

        // Load relationships for response
        $user->load(['role', 'department', 'creator']);

        return $user;
    }

    /**
     * Deactivate a user account.
     *
     * @param User $user
     * @return User
     */
    public function deactivateUser(User $user): User
    {
        $user->update(['status' => 'inactive']);
        
        // Revoke all API tokens for security
        $user->tokens()->delete();

        return $user;
    }

    /**
     * Get users with optional filtering.
     *
     * @param array $filters
     * @return Collection
     */
    public function getUsers(array $filters = []): Collection
    {
        $query = User::with(['role', 'department', 'creator']);

        // Filter by role
        if (isset($filters['role_id'])) {
            $query->where('role_id', $filters['role_id']);
        }

        // Filter by department
        if (isset($filters['department_id'])) {
            $query->where('department_id', $filters['department_id']);
        }

        // Filter by status
        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        return $query->get();
    }

    /**
     * Get a single user with relationships.
     *
     * @param int $userId
     * @return User
     */
    public function getUser(int $userId): User
    {
        return User::with(['role', 'department', 'creator'])->findOrFail($userId);
    }

    /**
     * Validate role assignment.
     *
     * @param int $roleId
     * @throws ValidationException
     */
    private function validateRoleAssignment(int $roleId): void
    {
        $role = Role::find($roleId);
        
        if (!$role) {
            throw ValidationException::withMessages([
                'role_id' => ['The selected role does not exist.']
            ]);
        }

        // Additional business rules can be added here
        // For example, limiting certain roles to specific departments
    }

    /**
     * Get all roles for dropdown selection.
     *
     * @return Collection
     */
    public function getRoles(): Collection
    {
        return Role::all(['id', 'name', 'description']);
    }

    /**
     * Get all departments for dropdown selection.
     *
     * @return Collection
     */
    public function getDepartments(): Collection
    {
        return Department::all(['id', 'name', 'description']);
    }
}