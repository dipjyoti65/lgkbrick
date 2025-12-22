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
                // Drop the existing constraint
                DB::statement('ALTER TABLE brick_types DROP CONSTRAINT IF EXISTS chk_current_price_positive');
                
                // Add new constraint that allows 0 or positive values
                DB::statement('ALTER TABLE brick_types ADD CONSTRAINT chk_current_price_non_negative CHECK (current_price >= 0)');
            } catch (\Exception $e) {
                // Handle any errors gracefully
                \Log::warning('Failed to modify brick_types price constraint: ' . $e->getMessage());
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
                DB::statement('ALTER TABLE brick_types DROP CONSTRAINT IF EXISTS chk_current_price_non_negative');
                
                // Restore the original constraint
                DB::statement('ALTER TABLE brick_types ADD CONSTRAINT chk_current_price_positive CHECK (current_price > 0)');
            } catch (\Exception $e) {
                // Handle any errors gracefully
                \Log::warning('Failed to restore brick_types price constraint: ' . $e->getMessage());
            }
        }
    }
};