<?php

namespace App\Http\Requests;

use App\Models\BrickType;
use Illuminate\Foundation\Http\FormRequest;

class UpdateBrickTypeRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Only Admin users can update brick types
        return $this->user() && $this->user()->role && $this->user()->role->name === 'Admin';
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        $brickType = $this->route('brick_type');
        $brickTypeId = $brickType instanceof BrickType ? $brickType->id : $brickType;
        
        return [
            'name' => ['sometimes', 'string', 'max:255', 'unique:brick_types,name,' . $brickTypeId],
            'description' => ['sometimes', 'nullable', 'string'],
            'current_price' => ['sometimes', 'nullable', 'numeric', 'min:0'],
            'unit' => ['sometimes', 'nullable', 'string', 'max:50'],
            'category' => ['sometimes', 'nullable', 'string', 'max:100'],
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
            'name.unique' => 'This brick type name already exists. Please choose a different name.',
            'name.max' => 'Brick type name cannot exceed 255 characters.',
            'current_price.numeric' => 'Price must be a valid number.',
            'current_price.min' => 'Price cannot be negative.',
            'unit.max' => 'Unit cannot exceed 50 characters.',
            'category.max' => 'Category cannot exceed 100 characters.',
            'status.in' => 'Status must be either active or inactive.',
        ];
    }
}