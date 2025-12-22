<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    /**
     * Handle user login and token generation
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::with(['role', 'department'])->where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Invalid credentials',
            ], Response::HTTP_UNAUTHORIZED);
        }

        // Check if user account is active
        if ($user->status !== 'active') {
            return response()->json([
                'status' => 'fail',
                'message' => 'Account is not active',
            ], Response::HTTP_UNAUTHORIZED);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login successful',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role_id' => $user->role_id,
                    'department_id' => $user->department_id,
                    'role' => $user->role,
                    'department' => $user->department,
                    'status' => $user->status,
                    'created_by' => $user->created_by,
                    'created_at' => $user->created_at?->toISOString(),
                    'updated_at' => $user->updated_at?->toISOString(),
                ],
                'token' => $token,
            ],
        ]);
    }

    /**
     * Handle user logout and token revocation
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logout successful',
        ]);
    }

    /**
     * Get current authenticated user with role and permissions
     */
    public function user(Request $request)
    {
        $user = $request->user()->load(['role', 'department']);

        return response()->json([
            'status' => 'success',
            'message' => 'User retrieved successfully',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role_id' => $user->role_id,
                    'department_id' => $user->department_id,
                    'role' => $user->role,
                    'department' => $user->department,
                    'status' => $user->status,
                    'created_by' => $user->created_by,
                    'created_at' => $user->created_at?->toISOString(),
                    'updated_at' => $user->updated_at?->toISOString(),
                    'permissions' => $user->role ? $user->role->permissions : [],
                ],
            ],
        ]);
    }
}