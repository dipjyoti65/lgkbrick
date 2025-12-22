<?php

namespace Tests\Feature;

use App\Models\BrickType;
use App\Models\Department;
use App\Models\Requisition;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class RequisitionControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $salesUser;
    protected User $logisticsUser;
    protected User $adminUser;
    protected BrickType $brickType;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles
        $salesRole = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['requisitions.create', 'requisitions.view']),
            'description' => 'Sales Executive role'
        ]);

        $logisticsRole = Role::create([
            'name' => 'Logistics',
            'permissions' => json_encode(['requisitions.view', 'challans.create']),
            'description' => 'Logistics role'
        ]);

        $adminRole = Role::create([
            'name' => 'Admin',
            'permissions' => json_encode(['*']),
            'description' => 'Admin role'
        ]);

        // Create departments
        $salesDept = Department::create([
            'name' => 'Sales',
            'description' => 'Sales Department'
        ]);

        $logisticsDept = Department::create([
            'name' => 'Logistics',
            'description' => 'Logistics Department'
        ]);

        // Create users
        $this->salesUser = User::create([
            'name' => 'Sales Executive',
            'email' => 'sales@example.com',
            'password' => bcrypt('password'),
            'role_id' => $salesRole->id,
            'department_id' => $salesDept->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        $this->logisticsUser = User::create([
            'name' => 'Logistics User',
            'email' => 'logistics@example.com',
            'password' => bcrypt('password'),
            'role_id' => $logisticsRole->id,
            'department_id' => $logisticsDept->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        $this->adminUser = User::create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'password' => bcrypt('password'),
            'role_id' => $adminRole->id,
            'department_id' => $salesDept->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        // Create brick type
        $this->brickType = BrickType::create([
            'name' => 'Red Brick',
            'description' => 'Standard red brick',
            'current_price' => 25.50,
            'unit' => 'piece',
            'category' => 'standard',
            'status' => 'active'
        ]);
    }

    public function test_sales_executive_can_create_requisition()
    {
        Sanctum::actingAs($this->salesUser);

        $requisitionData = [
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St, City',
            'customer_location' => 'Downtown'
        ];

        $response = $this->postJson('/api/requisitions', $requisitionData);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'message' => 'Requisition created successfully'
            ])
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'order_number',
                    'date',
                    'quantity',
                    'price_per_unit',
                    'total_amount',
                    'customer_name',
                    'customer_phone',
                    'customer_address',
                    'customer_location',
                    'status',
                    'user',
                    'brick_type'
                ]
            ]);

        $this->assertDatabaseHas('requisitions', [
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'status' => 'submitted'
        ]);
    }

    public function test_requisition_creation_validates_frontend_total()
    {
        Sanctum::actingAs($this->salesUser);

        $requisitionData = [
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2000.00, // Incorrect total
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St, City',
            'customer_location' => 'Downtown'
        ];

        $response = $this->postJson('/api/requisitions', $requisitionData);

        $response->assertStatus(422)
            ->assertJson([
                'status' => 'fail',
                'message' => 'Validation failed'
            ])
            ->assertJsonStructure([
                'errors' => [
                    'total_amount'
                ]
            ]);
    }

    public function test_requisition_creation_validates_brick_price()
    {
        Sanctum::actingAs($this->salesUser);

        $requisitionData = [
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 20.00, // Incorrect price
            'total_amount' => 2000.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St, City',
            'customer_location' => 'Downtown'
        ];

        $response = $this->postJson('/api/requisitions', $requisitionData);

        $response->assertStatus(422)
            ->assertJson([
                'status' => 'fail',
                'message' => 'Validation failed'
            ])
            ->assertJsonStructure([
                'errors' => [
                    'price_per_unit'
                ]
            ]);
    }

    public function test_sales_executive_can_list_own_requisitions()
    {
        Sanctum::actingAs($this->salesUser);

        // Create requisitions for different users
        $ownRequisition = Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        $otherRequisition = Requisition::create([
            'order_number' => 'ORD000002',
            'date' => now()->toDateString(),
            'user_id' => $this->logisticsUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 50,
            'price_per_unit' => 25.50,
            'total_amount' => 1275.00,
            'customer_name' => 'Jane Doe',
            'customer_phone' => '0987654321',
            'customer_address' => '456 Oak St',
            'customer_location' => 'Uptown',
            'status' => 'submitted'
        ]);

        $response = $this->getJson('/api/requisitions');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Requisitions retrieved successfully'
            ]);

        // Sales Executive should only see their own requisitions
        $data = $response->json('data.data');
        $this->assertCount(1, $data);
        $this->assertEquals($ownRequisition->id, $data[0]['id']);
    }

    public function test_admin_can_list_all_requisitions()
    {
        Sanctum::actingAs($this->adminUser);

        // Create requisitions for different users
        Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        Requisition::create([
            'order_number' => 'ORD000002',
            'date' => now()->toDateString(),
            'user_id' => $this->logisticsUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 50,
            'price_per_unit' => 25.50,
            'total_amount' => 1275.00,
            'customer_name' => 'Jane Doe',
            'customer_phone' => '0987654321',
            'customer_address' => '456 Oak St',
            'customer_location' => 'Uptown',
            'status' => 'submitted'
        ]);

        $response = $this->getJson('/api/requisitions');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Requisitions retrieved successfully'
            ]);

        // Admin should see all requisitions
        $data = $response->json('data.data');
        $this->assertCount(2, $data);
    }

    public function test_can_view_requisition_details()
    {
        Sanctum::actingAs($this->salesUser);

        $requisition = Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        $response = $this->getJson("/api/requisitions/{$requisition->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Requisition retrieved successfully',
                'data' => [
                    'id' => $requisition->id,
                    'order_number' => 'ORD000001',
                    'quantity' => 100,
                    'total_amount' => 2550.00,
                    'customer_name' => 'John Doe'
                ]
            ]);
    }

    public function test_sales_executive_cannot_view_other_users_requisitions()
    {
        Sanctum::actingAs($this->salesUser);

        $otherRequisition = Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->logisticsUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        $response = $this->getJson("/api/requisitions/{$otherRequisition->id}");

        $response->assertStatus(404);
    }

    public function test_logistics_can_view_pending_requisitions()
    {
        Sanctum::actingAs($this->logisticsUser);

        // Create requisitions with different statuses
        $pendingRequisition = Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        $assignedRequisition = Requisition::create([
            'order_number' => 'ORD000002',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 50,
            'price_per_unit' => 25.50,
            'total_amount' => 1275.00,
            'customer_name' => 'Jane Doe',
            'customer_phone' => '0987654321',
            'customer_address' => '456 Oak St',
            'customer_location' => 'Uptown',
            'status' => 'assigned'
        ]);

        $response = $this->getJson('/api/requisitions/pending');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Pending requisitions retrieved successfully'
            ]);

        // Should only return submitted (pending) requisitions
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals($pendingRequisition->id, $data[0]['id']);
    }

    public function test_can_get_brick_price_for_validation()
    {
        Sanctum::actingAs($this->salesUser);

        $response = $this->getJson("/api/brick-types/{$this->brickType->id}/price");

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Brick price retrieved successfully',
                'data' => [
                    'brick_type_id' => $this->brickType->id,
                    'name' => 'Red Brick',
                    'current_price' => 25.50,
                    'unit' => 'piece'
                ]
            ]);
    }

    public function test_cannot_get_price_for_inactive_brick_type()
    {
        Sanctum::actingAs($this->salesUser);

        // Deactivate brick type
        $this->brickType->update(['status' => 'inactive']);

        $response = $this->getJson("/api/brick-types/{$this->brickType->id}/price");

        $response->assertStatus(404)
            ->assertJson([
                'status' => 'fail',
                'message' => 'Brick type not found or inactive'
            ]);
    }

    public function test_requisitions_are_immutable_after_submission()
    {
        Sanctum::actingAs($this->salesUser);

        $requisition = Requisition::create([
            'order_number' => 'ORD000001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'total_amount' => 2550.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'Downtown',
            'status' => 'submitted'
        ]);

        // Try to update
        $response = $this->putJson("/api/requisitions/{$requisition->id}", [
            'quantity' => 200
        ]);

        $response->assertStatus(403)
            ->assertJson([
                'status' => 'fail',
                'message' => 'Requisitions cannot be modified after submission'
            ]);

        // Try to delete
        $response = $this->deleteJson("/api/requisitions/{$requisition->id}");

        $response->assertStatus(403)
            ->assertJson([
                'status' => 'fail',
                'message' => 'Requisitions cannot be deleted after submission'
            ]);
    }

    public function test_unauthenticated_users_cannot_access_requisitions()
    {
        $response = $this->getJson('/api/requisitions');
        $response->assertStatus(401);

        $response = $this->postJson('/api/requisitions', []);
        $response->assertStatus(401);
    }

    public function test_requisition_creation_requires_valid_data()
    {
        Sanctum::actingAs($this->salesUser);

        $response = $this->postJson('/api/requisitions', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors([
                'brick_type_id',
                'quantity',
                'price_per_unit',
                'total_amount',
                'customer_name',
                'customer_phone',
                'customer_address',
                'customer_location'
            ]);
    }
}