<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Role;
use App\Models\Department;
use App\Models\BrickType;
use App\Models\Requisition;
use App\Models\DeliveryChallan;
use App\Models\Payment;

class ReportExportTest extends TestCase
{
    use RefreshDatabase;

    protected User $accountsUser;

    protected function setUp(): void
    {
        parent::setUp();

        // Create roles and departments
        $accountsRole = Role::create([
            'name' => 'Accounts',
            'permissions' => json_encode(['payments' => true, 'reports' => true]),
            'description' => 'Accounts role'
        ]);

        $department = Department::create([
            'name' => 'Accounts',
            'description' => 'Accounts Department'
        ]);

        // Create user
        $this->accountsUser = User::create([
            'name' => 'Accounts User',
            'email' => 'accounts@test.com',
            'password' => bcrypt('password'),
            'role_id' => $accountsRole->id,
            'department_id' => $department->id,
            'status' => 'active',
            'created_by' => 1,
        ]);
    }

    public function test_accounts_user_can_export_daily_report_as_pdf()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily/export/pdf?date=2024-01-15');

        $response->assertStatus(200)
                ->assertHeader('Content-Type', 'application/pdf')
                ->assertHeader('Content-Disposition', 'attachment; filename="daily-report-2024-01-15.pdf"');
    }

    public function test_accounts_user_can_export_range_report_as_pdf()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/range/export/pdf?from_date=2024-01-01&to_date=2024-01-31');

        $response->assertStatus(200)
                ->assertHeader('Content-Type', 'application/pdf')
                ->assertHeader('Content-Disposition', 'attachment; filename="range-report-2024-01-01-to-2024-01-31.pdf"');
    }

    public function test_accounts_user_can_export_daily_report_as_excel()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/daily/export/excel?date=2024-01-15');

        $response->assertStatus(200)
                ->assertHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                ->assertHeader('Content-Disposition', 'attachment; filename="daily-report-2024-01-15.xlsx"');
    }

    public function test_accounts_user_can_export_range_report_as_excel()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        $response = $this->getJson('/api/reports/range/export/excel?from_date=2024-01-01&to_date=2024-01-31');

        $response->assertStatus(200)
                ->assertHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                ->assertHeader('Content-Disposition', 'attachment; filename="range-report-2024-01-01-to-2024-01-31.xlsx"');
    }

    public function test_export_requires_valid_parameters()
    {
        $this->actingAs($this->accountsUser, 'sanctum');

        // Test PDF export with invalid date
        $response = $this->getJson('/api/reports/daily/export/pdf?date=invalid');
        $response->assertStatus(422);

        // Test Excel export with invalid date range
        $response = $this->getJson('/api/reports/range/export/excel?from_date=2024-01-31&to_date=2024-01-01');
        $response->assertStatus(422);
    }
}