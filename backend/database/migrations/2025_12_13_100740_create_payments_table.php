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
            $table->unsignedBigInteger('organization_id');
            $table->unsignedBigInteger('invoice_id');
            $table->string('invoice_type'); // 'sales', 'purchase'
            $table->date('payment_date');
            $table->decimal('amount', 15, 2);
            $table->string('payment_method'); // 'cash', 'card', 'upi', 'cheque', 'bank_transfer'
            $table->string('reference_number')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            // Foreign keys
            $table->foreign('organization_id')->references('id')->on('organizations')->onDelete('cascade');
            
            // Indexes
            $table->index('organization_id');
            $table->index('invoice_id');
            $table->index('invoice_type');
            $table->index('payment_date');
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
