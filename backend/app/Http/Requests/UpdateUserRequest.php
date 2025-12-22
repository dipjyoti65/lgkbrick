<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Only Admin users can update users
        return $this->user() && $this->user()->role && $this->user()->role->name === 'Admin';
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array|string>
     */
    public function rules(): array
    {
        $userId = $this->route('user');
        
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes', 
                'string', 
                'email', 
                'max:255', 
                Rule::unique('users')->ignore($userId)
            ],
            'password' => ['sometimes', 'string', 'min:8'],
            'role_id' => ['sometimes', 'integer', 'exists:roles,id'],
            'department_id' => ['sometimes', 'integer', 'exists:departments,id'],
            'status' => ['sometimes', 'string', Rule::in(['active', 'inactive'])],
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
            'email.unique' => 'This email address is already registered.',
            'role_id.exists' => 'The selected role does not exist.',
            'department_id.exists' => 'The selected department does not exist.',
            'password.min' => 'Password must be at least 8 characters long.',
        ];
    }
}