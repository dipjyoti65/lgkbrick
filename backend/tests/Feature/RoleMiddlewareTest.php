<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class RoleMiddlewareTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test that active users can access protected endpoints
     */
    public function testActiveUserCanAccessProtectedEndpoints()
    {
        $role = Role::factory()->admin()->create();
        $department = Department::factory()->administration()->create();
        
        $user = User::factory()->create([
            'email' => 'admin@example.com',
            'password' => Hash::make('password123'),
            'role_id' => $role->id,
            'department_id' => $department->id,
            'status' => 'active',
        ]);

        // Login to get token
        $response = $this->postJson('/api/login', [
            'email' => 'admin@example.com',
            'password' => 'password123',
        ]);

        $token = $response->json('data.token');

        // Test accessing user profile endpoint
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/user');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'user' => [
                            'id',
                            'email',
                            'role',
                            'department',
                            'status',
                            'permissions',
                        ],
                    ],
                ]);
    }

    /**
     * Test that inactive users cannot login
     */
    public function testInactiveUserCannotLogin()
    {
        $role = Role::factory()->admin()->create();
        $department = Department::factory()->administration()->create();
        
        $user = User::factory()->create([
            'email' => 'inactive@example.com',
            'password' => Hash::make('password123'),
            'role_id' => $role->id,
            'department_id' => $department->id,
            'status' => 'inactive',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'inactive@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(401)
                ->assertJson([
                    'status' => 'fail',
                    'message' => 'Account is not active',
                ]);
    }

    /**
     * Test that user profile includes role and permissions
     */
    public function testUserProfileIncludesRoleAndPermissions()
    {
        $role = Role::factory()->salesExecutive()->create();
        $department = Department::factory()->sales()->create();
        
        $user = User::factory()->create([
            'email' => 'sales@example.com',
            'password' => Hash::make('password123'),
            'role_id' => $role->id,
            'department_id' => $department->id,
            'status' => 'active',
        ]);

        // Login to get token
        $response = $this->postJson('/api/login', [
            'email' => 'sales@example.com',
            'password' => 'password123',
        ]);

        $token = $response->json('data.token');

        // Test user profile endpoint
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/user');

        $response->assertStatus(200);
        
        $userData = $response->json('data.user');
        $this->assertEquals('Sales Executive', $userData['role']['name']);
        $this->assertEquals('Sales', $userData['department']['name']);
        $this->assertIsArray($userData['permissions']);
        $this->assertContains('requisitions.create', $userData['permissions']);
    }
}