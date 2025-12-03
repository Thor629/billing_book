<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quotations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->onDelete('cascade');
            $table->foreignId('party_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // Quotation details
            $table->string('quotation_number', 50);
            $table->date('quotation_date');
            $table->integer('valid_for')->default(30); // days
            $table->date('validity_date');
            
            // Amounts
            $table->decimal('subtotal', 15, 2)->default(0);
            $table->decimal('discount_amount', 15, 2)->default(0);
            $table->decimal('tax_amount', 15, 2)->default(0);
            $table->decimal('additional_charges', 15, 2)->default(0);
            $table->decimal('round_off', 10, 2)->default(0);
            $table->decimal('total_amount', 15, 2)->default(0);
            
            // Status
            $table->enum('status', ['open', 'accepted', 'rejected', 'expired', 'converted'])->default('open');
            
            // Additional fields
            $table->text('notes')->nullable();
            $table->text('terms_conditions')->nullable();
            $table->text('bank_details')->nullable();
            $table->boolean('show_bank_details')->default(true);
            $table->boolean('auto_round_off')->default(false);
            
            $table->timestamps();
            $table->softDeletes();
            
            // Indexes
            $table->index(['organization_id', 'quotation_date']);
            $table->index('status');
            $table->unique(['organization_id', 'quotation_number'], 'quotations_org_num_unique');
        });
        
        Schema::create('quotation_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('quotation_id')->constrained()->onDelete('cascade');
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
        Schema::dropIfExists('quotation_items');
        Schema::dropIfExists('quotations');
    }
};
