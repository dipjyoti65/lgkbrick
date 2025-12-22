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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('delivery_challan_id')->constrained('delivery_challans')->onDelete('cascade');
            $table->enum('payment_status', ['pending', 'partial', 'paid', 'approved', 'overdue'])->default('pending');
            $table->decimal('total_amount', 10, 2);
            $table->decimal('amount_received', 10, 2)->default(0);
            $table->decimal('remaining_amount', 10, 2)->storedAs('total_amount - amount_received');
            $table->date('payment_date')->nullable();
            $table->enum('payment_method', ['cash', 'cheque', 'bank_transfer', 'upi'])->nullable();
            $table->string('reference_number')->nullable();
            $table->text('remarks')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at')->nullable();
            $table->timestamps();
            
            // Add indexes for performance
            $table->index(['delivery_challan_id']);
            $table->index(['payment_status']);
            $table->index(['payment_date']);
            $table->index(['approved_by']);
            
            // Note: Check constraint for amount_received <= total_amount will be enforced at application level
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
