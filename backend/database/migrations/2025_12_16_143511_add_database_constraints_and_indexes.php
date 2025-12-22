<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check constraints are only supported in MySQL/PostgreSQL, not SQLite
        // For production MySQL, we would add these constraints
        if (DB::getDriverName() !== 'sqlite') {
            try {
                // Add check constraints for amount validations
                DB::statement('ALTER TABLE payments ADD CONSTRAINT chk_amount_received_valid CHECK (amount_received >= 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                DB::statement('ALTER TABLE payments ADD CONSTRAINT chk_amount_received_not_exceed_total CHECK (amount_received <= total_amount)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                DB::statement('ALTER TABLE payments ADD CONSTRAINT chk_total_amount_positive CHECK (total_amount > 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                // Add check constraints for requisitions
                DB::statement('ALTER TABLE requisitions ADD CONSTRAINT chk_quantity_positive CHECK (quantity > 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                DB::statement('ALTER TABLE requisitions ADD CONSTRAINT chk_price_per_unit_positive CHECK (price_per_unit > 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                DB::statement('ALTER TABLE requisitions ADD CONSTRAINT chk_total_amount_positive CHECK (total_amount > 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
            
            try {
                // Add check constraints for brick types
                DB::statement('ALTER TABLE brick_types ADD CONSTRAINT chk_current_price_positive CHECK (current_price > 0)');
            } catch (\Exception $e) {
                // Constraint might already exist, ignore
            }
        }
        
        // Add additional performance indexes
        Schema::table('users', function (Blueprint $table) {
            $table->index(['role_id', 'status']);
            $table->index(['department_id', 'status']);
            $table->index(['email', 'status']);
            $table->index(['created_by']);
        });
        
        Schema::table('brick_types', function (Blueprint $table) {
            $table->index(['status', 'category']);
            $table->index(['name', 'status']);
        });
        
        Schema::table('requisitions', function (Blueprint $table) {
            $table->index(['brick_type_id', 'status']);
            $table->index(['customer_name']);
            $table->index(['order_number', 'status']);
        });
        
        Schema::table('delivery_challans', function (Blueprint $table) {
            $table->index(['challan_number', 'delivery_status']);
            $table->index(['vehicle_number']);
            $table->index(['delivery_date']);
        });
        
        Schema::table('payments', function (Blueprint $table) {
            $table->index(['payment_method', 'payment_status']);
            $table->index(['reference_number']);
        });
        
        // Add unique constraint for brick type names
        Schema::table('brick_types', function (Blueprint $table) {
            $table->unique('name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop check constraints (only for non-SQLite databases)
        if (DB::getDriverName() !== 'sqlite') {
            DB::statement('ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_amount_received_valid');
            DB::statement('ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_amount_received_not_exceed_total');
            DB::statement('ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_total_amount_positive');
            DB::statement('ALTER TABLE requisitions DROP CONSTRAINT IF EXISTS chk_quantity_positive');
            DB::statement('ALTER TABLE requisitions DROP CONSTRAINT IF EXISTS chk_price_per_unit_positive');
            DB::statement('ALTER TABLE requisitions DROP CONSTRAINT IF EXISTS chk_total_amount_positive');
            DB::statement('ALTER TABLE brick_types DROP CONSTRAINT IF EXISTS chk_current_price_positive');
        }
        
        // Drop indexes
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['role_id', 'status']);
            $table->dropIndex(['department_id', 'status']);
            $table->dropIndex(['email', 'status']);
            $table->dropIndex(['created_by']);
        });
        
        Schema::table('brick_types', function (Blueprint $table) {
            $table->dropIndex(['status', 'category']);
            $table->dropIndex(['name', 'status']);
            $table->dropUnique(['name']);
        });
        
        Schema::table('requisitions', function (Blueprint $table) {
            $table->dropIndex(['brick_type_id', 'status']);
            $table->dropIndex(['customer_name']);
            $table->dropIndex(['order_number', 'status']);
        });
        
        Schema::table('delivery_challans', function (Blueprint $table) {
            $table->dropIndex(['challan_number', 'delivery_status']);
            $table->dropIndex(['vehicle_number']);
            $table->dropIndex(['delivery_date']);
        });
        
        Schema::table('payments', function (Blueprint $table) {
            $table->dropIndex(['payment_method', 'payment_status']);
            $table->dropIndex(['reference_number']);
        });
    }
};