<?php

namespace Database\Factories;

use App\Models\Role;
use App\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
            'remember_token' => Str::random(10),
            'role_id' => Role::factory(),
            'department_id' => Department::factory(),
            'status' => 'active',
            'created_by' => null,
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     *
     * @return $this
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    /**
     * Create an admin user
     */
    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'role_id' => Role::factory()->admin(),
            'department_id' => Department::factory()->administration(),
        ]);
    }

    /**
     * Create a sales executive user
     */
    public function salesExecutive(): static
    {
        return $this->state(fn (array $attributes) => [
            'role_id' => Role::factory()->salesExecutive(),
            'department_id' => Department::factory()->sales(),
        ]);
    }

    /**
     * Create a logistics user
     */
    public function logistics(): static
    {
        return $this->state(fn (array $attributes) => [
            'role_id' => Role::factory()->logistics(),
            'department_id' => Department::factory()->logistics(),
        ]);
    }

    /**
     * Create an accounts user
     */
    public function accounts(): static
    {
        return $this->state(fn (array $attributes) => [
            'role_id' => Role::factory()->accounts(),
            'department_id' => Department::factory()->accounts(),
        ]);
    }

    /**
     * Create an inactive user
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'inactive',
        ]);
    }
}
