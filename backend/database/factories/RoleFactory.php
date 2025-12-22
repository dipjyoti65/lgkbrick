<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Role>
 */
class RoleFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->randomElement(['Admin', 'Sales Executive', 'Logistics', 'Accounts']),
            'permissions' => ['read', 'write'],
            'description' => fake()->sentence(),
        ];
    }

    /**
     * Create an Admin role
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Admin',
            'permissions' => ['users.create', 'users.read', 'users.update', 'users.delete', 'brick-types.create', 'brick-types.read', 'brick-types.update', 'brick-types.delete'],
            'description' => 'System administrator with full access',
        ]);
    }

    /**
     * Create a Sales Executive role
     */
    public function salesExecutive(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Sales Executive',
            'permissions' => ['requisitions.create', 'requisitions.read'],
            'description' => 'Sales team member who creates customer orders',
        ]);
    }

    /**
     * Create a Logistics role
     */
    public function logistics(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Logistics',
            'permissions' => ['requisitions.read', 'delivery-challans.create', 'delivery-challans.read', 'delivery-challans.update'],
            'description' => 'Logistics team member who manages deliveries',
        ]);
    }

    /**
     * Create an Accounts role
     */
    public function accounts(): static
    {
        return $this->state(fn (array $attributes) => [
            'name' => 'Accounts',
            'permissions' => ['payments.create', 'payments.read', 'payments.update', 'reports.read'],
            'description' => 'Accounts team member who manages payments and reports',
        ]);
    }
}