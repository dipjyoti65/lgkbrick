<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use App\Models\BrickType;

class BrickTypeManagementTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected User $adminUser;
    protected User $salesUser;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create roles and departments
        $adminRole = Role::create([
            'name' => 'Admin',
            'permissions' => json_encode(['all']),
            'description' => 'Administrator role'
        ]);
        
        $salesRole = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['requisitions']),
            'description' => 'Sales Executive role'
        ]);

        $department = Department::create([
            'name' => 'Administration',
            'description' => 'Admin department'
        ]);

        // Create test users
        $this->adminUser = User::create([
            'name' => 'Admin User',
            'email' => 'admin@test.com',
            'password' => bcrypt('password'),
            'role_id' => $adminRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        $this->salesUser = User::create([
            'name' => 'Sales User',
            'email' => 'sales@test.com',
            'password' => bcrypt('password'),
            'role_id' => $salesRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);
    }

    public function test_admin_can_create_brick_type()
    {
        $this->actingAs($this->adminUser, 'sanctum');

        $brickTypeData = [
            'name' => 'Red Brick',
            'description' => 'Standard red clay brick',
            'current_price' => 5.50,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active'
        ];

        $response = $this->postJson('/api/brick-types', $brickTypeData);

        $response->assertStatus(201)
                ->assertJson([
                    'status' => 'success',
                    'message' => 'Brick type created successfully'
                ]);

        $this->assertDatabaseHas('brick_types', [
            'name' => 'Red Brick',
            'current_price' => 5.50,
            'status' => 'active'
        ]);
    }

    public function test_admin_can_list_all_brick_types()
    {
        $this->actingAs($this->adminUser, 'sanctum');

        // Create test brick types
        BrickType::create([
            'name' => 'Active Brick',
            'description' => 'Active brick type',
            'current_price' => 5.00,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active'
        ]);

        BrickType::create([
            'name' => 'Inactive Brick',
            'description' => 'Inactive brick type',
            'current_price' => 6.00,
            'unit' => 'piece',
            'category' => 'Premium',
            'status' => 'inactive'
        ]);

        $response = $this->getJson('/api/brick-types');

        $response->assertStatus(200)
                ->assertJson([
                    'status' => 'success',
                    'message' => 'Brick types retrieved successfully'
                ])
                ->assertJsonCount(2, 'data.brick_types');
    }

    public function test_sales_executive_can_only_see_active_brick_types()
    {
        $this->actingAs($this->salesUser, 'sanctum');

        // Create test brick types
        BrickType::create([
            'name' => 'Active Brick',
            'description' => 'Active brick type',
            'current_price' => 5.00,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active'
        ]);

        BrickType::create([
            'name' => 'Inactive Brick',
            'description' => 'Inactive brick type',
            'current_price' => 6.00,
            'unit' => 'piece',
            'category' => 'Premium',
            'status' => 'inactive'
        ]);

        $response = $this->getJson('/api/brick-types/active');

        $response->assertStatus(200)
                ->assertJson([
                    'status' => 'success',
                    'message' => 'Active brick types retrieved successfully'
                ])
                ->assertJsonCount(1, 'data.brick_types');
    }

    public function test_admin_can_update_brick_type_status()
    {
        $this->actingAs($this->adminUser, 'sanctum');

        $brickType = BrickType::create([
            'name' => 'Test Brick',
            'description' => 'Test brick type',
            'current_price' => 5.00,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active'
        ]);

        $response = $this->patchJson("/api/brick-types/{$brickType->id}/status", [
            'status' => 'inactive'
        ]);

        $response->assertStatus(200)
                ->assertJson([
                    'status' => 'success',
                    'message' => 'Brick type status updated successfully'
                ]);

        $this->assertDatabaseHas('brick_types', [
            'id' => $brickType->id,
            'status' => 'inactive'
        ]);
    }

    public function test_admin_can_update_brick_type_price()
    {
        $this->actingAs($this->adminUser, 'sanctum');

        $brickType = BrickType::create([
            'name' => 'Test Brick',
            'description' => 'Test brick type',
            'current_price' => 5.00,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active'
        ]);

        $response = $this->putJson("/api/brick-types/{$brickType->id}", [
            'current_price' => 6.50
        ]);

        $response->assertStatus(200)
                ->assertJson([
                    'status' => 'success',
                    'message' => 'Brick type updated successfully'
                ]);

        $this->assertDatabaseHas('brick_types', [
            'id' => $brickType->id,
            'current_price' => 6.50
        ]);
    }

    public function test_non_admin_cannot_create_brick_type()
    {
        $this->actingAs($this->salesUser, 'sanctum');

        $brickTypeData = [
            'name' => 'Red Brick',
            'description' => 'Standard red clay brick',
            'current_price' => 5.50,
            'unit' => 'piece',
            'category' => 'Standard'
        ];

        $response = $this->postJson('/api/brick-types', $brickTypeData);

        $response->assertStatus(403);
    }
}