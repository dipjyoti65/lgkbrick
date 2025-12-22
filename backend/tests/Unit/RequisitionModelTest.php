<?php

namespace Tests\Unit;

use App\Models\Requisition;
use App\Models\User;
use App\Models\BrickType;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class RequisitionModelTest extends TestCase
{
    use RefreshDatabase;

    public function test_requisition_has_correct_status_constants()
    {
        $this->assertEquals('submitted', Requisition::STATUS_SUBMITTED);
        $this->assertEquals('assigned', Requisition::STATUS_ASSIGNED);
        $this->assertEquals('delivered', Requisition::STATUS_DELIVERED);
        $this->assertEquals('paid', Requisition::STATUS_PAID);
        $this->assertEquals('complete', Requisition::STATUS_COMPLETE);
    }

    public function test_get_status_values_returns_all_statuses()
    {
        $expected = ['submitted', 'assigned', 'delivered', 'paid', 'complete'];
        $this->assertEquals($expected, Requisition::getStatusValues());
    }

    public function test_calculate_total_amount()
    {
        $requisition = new Requisition();
        $requisition->quantity = 100;
        $requisition->price_per_unit = 25.50;

        $this->assertEquals(2550.0, $requisition->calculateTotalAmount());
    }

    public function test_set_total_amount()
    {
        $requisition = new Requisition();
        $requisition->quantity = 50;
        $requisition->price_per_unit = 10.25;
        
        $requisition->setTotalAmount();
        
        $this->assertEquals(512.5, $requisition->total_amount);
    }

    public function test_verify_total_amount()
    {
        $requisition = new Requisition();
        $requisition->quantity = 100;
        $requisition->price_per_unit = 25.50;
        $requisition->total_amount = 2550.00;

        $this->assertTrue($requisition->verifyTotalAmount());

        $requisition->total_amount = 2500.00;
        $this->assertFalse($requisition->verifyTotalAmount());
    }

    public function test_status_check_methods()
    {
        $requisition = new Requisition();
        
        $requisition->status = Requisition::STATUS_SUBMITTED;
        $this->assertTrue($requisition->isSubmitted());
        $this->assertFalse($requisition->isAssigned());
        
        $requisition->status = Requisition::STATUS_ASSIGNED;
        $this->assertTrue($requisition->isAssigned());
        $this->assertFalse($requisition->isSubmitted());
        
        $requisition->status = Requisition::STATUS_DELIVERED;
        $this->assertTrue($requisition->isDelivered());
        
        $requisition->status = Requisition::STATUS_PAID;
        $this->assertTrue($requisition->isPaid());
        
        $requisition->status = Requisition::STATUS_COMPLETE;
        $this->assertTrue($requisition->isComplete());
    }

    public function test_can_be_modified_only_when_submitted()
    {
        $requisition = new Requisition();
        
        $requisition->status = Requisition::STATUS_SUBMITTED;
        $this->assertTrue($requisition->canBeModified());
        $this->assertFalse($requisition->isImmutable());
        
        $requisition->status = Requisition::STATUS_ASSIGNED;
        $this->assertFalse($requisition->canBeModified());
        $this->assertTrue($requisition->isImmutable());
    }

    public function test_status_transitions()
    {
        $requisition = new Requisition();
        
        // From submitted
        $requisition->status = Requisition::STATUS_SUBMITTED;
        $this->assertTrue($requisition->canTransitionTo(Requisition::STATUS_ASSIGNED));
        $this->assertFalse($requisition->canTransitionTo(Requisition::STATUS_DELIVERED));
        
        // From assigned
        $requisition->status = Requisition::STATUS_ASSIGNED;
        $this->assertTrue($requisition->canTransitionTo(Requisition::STATUS_DELIVERED));
        $this->assertFalse($requisition->canTransitionTo(Requisition::STATUS_PAID));
        
        // From delivered
        $requisition->status = Requisition::STATUS_DELIVERED;
        $this->assertTrue($requisition->canTransitionTo(Requisition::STATUS_PAID));
        $this->assertFalse($requisition->canTransitionTo(Requisition::STATUS_COMPLETE));
        
        // From paid
        $requisition->status = Requisition::STATUS_PAID;
        $this->assertTrue($requisition->canTransitionTo(Requisition::STATUS_COMPLETE));
        $this->assertFalse($requisition->canTransitionTo(Requisition::STATUS_ASSIGNED));
    }

    public function test_update_status_with_valid_transition()
    {
        $requisition = new Requisition();
        $requisition->status = Requisition::STATUS_SUBMITTED;
        
        $result = $requisition->updateStatus(Requisition::STATUS_ASSIGNED);
        
        $this->assertTrue($result);
        $this->assertEquals(Requisition::STATUS_ASSIGNED, $requisition->status);
    }

    public function test_update_status_with_invalid_transition()
    {
        $requisition = new Requisition();
        $requisition->status = Requisition::STATUS_SUBMITTED;
        
        $result = $requisition->updateStatus(Requisition::STATUS_DELIVERED);
        
        $this->assertFalse($result);
        $this->assertEquals(Requisition::STATUS_SUBMITTED, $requisition->status);
    }

    public function test_update_status_with_invalid_status()
    {
        $requisition = new Requisition();
        $requisition->status = Requisition::STATUS_SUBMITTED;
        
        $result = $requisition->updateStatus('invalid_status');
        
        $this->assertFalse($result);
        $this->assertEquals(Requisition::STATUS_SUBMITTED, $requisition->status);
    }
}