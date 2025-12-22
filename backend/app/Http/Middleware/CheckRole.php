<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @param  string  ...$roles
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next, ...$roles)
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

        if (!$user->role) {
            return response()->json([
                'status' => 'fail',
                'message' => 'No role assigned',
            ], Response::HTTP_FORBIDDEN);
        }

        // Check if user has any of the required roles
        if (!in_array($user->role->name, $roles)) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Insufficient permissions',
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}