<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Laravel\Sanctum\Sanctum;

class UserManagementTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create roles and departments
        $this->adminRole = Role::factory()->create(['name' => 'Admin']);
        $this->salesRole = Role::factory()->create(['name' => 'Sales Executive']);
        $this->department = Department::factory()->create(['name' => 'Administration']);
    }

    public function test_admin_can_list_users(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'role_id' => $this->adminRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Create some test users
        User::factory()->count(3)->create([
            'role_id' => $this->salesRole->id,
            'department_id' => $this->department->id,
            'created_by' => $admin->id
        ]);

        // Authenticate as admin
        Sanctum::actingAs($admin);

        // Make request
        $response = $this->getJson('/api/users');

        // Assert response
        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'users' => [
                            '*' => [
                                'id',
                                'name',
                                'email',
                                'status',
                                'role' => ['id', 'name'],
                                'department' => ['id', 'name']
                            ]
                        ],
                        'roles',
                        'departments'
                    ]
                ]);
    }

    public function test_admin_can_create_user(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'role_id' => $this->adminRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Authenticate as admin
        Sanctum::actingAs($admin);

        // User data
        $userData = [
            'name' => $this->faker->name,
            'email' => $this->faker->unique()->safeEmail,
            'password' => 'password123',
            'role_id' => $this->salesRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ];

        // Make request
        $response = $this->postJson('/api/users', $userData);

        // Assert response
        $response->assertStatus(201)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'user' => [
                            'id',
                            'name',
                            'email',
                            'status',
                            'created_by',
                            'role',
                            'department'
                        ]
                    ]
                ]);

        // Assert database
        $this->assertDatabaseHas('users', [
            'email' => $userData['email'],
            'name' => $userData['name'],
            'role_id' => $userData['role_id'],
            'department_id' => $userData['department_id'],
            'created_by' => $admin->id
        ]);
    }

    public function test_non_admin_cannot_access_user_management(): void
    {
        // Create non-admin user
        $user = User::factory()->create([
            'role_id' => $this->salesRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Authenticate as non-admin
        Sanctum::actingAs($user);

        // Try to access users list
        $response = $this->getJson('/api/users');

        // Assert forbidden
        $response->assertStatus(403);
    }

    public function test_admin_can_update_user(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'role_id' => $this->adminRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Create user to update
        $user = User::factory()->create([
            'role_id' => $this->salesRole->id,
            'department_id' => $this->department->id,
            'created_by' => $admin->id
        ]);

        // Authenticate as admin
        Sanctum::actingAs($admin);

        // Update data
        $updateData = [
            'name' => 'Updated Name',
            'status' => 'inactive'
        ];

        // Make request
        $response = $this->putJson("/api/users/{$user->id}", $updateData);

        // Assert response
        $response->assertStatus(200)
                ->assertJsonPath('data.user.name', 'Updated Name')
                ->assertJsonPath('data.user.status', 'inactive');

        // Assert database
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Updated Name',
            'status' => 'inactive'
        ]);
    }

    public function test_admin_can_deactivate_user(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'role_id' => $this->adminRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Create user to deactivate
        $user = User::factory()->create([
            'role_id' => $this->salesRole->id,
            'department_id' => $this->department->id,
            'created_by' => $admin->id,
            'status' => 'active'
        ]);

        // Authenticate as admin
        Sanctum::actingAs($admin);

        // Make request
        $response = $this->deleteJson("/api/users/{$user->id}");

        // Assert response
        $response->assertStatus(200)
                ->assertJsonPath('data.user.status', 'inactive');

        // Assert database
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'status' => 'inactive'
        ]);
    }

    public function test_admin_cannot_deactivate_self(): void
    {
        // Create admin user
        $admin = User::factory()->create([
            'role_id' => $this->adminRole->id,
            'department_id' => $this->department->id,
            'status' => 'active'
        ]);

        // Authenticate as admin
        Sanctum::actingAs($admin);

        // Try to deactivate self
        $response = $this->deleteJson("/api/users/{$admin->id}");

        // Assert forbidden
        $response->assertStatus(403)
                ->assertJsonPath('message', 'Cannot deactivate your own account');
    }
}