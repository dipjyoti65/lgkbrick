<?php

namespace Tests\Unit;

use App\Http\Resources\UserResource;
use App\Http\Resources\BrickTypeResource;
use App\Models\User;
use App\Models\BrickType;
use Illuminate\Http\Request;
use Tests\TestCase;

class ApiResourceTest extends TestCase
{
    public function test_user_resource_structure()
    {
        // Create a mock user object
        $user = new User([
            'email' => 'test@example.com',
            'status' => 'active',
            'created_by' => 1,
        ]);
        $user->id = 1;
        $user->created_at = now();
        $user->updated_at = now();

        $resource = new UserResource($user);
        $request = new Request();
        
        $array = $resource->toArray($request);

        $this->assertEquals(1, $array['id']);
        $this->assertEquals('test@example.com', $array['email']);
        $this->assertEquals('active', $array['status']);
        $this->assertEquals(1, $array['created_by']);
        $this->assertArrayHasKey('created_at', $array);
        $this->assertArrayHasKey('updated_at', $array);
    }

    public function test_brick_type_resource_structure()
    {
        // Create a mock brick type object
        $brickType = new BrickType([
            'name' => 'Red Brick',
            'description' => 'Standard red brick',
            'current_price' => 15.50,
            'unit' => 'piece',
            'category' => 'Standard',
            'status' => 'active',
        ]);
        $brickType->id = 1;
        $brickType->created_at = now();
        $brickType->updated_at = now();

        $resource = new BrickTypeResource($brickType);
        $request = new Request();
        
        $array = $resource->toArray($request);

        $this->assertEquals(1, $array['id']);
        $this->assertEquals('Red Brick', $array['name']);
        $this->assertEquals('Standard red brick', $array['description']);
        $this->assertEquals(15.50, $array['current_price']);
        $this->assertEquals('piece', $array['unit']);
        $this->assertEquals('Standard', $array['category']);
        $this->assertEquals('active', $array['status']);
        $this->assertArrayHasKey('created_at', $array);
        $this->assertArrayHasKey('updated_at', $array);
    }

    public function test_user_resource_with_method()
    {
        $user = new User(['id' => 1, 'email' => 'test@example.com']);
        $resource = new UserResource($user);
        $request = new Request();
        
        $with = $resource->with($request);

        $this->assertEquals('success', $with['status']);
        $this->assertEquals('User retrieved successfully', $with['message']);
    }

    public function test_brick_type_resource_with_method()
    {
        $brickType = new BrickType(['id' => 1, 'name' => 'Test Brick']);
        $resource = new BrickTypeResource($brickType);
        $request = new Request();
        
        $with = $resource->with($request);

        $this->assertEquals('success', $with['status']);
        $this->assertEquals('Brick type retrieved successfully', $with['message']);
    }
}