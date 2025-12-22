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
        Schema::create('requisitions', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->date('date');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('brick_type_id')->constrained('brick_types')->onDelete('cascade');
            $table->decimal('quantity', 10, 2);
            $table->decimal('price_per_unit', 10, 2);
            $table->decimal('total_amount', 12, 2);
            $table->string('customer_name');
            $table->string('customer_phone');
            $table->text('customer_address');
            $table->string('customer_location');
            $table->enum('status', ['submitted', 'assigned', 'delivered', 'paid', 'complete'])->default('submitted');
            $table->timestamps();
            
            // Add indexes for performance
            $table->index(['user_id', 'status']);
            $table->index(['status']);
            $table->index(['date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('requisitions');
    }
};
