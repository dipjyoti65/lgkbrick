<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use App\Models\BrickType;
use App\Models\Requisition;
use App\Models\DeliveryChallan;
use App\Models\Payment;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class PaymentControllerTest extends TestCase
{
    use RefreshDatabase;

    protected $accountsUser;
    protected $salesUser;
    protected $challan;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles
        $accountsRole = Role::create([
            'name' => 'Accounts',
            'permissions' => json_encode(['manage_payments']),
            'description' => 'Accounts role'
        ]);

        $salesRole = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['create_requisitions']),
            'description' => 'Sales Executive role'
        ]);

        // Create department
        $department = Department::create([
            'name' => 'Accounts',
            'description' => 'Accounts Department'
        ]);

        // Create users
        $this->accountsUser = User::create([
            'name' => 'Accounts User',
            'email' => 'accounts@example.com',
            'password' => bcrypt('password'),
            'role_id' => $accountsRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        $this->salesUser = User::create([
            'name' => 'Sales User',
            'email' => 'sales@example.com',
            'password' => bcrypt('password'),
            'role_id' => $salesRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        // Create test data
        $brickType = BrickType::create([
            'name' => 'Test Brick',
            'description' => 'Test brick type',
            'current_price' => 10.00,
            'unit' => 'piece',
            'category' => 'standard',
            'status' => 'active'
        ]);

        $requisition = Requisition::create([
            'order_number' => 'ORD-001',
            'date' => now()->toDateString(),
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $brickType->id,
            'quantity' => 100,
            'price_per_unit' => 10.00,
            'total_amount' => 1000.00,
            'customer_name' => 'Test Customer',
            'customer_phone' => '1234567890',
            'customer_address' => 'Test Address',
            'customer_location' => 'Test Location',
            'status' => 'submitted'
        ]);

        $this->challan = DeliveryChallan::create([
            'challan_number' => 'CH-001',
            'requisition_id' => $requisition->id,
            'order_number' => 'ORD-001',
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Test Driver',
            'vehicle_type' => 'Truck',
            'location' => 'Test Location',
            'delivery_status' => 'delivered'
        ]);
    }

    public function test_accounts_user_can_access_payment_dashboard()
    {
        Sanctum::actingAs($this->accountsUser);

        $response = $this->getJson('/api/payments');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'payments',
                        'pagination',
                        'summary'
                    ]
                ]);
    }

    public function test_non_accounts_user_cannot_access_payments()
    {
        Sanctum::actingAs($this->salesUser);

        $response = $this->getJson('/api/payments');

        $response->assertStatus(403);
    }

    public function test_accounts_user_can_get_delivered_challans()
    {
        Sanctum::actingAs($this->accountsUser);

        $response = $this->getJson('/api/payments/delivered-challans');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'challans'
                    ]
                ]);
    }

    public function test_accounts_user_can_create_payment_record()
    {
        Sanctum::actingAs($this->accountsUser);

        $paymentData = [
            'delivery_challan_id' => $this->challan->id,
            'total_amount' => 1000.00,
            'amount_received' => 500.00,
            'payment_date' => now()->toDateString(),
            'payment_method' => 'cash',
            'reference_number' => 'REF-001',
            'remarks' => 'Partial payment received'
        ];

        $response = $this->postJson('/api/payments', $paymentData);

        $response->assertStatus(201)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'payment'
                    ]
                ]);

        $this->assertDatabaseHas('payments', [
            'delivery_challan_id' => $this->challan->id,
            'total_amount' => 1000.00,
            'amount_received' => 500.00,
            'payment_status' => 'partial'
        ]);
    }

    public function test_payment_creation_validates_amount_against_total()
    {
        Sanctum::actingAs($this->accountsUser);

        $paymentData = [
            'delivery_challan_id' => $this->challan->id,
            'total_amount' => 1000.00,
            'amount_received' => 1500.00, // Exceeds total
        ];

        $response = $this->postJson('/api/payments', $paymentData);

        $response->assertStatus(400);
    }

    public function test_accounts_user_can_update_payment()
    {
        Sanctum::actingAs($this->accountsUser);

        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => 'pending',
            'total_amount' => 1000.00,
            'amount_received' => 0
        ]);

        $updateData = [
            'amount_received' => 600.00,
            'payment_method' => 'bank_transfer',
            'reference_number' => 'TXN-123'
        ];

        $response = $this->putJson("/api/payments/{$payment->id}", $updateData);

        $response->assertStatus(200);

        $payment->refresh();
        $this->assertEquals(600.00, $payment->amount_received);
        $this->assertEquals('partial', $payment->payment_status);
    }

    public function test_cannot_update_approved_payment()
    {
        Sanctum::actingAs($this->accountsUser);

        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => 'approved',
            'total_amount' => 1000.00,
            'amount_received' => 1000.00,
            'approved_by' => $this->accountsUser->id,
            'approved_at' => now()
        ]);

        $updateData = [
            'amount_received' => 500.00
        ];

        $response = $this->putJson("/api/payments/{$payment->id}", $updateData);

        $response->assertStatus(400);
    }

    public function test_accounts_user_can_approve_payment()
    {
        Sanctum::actingAs($this->accountsUser);

        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => 'paid',
            'total_amount' => 1000.00,
            'amount_received' => 1000.00
        ]);

        $response = $this->postJson("/api/payments/{$payment->id}/approve");

        $response->assertStatus(200);

        $payment->refresh();
        $this->assertEquals('approved', $payment->payment_status);
        $this->assertEquals($this->accountsUser->id, $payment->approved_by);
        $this->assertNotNull($payment->approved_at);
    }

    public function test_unauthenticated_user_cannot_access_payments()
    {
        $response = $this->getJson('/api/payments');

        $response->assertStatus(401);
    }
}