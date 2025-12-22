<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateBrickTypeRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Only Admin users can create brick types
        return $this->user() && $this->user()->role && $this->user()->role->name === 'Admin';
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255', 'unique:brick_types'],
            'description' => ['nullable', 'string'],
            'current_price' => ['nullable', 'numeric', 'min:0'],
            'unit' => ['nullable', 'string', 'max:50'],
            'category' => ['nullable', 'string', 'max:100'],
            'status' => ['sometimes', 'in:active,inactive'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Brick type name is required.',
            'name.unique' => 'This brick type name already exists. Please choose a different name.',
            'name.max' => 'Brick type name cannot exceed 255 characters.',
            'current_price.numeric' => 'Price must be a valid number.',
            'current_price.min' => 'Price cannot be negative.',
            'unit.max' => 'Unit cannot exceed 50 characters.',
            'category.max' => 'Category cannot exceed 100 characters.',
            'status.in' => 'Status must be either active or inactive.',
        ];
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        // Set default status to active if not provided
        if (!$this->has('status')) {
            $this->merge(['status' => 'active']);
        }
    }
}