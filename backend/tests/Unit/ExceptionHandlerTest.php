<?php

namespace Tests\Unit;

use App\Exceptions\Handler;
use App\Exceptions\BusinessRuleViolationException;
use App\Exceptions\PriceChangeException;
use App\Exceptions\CalculationMismatchException;
use App\Http\Responses\BaseApiResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Validator;
use Tests\TestCase;

class ExceptionHandlerTest extends TestCase
{
    protected Handler $handler;

    protected function setUp(): void
    {
        parent::setUp();
        $this->handler = new Handler($this->app);
    }

    public function test_handler_includes_business_rule_exceptions_in_dont_report()
    {
        $reflection = new \ReflectionClass($this->handler);
        $dontReportProperty = $reflection->getProperty('dontReport');
        $dontReportProperty->setAccessible(true);
        $dontReport = $dontReportProperty->getValue($this->handler);

        $expectedExceptions = [
            BusinessRuleViolationException::class,
            PriceChangeException::class,
            CalculationMismatchException::class,
            \App\Exceptions\PaymentAmountExceedsOrderException::class,
            \App\Exceptions\RecordImmutableException::class,
            \App\Exceptions\UnauthorizedRoleException::class,
        ];

        foreach ($expectedExceptions as $exception) {
            $this->assertContains($exception, $dontReport, "Exception {$exception} should be in dontReport array");
        }
    }

    public function test_base_api_response_success_format()
    {
        $response = BaseApiResponse::success(['key' => 'value'], 'Success message');
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('success', $data['status']);
        $this->assertEquals('Success message', $data['message']);
        $this->assertEquals(['key' => 'value'], $data['data']);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
    }

    public function test_base_api_response_fail_format()
    {
        $errors = ['field' => ['Error message']];
        $response = BaseApiResponse::fail('Operation failed', $errors);
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('fail', $data['status']);
        $this->assertEquals('Operation failed', $data['message']);
        $this->assertEquals($errors, $data['errors']);
        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
    }

    public function test_base_api_response_validation_error_format()
    {
        $errors = ['email' => ['The email field is required.']];
        $response = BaseApiResponse::validationError($errors, 'Validation failed');
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('fail', $data['status']);
        $this->assertEquals('Validation failed', $data['message']);
        $this->assertEquals($errors, $data['errors']);
        $this->assertEquals(Response::HTTP_UNPROCESSABLE_ENTITY, $response->getStatusCode());
    }

    public function test_base_api_response_unauthorized_format()
    {
        $response = BaseApiResponse::unauthorized('Authentication required');
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('fail', $data['status']);
        $this->assertEquals('Authentication required', $data['message']);
        $this->assertEquals(Response::HTTP_UNAUTHORIZED, $response->getStatusCode());
    }

    public function test_base_api_response_forbidden_format()
    {
        $response = BaseApiResponse::forbidden('Access denied');
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('fail', $data['status']);
        $this->assertEquals('Access denied', $data['message']);
        $this->assertEquals(Response::HTTP_FORBIDDEN, $response->getStatusCode());
    }

    public function test_base_api_response_not_found_format()
    {
        $response = BaseApiResponse::notFound('Resource not found');
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('fail', $data['status']);
        $this->assertEquals('Resource not found', $data['message']);
        $this->assertEquals(Response::HTTP_NOT_FOUND, $response->getStatusCode());
    }

    public function test_base_api_response_error_format()
    {
        $response = BaseApiResponse::error('Internal server error', ['debug' => 'info']);
        $data = json_decode($response->getContent(), true);

        $this->assertEquals('error', $data['status']);
        $this->assertEquals('Internal server error', $data['message']);
        $this->assertEquals(['debug' => 'info'], $data['errors']);
        $this->assertEquals(Response::HTTP_INTERNAL_SERVER_ERROR, $response->getStatusCode());
    }
}