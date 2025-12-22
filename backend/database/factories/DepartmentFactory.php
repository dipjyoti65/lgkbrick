<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Department>
 */
class DepartmentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->randomElement(['Sales', 'Logistics', 'Accounts', 'Administration']),
            'description' => fake()->sentence(),
        ];
    }

    /**
     * Create a Sales department
     */
    public function sales(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Sales',
            'description' => 'Sales department responsible for customer orders',
        ]);
    }

    /**
     * Create a Logistics department
     */
    public function logistics(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Logistics',
            'description' => 'Logistics department responsible for deliveries',
        ]);
    }

    /**
     * Create an Accounts department
     */
    public function accounts(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Accounts',
            'description' => 'Accounts department responsible for payments and reports',
        ]);
    }

    /**
     * Create an Administration department
     */
    public function administration(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Administration',
            'description' => 'Administration department for system management',
        ]);
    }
}