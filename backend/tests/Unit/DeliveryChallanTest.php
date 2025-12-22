<?php

namespace Tests\Unit;

use App\Models\DeliveryChallan;
use App\Models\Requisition;
use App\Models\User;
use App\Models\BrickType;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeliveryChallanTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create necessary test data
        $this->role = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['create_requisitions']),
            'description' => 'Sales Executive Role'
        ]);

        $this->department = Department::create([
            'name' => 'Sales',
            'description' => 'Sales Department'
        ]);

        $this->user = User::create([
            'name' => 'Sales Executive',
            'email' => 'sales@example.com',
            'password' => bcrypt('password'),
            'role_id' => $this->role->id,
            'department_id' => $this->department->id,
            'status' => 'active',
            'created_by' => 1
        ]);

        $this->brickType = BrickType::create([
            'name' => 'Red Brick',
            'description' => 'Standard red brick',
            'current_price' => 10.50,
            'unit' => 'piece',
            'category' => 'standard',
            'status' => 'active'
        ]);

        $this->requisition = Requisition::create([
            'order_number' => 'ORD-000001',
            'date' => now()->toDateString(),
            'user_id' => $this->user->id,
            'brick_type_id' => $this->brickType->id,
            'quantity' => 100,
            'price_per_unit' => 10.50,
            'total_amount' => 1050.00,
            'customer_name' => 'John Doe',
            'customer_phone' => '1234567890',
            'customer_address' => '123 Main St',
            'customer_location' => 'City Center',
            'status' => 'submitted'
        ]);
    }

    public function test_delivery_challan_has_correct_status_constants()
    {
        $expectedStatuses = ['pending', 'assigned', 'in_transit', 'delivered', 'failed'];
        $actualStatuses = DeliveryChallan::getDeliveryStatusValues();
        
        $this->assertEquals($expectedStatuses, $actualStatuses);
    }

    public function test_delivery_challan_belongs_to_requisition()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        $this->assertInstanceOf(Requisition::class, $challan->requisition);
        $this->assertEquals($this->requisition->id, $challan->requisition->id);
    }

    public function test_delivery_status_check_methods()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        $this->assertTrue($challan->isPending());
        $this->assertFalse($challan->isAssigned());
        $this->assertFalse($challan->isInTransit());
        $this->assertFalse($challan->isDelivered());
        $this->assertFalse($challan->isFailed());
    }

    public function test_delivery_status_transitions()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        // Valid transitions from pending
        $this->assertTrue($challan->canTransitionTo('assigned'));
        $this->assertTrue($challan->canTransitionTo('failed'));
        $this->assertFalse($challan->canTransitionTo('in_transit'));
        $this->assertFalse($challan->canTransitionTo('delivered'));
    }

    public function test_update_delivery_status_with_valid_transition()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        $result = $challan->updateDeliveryStatus('assigned');
        
        $this->assertTrue($result);
        $this->assertEquals('assigned', $challan->delivery_status);
    }

    public function test_update_delivery_status_with_invalid_transition()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        $result = $challan->updateDeliveryStatus('delivered');
        
        $this->assertFalse($result);
        $this->assertEquals('pending', $challan->delivery_status);
    }

    public function test_print_count_functionality()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'pending'
        ]);

        $this->assertEquals(0, $challan->getPrintCount());
        $this->assertFalse($challan->hasBeenPrinted());

        $challan->incrementPrintCount();
        $challan->refresh();

        $this->assertEquals(1, $challan->getPrintCount());
        $this->assertTrue($challan->hasBeenPrinted());
    }

    public function test_delivery_date_set_when_delivered()
    {
        $challan = DeliveryChallan::create([
            'challan_number' => 'CH-000001',
            'requisition_id' => $this->requisition->id,
            'order_number' => $this->requisition->order_number,
            'date' => now()->toDateString(),
            'vehicle_number' => 'ABC-123',
            'driver_name' => 'Driver Name',
            'vehicle_type' => 'Truck',
            'location' => 'Warehouse',
            'delivery_status' => 'in_transit'
        ]);

        $this->assertNull($challan->delivery_date);

        $challan->updateDeliveryStatus('delivered');
        
        $this->assertNotNull($challan->delivery_date);
        $this->assertEquals(now()->toDateString(), $challan->delivery_date->toDateString());
    }
}