<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sales_invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->onDelete('cascade');
            $table->foreignId('party_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // Invoice details
            $table->string('invoice_prefix', 10)->default('INV');
            $table->string('invoice_number', 50);
            $table->date('invoice_date');
            $table->integer('payment_terms')->default(30); // days
            $table->date('due_date');
            
            // Amounts
            $table->decimal('subtotal', 15, 2)->default(0);
            $table->decimal('discount_amount', 15, 2)->default(0);
            $table->decimal('tax_amount', 15, 2)->default(0);
            $table->decimal('additional_charges', 15, 2)->default(0);
            $table->decimal('round_off', 10, 2)->default(0);
            $table->decimal('total_amount', 15, 2)->default(0);
            
            // Payment details
            $table->decimal('amount_received', 15, 2)->default(0);
            $table->decimal('balance_amount', 15, 2)->default(0);
            $table->string('payment_mode', 50)->nullable();
            $table->enum('payment_status', ['paid', 'unpaid', 'partial'])->default('unpaid');
            
            // Additional fields
            $table->text('notes')->nullable();
            $table->text('terms_conditions')->nullable();
            $table->text('bank_details')->nullable();
            $table->boolean('show_bank_details')->default(true);
            $table->boolean('auto_round_off')->default(false);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index(['organization_id', 'invoice_date']);
            $table->index('payment_status');
            $table->unique(['organization_id', 'invoice_prefix', 'invoice_number'], 'sales_inv_org_prefix_num_unique');
        });
        
        Schema::create('sales_invoice_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sales_invoice_id')->constrained()->onDelete('cascade');
            $table->foreignId('item_id')->constrained()->onDelete('cascade');
            
            // Item details
            $table->string('item_name');
            $table->string('hsn_sac', 20)->nullable();
            $table->string('item_code', 50)->nullable();
            $table->decimal('mrp', 15, 2)->nullable();
            
            // Quantity and pricing
            $table->decimal('quantity', 15, 3);
            $table->string('unit', 20)->default('pcs');
            $table->decimal('price_per_unit', 15, 2);
            $table->decimal('discount_percent', 5, 2)->default(0);
            $table->decimal('discount_amount', 15, 2)->default(0);
            
            // Tax
            $table->decimal('tax_percent', 5, 2)->default(0);
            $table->decimal('tax_amount', 15, 2)->default(0);
            
            // Totals
            $table->decimal('line_total', 15, 2);
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sales_invoice_items');
        Schema::dropIfExists('sales_invoices');
    }
};
