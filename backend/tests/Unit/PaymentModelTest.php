<?php

namespace Tests\Unit;

use Tests\TestCase;
use App\Models\Payment;
use App\Models\DeliveryChallan;
use App\Models\Requisition;
use App\Models\BrickType;
use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use Illuminate\Foundation\Testing\RefreshDatabase;

class PaymentModelTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create test data
        $role = Role::create([
            'name' => 'Sales Executive',
            'permissions' => json_encode(['create_requisitions']),
            'description' => 'Can create requisitions'
        ]);
        
        $department = Department::create([
            'name' => 'Sales',
            'description' => 'Sales Department'
        ]);
        
        $user = User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
            'role_id' => $role->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1
        ]);
        
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
            'user_id' => $user->id,
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

    public function test_payment_has_correct_status_constants()
    {
        $this->assertEquals('pending', Payment::STATUS_PENDING);
        $this->assertEquals('partial', Payment::STATUS_PARTIAL);
        $this->assertEquals('paid', Payment::STATUS_PAID);
        $this->assertEquals('approved', Payment::STATUS_APPROVED);
        $this->assertEquals('overdue', Payment::STATUS_OVERDUE);
    }

    public function test_payment_belongs_to_delivery_challan()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_PENDING,
            'total_amount' => 1000.00,
            'amount_received' => 0
        ]);

        $this->assertInstanceOf(DeliveryChallan::class, $payment->deliveryChallan);
        $this->assertEquals($this->challan->id, $payment->deliveryChallan->id);
    }

    public function test_payment_status_check_methods()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_APPROVED,
            'total_amount' => 1000.00,
            'amount_received' => 1000.00
        ]);

        $this->assertTrue($payment->isApproved());
        $this->assertTrue($payment->isFullyPaid());
        $this->assertFalse($payment->isPartial());
    }

    public function test_payment_amount_validation()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_PENDING,
            'total_amount' => 1000.00,
            'amount_received' => 0
        ]);

        $this->assertTrue($payment->validatePaymentAmount(500.00));
        $this->assertTrue($payment->validatePaymentAmount(1000.00));
        $this->assertFalse($payment->validatePaymentAmount(1500.00));
    }

    public function test_remaining_amount_calculation()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_PARTIAL,
            'total_amount' => 1000.00,
            'amount_received' => 600.00
        ]);

        $this->assertEquals(400.00, $payment->remaining_amount);
    }

    public function test_approved_payment_cannot_be_updated()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_APPROVED,
            'total_amount' => 1000.00,
            'amount_received' => 1000.00
        ]);

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Cannot modify approved payment records');
        
        $payment->update(['amount_received' => 500.00]);
    }

    public function test_approved_payment_cannot_be_deleted()
    {
        $payment = Payment::create([
            'delivery_challan_id' => $this->challan->id,
            'payment_status' => Payment::STATUS_APPROVED,
            'total_amount' => 1000.00,
            'amount_received' => 1000.00
        ]);

        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Cannot delete approved payment records');
        
        $payment->delete();
    }

    public function test_get_payment_statuses()
    {
        $statuses = Payment::getPaymentStatuses();
        
        $this->assertContains(Payment::STATUS_PENDING, $statuses);
        $this->assertContains(Payment::STATUS_PARTIAL, $statuses);
        $this->assertContains(Payment::STATUS_PAID, $statuses);
        $this->assertContains(Payment::STATUS_APPROVED, $statuses);
        $this->assertContains(Payment::STATUS_OVERDUE, $statuses);
    }

    public function test_get_payment_methods()
    {
        $methods = Payment::getPaymentMethods();
        
        $this->assertContains(Payment::METHOD_CASH, $methods);
        $this->assertContains(Payment::METHOD_CHEQUE, $methods);
        $this->assertContains(Payment::METHOD_BANK_TRANSFER, $methods);
        $this->assertContains(Payment::METHOD_UPI, $methods);
    }
}