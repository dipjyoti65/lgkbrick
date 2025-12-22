<?php

namespace Tests\Unit;

use App\Http\Responses\BaseApiResponse;
use Illuminate\Http\Response;
use Tests\TestCase;

class ApiResponseTest extends TestCase
{
    public function test_success_response_structure()
    {
        $data = ['user' => ['id' => 1, 'name' => 'Test User']];
        $response = BaseApiResponse::success($data, 'User retrieved successfully');

        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $content = json_decode($response->getContent(), true);
        $this->assertEquals('success', $content['status']);
        $this->assertEquals('User retrieved successfully', $content['message']);
        $this->assertEquals($data, $content['data']);
    }

    public function test_fail_response_structure()
    {
        $errors = ['email' => ['Email is required']];
        $response = BaseApiResponse::fail('Validation failed', $errors, Response::HTTP_UNPROCESSABLE_ENTITY);

        $this->assertEquals(Response::HTTP_UNPROCESSABLE_ENTITY, $response->getStatusCode());
        
        $content = json_decode($response->getContent(), true);
        $this->assertEquals('fail', $content['status']);
        $this->assertEquals('Validation failed', $content['message']);
        $this->assertEquals($errors, $content['errors']);
    }

    public function test_validation_error_response()
    {
        $errors = ['email' => ['Email is required'], 'password' => ['Password is required']];
        $response = BaseApiResponse::validationError($errors);

        $this->assertEquals(Response::HTTP_UNPROCESSABLE_ENTITY, $response->getStatusCode());
        
        $content = json_decode($response->getContent(), true);
        $this->assertEquals('fail', $content['status']);
        $this->assertEquals('Validation failed', $content['message']);
        $this->assertEquals($errors, $content['errors']);
    }

    public function test_unauthorized_response()
    {
        $response = BaseApiResponse::unauthorized();

        $this->assertEquals(Response::HTTP_UNAUTHORIZED, $response->getStatusCode());
        
        $content = json_decode($response->getContent(), true);
        $this->assertEquals('fail', $content['status']);
        $this->assertEquals('Unauthorized', $content['message']);
    }

    public function test_not_found_response()
    {
        $response = BaseApiResponse::notFound('User not found');

        $this->assertEquals(Response::HTTP_NOT_FOUND, $response->getStatusCode());
        
        $content = json_decode($response->getContent(), true);
        $this->assertEquals('fail', $content['status']);
        $this->assertEquals('User not found', $content['message']);
    }
}