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
        Schema::create('delivery_challans', function (Blueprint $table) {
            $table->id();
            $table->string('challan_number')->unique();
            $table->foreignId('requisition_id')->constrained('requisitions')->onDelete('cascade');
            $table->string('order_number'); // Copied from requisitions table for easy reference
            $table->date('date');
            $table->string('vehicle_number');
            $table->string('driver_name');
            $table->string('vehicle_type');
            $table->string('location');
            $table->text('remarks')->nullable();
            $table->enum('delivery_status', ['pending', 'assigned', 'in_transit', 'delivered', 'failed'])->default('pending');
            $table->date('delivery_date')->nullable();
            $table->integer('print_count')->default(0);
            $table->timestamps();
            
            // Add indexes for performance
            $table->index(['requisition_id']);
            $table->index(['delivery_status']);
            $table->index(['date']);
            $table->index(['order_number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('delivery_challans');
    }
};
