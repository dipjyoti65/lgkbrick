<?php

namespace Tests\Unit;

use App\Exceptions\BusinessRuleViolationException;
use App\Exceptions\PriceChangeException;
use App\Exceptions\CalculationMismatchException;
use App\Exceptions\PaymentAmountExceedsOrderException;
use App\Exceptions\RecordImmutableException;
use App\Exceptions\UnauthorizedRoleException;
use Illuminate\Http\Response;
use Tests\TestCase;

class CustomExceptionsTest extends TestCase
{
    public function test_business_rule_violation_exception()
    {
        $errors = ['field' => ['Error message']];
        $exception = new BusinessRuleViolationException('Business rule violated', $errors);

        $this->assertEquals('Business rule violated', $exception->getMessage());
        $this->assertEquals($errors, $exception->getErrors());
        $this->assertEquals(Response::HTTP_UNPROCESSABLE_ENTITY, $exception->getStatusCode());

        $response = $exception->render();
        $content = json_decode($response->getContent(), true);
        
        $this->assertEquals('fail', $content['status']);
        $this->assertEquals('Business rule violated', $content['message']);
        $this->assertEquals($errors, $content['errors']);
    }

    public function test_price_change_exception_with_details()
    {
        $exception = PriceChangeException::withPriceDetails(150.0, 100.0);

        $this->assertStringContainsString('100', $exception->getMessage());
        $this->assertStringContainsString('150', $exception->getMessage());

        $errors = $exception->getErrors();
        $this->assertEquals(150.0, $errors['current_price']);
        $this->assertEquals(100.0, $errors['submitted_price']);
    }

    public function test_calculation_mismatch_exception_with_details()
    {
        $exception = CalculationMismatchException::withCalculationDetails(1500.0, 1400.0, 10.0, 150.0);

        $errors = $exception->getErrors();
        $this->assertEquals(1500.0, $errors['expected_total']);
        $this->assertEquals(1400.0, $errors['submitted_total']);
        $this->assertEquals(10.0, $errors['quantity']);
        $this->assertEquals(150.0, $errors['price_per_unit']);
    }

    public function test_payment_amount_exceeds_order_exception()
    {
        $exception = PaymentAmountExceedsOrderException::withPaymentDetails(1000.0, 1200.0, 200.0);

        $errors = $exception->getErrors();
        $this->assertEquals(1000.0, $errors['order_total']);
        $this->assertEquals(1200.0, $errors['attempted_payment']);
        $this->assertEquals(200.0, $errors['already_received']);
        $this->assertEquals(800.0, $errors['remaining_amount']);
    }

    public function test_record_immutable_exception_for_approved_payment()
    {
        $exception = RecordImmutableException::forApprovedPayment();

        $this->assertEquals(Response::HTTP_FORBIDDEN, $exception->getStatusCode());
        $this->assertStringContainsString('Approved payment', $exception->getMessage());

        $errors = $exception->getErrors();
        $this->assertArrayHasKey('payment_status', $errors);
    }

    public function test_unauthorized_role_exception_with_role_details()
    {
        $exception = UnauthorizedRoleException::withRoleDetails('Admin', 'Sales Executive');

        $errors = $exception->getErrors();
        $this->assertEquals('Admin', $errors['required_role']);
        $this->assertEquals('Sales Executive', $errors['user_role']);
        $this->assertEquals(Response::HTTP_FORBIDDEN, $exception->getStatusCode());
    }

    public function test_unauthorized_role_exception_with_multiple_roles()
    {
        $requiredRoles = ['Admin', 'Logistics'];
        $exception = UnauthorizedRoleException::withMultipleRoles($requiredRoles, 'Sales Executive');

        $errors = $exception->getErrors();
        $this->assertEquals($requiredRoles, $errors['required_roles']);
        $this->assertEquals('Sales Executive', $errors['user_role']);
    }
}