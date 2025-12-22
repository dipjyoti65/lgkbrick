<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use App\Models\BrickType;
use App\Models\Requisition;
use App\Models\DeliveryChallan;
use App\Models\Payment;

class ReportControllerTest extends TestCase
{
    use RefreshDatabase;

    protected User $accountsUser;
    protected User $salesUser;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles and departments
        $accountsRole = Role::create([
            'name' => 'Accounts',
            'permissions' => json_encode(['payments' => true, 'reports' => true]),
            'description' => 'Accounts role'
        ]);

        $salesRole = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['requisitions' => true]),
            'description' => 'Sales Executive role'
        ]);

        $department = Department::create([
            'name' => 'Accounts',
            'description' => 'Accounts Department'
        ]);

        // Create users
        $this->accountsUser = User::create([
            'name' => 'Accounts User',
            'email' => 'accounts@test.com',
            'password' => bcrypt('password'),
            'role_id' => $accountsRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1,
        ]);

        $this->salesUser = User::create([
            'name' => 'Sales User',
            'email' => 'sales@test.com',
            'password' => bcrypt('password'),
            'role_id' => $salesRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1,
        ]);
    }

    public function test_accounts_user_can_generate_daily_report()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily?date=2024-01-15');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'report' => [
                            'report_type',
                            'date',
                            'summary' => [
                                'total_delivered_orders',
                                'total_expected_amount',
                                'total_received_amount',
                                'total_outstanding_amount',
                            ],
                            'payment_status_breakdown',
                            'delivered_orders',
                        ]
                    ]
                ]);
    }

    public function test_accounts_user_can_generate_range_report()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/range?from_date=2024-01-01&to_date=2024-01-31');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'status',
                    'message',
                    'data' => [
                        'report' => [
                            'report_type',
                            'from_date',
                            'to_date',
                            'summary' => [
                                'total_delivered_orders',
                                'total_expected_amount',
                                'total_received_amount',
                                'total_outstanding_amount',
                            ],
                            'payment_status_breakdown',
                            'daily_breakdown',
                            'delivered_orders',
                        ]
                    ]
                ]);
    }

    public function test_non_accounts_user_cannot_access_reports()
    {
        $this->actingAs($this->salesUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily?date=2024-01-15');

        $response->assertStatus(403);
    }

    public function test_daily_report_requires_valid_date()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily?date=invalid-date');

        $response->assertStatus(422)
                ->assertJsonValidationErrors(['date']);
    }

    public function test_range_report_requires_valid_dates()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        // Missing dates
        $response = $this->getJson('/api/reports/range');
        $response->assertStatus(422)
                ->assertJsonValidationErrors(['from_date', 'to_date']);

        // Invalid date format
        $response = $this->getJson('/api/reports/range?from_date=invalid&to_date=2024-01-31');
        $response->assertStatus(422)
                ->assertJsonValidationErrors(['from_date']);

        // to_date before from_date
        $response = $this->getJson('/api/reports/range?from_date=2024-01-31&to_date=2024-01-01');
        $response->assertStatus(422)
                ->assertJsonValidationErrors(['to_date']);
    }

    public function test_unauthenticated_user_cannot_access_reports()
    {
        $response = $this->getJson('/api/reports/daily?date=2024-01-15');

        $response->assertStatus(401);
    }

    public function test_report_with_actual_data()
    {
        // Create test data
        $brickType = BrickType::create([
            'name' => 'Red Brick',
            'description' => 'Standard red brick',
            'current_price' => 10.00,
            'unit' => 'piece',
            'category' => 'standard',
            'status' => 'active',
        ]);

        $requisition = Requisition::create([
            'order_number' => 'ORD-001',
            'date' => '2024-01-15',
            'user_id' => $this->salesUser->id,
            'brick_type_id' => $brickType->id,
            'quantity' => 100,
            'price_per_unit' => 10.00,
            'total_amount' => 1000.00,
            'customer_name' => 'Test Customer',
            'customer_phone' => '1234567890',
            'customer_address' => 'Test Address',
            'customer_location' => 'Test Location',
            'status' => 'submitted',
        ]);

        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-001',
            'requisition_id' => $requisition->id,
            'order_number' => $requisition->order_number,
            'date' => '2024-01-15',
            'vehicle_number' => 'ABC123',
            'driver_name' => 'Test Driver',
            'vehicle_type' => 'truck',
            'location' => 'Test Location',
            'delivery_status' => 'delivered',
            'delivery_date' => '2024-01-15',
        ]);

        $payment = Payment::create([
            'delivery_challan_id' => $challan->id,
            'payment_status' => 'partial',
            'total_amount' => 1000.00,
            'amount_received' => 500.00,
            'payment_date' => '2024-01-15',
            'payment_method' => 'cash',
        ]);

        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily?date=2024-01-15');

        $response->assertStatus(200);
        
        $reportData = $response->json('data.report');
        
        $this->assertEquals(1, $reportData['summary']['total_delivered_orders']);
        $this->assertEquals(1000.00, $reportData['summary']['total_expected_amount']);
        $this->assertEquals(500.00, $reportData['summary']['total_received_amount']);
        $this->assertEquals(500.00, $reportData['summary']['total_outstanding_amount']);
        
        // Check payment status breakdown
        $this->assertEquals(1, $reportData['payment_status_breakdown']['partial']['count']);
        $this->assertEquals(1000.00, $reportData['payment_status_breakdown']['partial']['expected_amount']);
        $this->assertEquals(500.00, $reportData['payment_status_breakdown']['partial']['received_amount']);
        $this->assertEquals(500.00, $reportData['payment_status_breakdown']['partial']['outstanding_amount']);
    }
}