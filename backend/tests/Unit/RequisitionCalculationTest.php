<?php

namespace Tests\Unit;

use App\Models\Requisition;
use App\Models\User;
use App\Models\BrickType;
use App\Models\Role;
use App\Models\Department;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class RequisitionCalculationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create test data
        $role = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['requisitions.create']),
            'description' => 'Sales Executive role'
        ]);
        
        $department = Department::create([
            'name' => 'Sales',
            'description' => 'Sales Department'
        ]);
        
        $this->user = User::create([
            'name' => 'Sales Executive',
            'email' => 'sales@example.com',
            'password' => bcrypt('password'),
            'role_id' => $role->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);
        
        $this->brickType = BrickType::create([
            'name' => 'Red Brick',
            'description' => 'Standard red brick',
            'current_price' => 25.50,
            'unit' => 'piece',
            'category' => 'standard',
            'status' => 'active'
        ]);
    }

    public function test_automatic_total_calculation_on_save()
    {
        $requisition = new Requisition([
            'order_number' => 'ORD-001',
            'date' => now()->toDateString(),
            'user_id' => $this->user->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'City Center',
            'status' => Requisition::STATUS_SUBMITTED
        ]);
        
        // Don't set total_amount manually - let the model calculate it
        $requisition->save();
        
        // Verify the total was calculated automatically
        $this->assertEquals(2550.0, $requisition->total_amount);
    }

    public function test_recalculation_when_quantity_changes()
    {
        $requisition = Requisition::create([
            'order_number' => 'ORD-002',
            'date' => now()->toDateString(),
            'user_id' => $this->user->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'customer_name' => 'Jane Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '456 Oak St',
            'customer_location' => 'Downtown',
            'status' => Requisition::STATUS_SUBMITTED
        ]);
        
        // Initial total should be calculated
        $this->assertEquals(2550.0, $requisition->total_amount);
        
        // Change quantity and save
        $requisition->quantity = 200;
        $requisition->save();
        
        // Total should be recalculated
        $this->assertEquals(5100.0, $requisition->total_amount);
    }

    public function test_recalculation_when_price_changes()
    {
        $requisition = Requisition::create([
            'order_number' => 'ORD-003',
            'date' => now()->toDateString(),
            'user_id' => $this->user->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'customer_name' => 'Bob Smith',
            'customer_phone' => '1234567890',
            'customer_address' => '789 Pine St',
            'customer_location' => 'Uptown',
            'status' => Requisition::STATUS_SUBMITTED
        ]);
        
        // Initial total should be calculated
        $this->assertEquals(2550.0, $requisition->total_amount);
        
        // Change price and save
        $requisition->price_per_unit = 30.00;
        $requisition->save();
        
        // Total should be recalculated
        $this->assertEquals(3000.0, $requisition->total_amount);
    }

    public function test_no_recalculation_when_other_fields_change()
    {
        $requisition = Requisition::create([
            'order_number' => 'ORD-004',
            'date' => now()->toDateString(),
            'user_id' => $this->user->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 25.50,
            'customer_name' => 'Alice Johnson',
            'customer_phone' => '1234567890',
            'customer_address' => '321 Elm St',
            'customer_location' => 'Suburb',
            'status' => Requisition::STATUS_SUBMITTED
        ]);
        
        // Set a specific total amount
        $requisition->total_amount = 9999.99;
        $requisition->save();
        
        // Change customer name (not quantity or price)
        $requisition->customer_name = 'Alice Smith';
        $requisition->save();
        
        // Total should remain unchanged since quantity and price didn't change
        $this->assertEquals(9999.99, $requisition->total_amount);
    }
}