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
            // Make current_price, unit, and category nullable
            $table->decimal('current_price', 10, 2)->nullable()->change();
            $table->string('unit')->nullable()->change();
            $table->string('category')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('brick_types', function (Blueprint $table) {
            // Revert back to non-nullable (but this might fail if there are null values)
            $table->decimal('current_price', 10, 2)->nullable(false)->change();
            $table->string('unit')->nullable(false)->change();
            $table->string('category')->nullable(false)->change();
        });
    }
};