<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class CheckPermission
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @param  string  ...$permissions
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, ...$permissions)
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Unauthenticated',
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Check if user account is active
        if ($user->status !== 'active') {
            return response()->json([
                'status' => 'fail',
                'message' => 'Account is not active',
            ], Response::HTTP_FORBIDDEN);
        }

        // Load user role if not already loaded
        if (!$user->relationLoaded('role')) {
            $user->load('role');
        }

        if (!$user->role || !$user->role->permissions) {
            return response()->json([
                'status' => 'fail',
                'message' => 'No permissions assigned',
            ], Response::HTTP_FORBIDDEN);
        }

        $userPermissions = $user->role->permissions;

        // Check if user has any of the required permissions
        foreach ($permissions as $permission) {
            if (in_array($permission, $userPermissions)) {
                return $next($request);
            }
        }

        return response()->json([
            'status' => 'fail',
            'message' => 'Insufficient permissions',
        ], Response::HTTP_FORBIDDEN);
    }
}