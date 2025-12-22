<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Only modify constraint for non-SQLite databases
        if (DB::getDriverName() !== 'sqlite') {
            try {
                // Drop the price_per_unit constraint that prevents 0 values
                DB::statement('ALTER TABLE requisitions DROP CONSTRAINT IF EXISTS chk_price_per_unit_positive');
                
                // Add new constraint that allows 0 or positive values for price_per_unit
                DB::statement('ALTER TABLE requisitions ADD CONSTRAINT chk_price_per_unit_non_negative CHECK (price_per_unit >= 0)');
            } catch (\Exception $e) {
                // Handle any errors gracefully
                \Log::warning('Failed to modify requisitions price_per_unit constraint: ' . $e->getMessage());
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Only modify constraint for non-SQLite databases
        if (DB::getDriverName() !== 'sqlite') {
            try {
                // Drop the new constraint
                DB::statement('ALTER TABLE requisitions DROP CONSTRAINT IF EXISTS chk_price_per_unit_non_negative');
                
                // Restore the original constraint
                DB::statement('ALTER TABLE requisitions ADD CONSTRAINT chk_price_per_unit_positive CHECK (price_per_unit > 0)');
            } catch (\Exception $e) {
                // Handle any errors gracefully
                \Log::warning('Failed to restore requisitions price_per_unit constraint: ' . $e->getMessage());
            }
        }
    }
};