<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('brick_types', function (Blueprint $table) {
            // Explicitly make these fields nullable with proper column modification
            $table->decimal('current_price', 10, 2)->nullable()->default(null)->change();
            $table->string('unit', 50)->nullable()->default(null)->change();
            $table->string('category', 100)->nullable()->default(null)->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('brick_types', function (Blueprint $table) {
            // Note: This rollback might fail if there are null values in the database
            $table->decimal('current_price', 10, 2)->nullable(false)->change();
            $table->string('unit', 50)->nullable(false)->change();
            $table->string('category', 100)->nullable(false)->change();
        });
    }
};