<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('party_id')->nullable()->constrained()->onDelete('set null');
            $table->foreignId('bank_account_id')->nullable()->constrained()->onDelete('set null');
            $table->string('expense_number', 50);
            $table->date('expense_date');
            $table->string('category', 100);
            $table->string('payment_mode', 50);
            $table->decimal('total_amount', 15, 2);
            $table->boolean('with_gst')->default(false);
            $table->text('notes')->nullable();
            $table->string('original_invoice_number', 100)->nullable();
            $table->timestamps();

            $table->unique(['organization_id', 'expense_number']);
            $table->index(['organization_id', 'expense_date']);
            $table->index(['organization_id', 'category']);
        });

        Schema::create('expense_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('expense_id')->constrained()->onDelete('cascade');
            $table->string('item_name');
            $table->text('description')->nullable();
            $table->decimal('quantity', 15, 3);
            $table->decimal('rate', 15, 2);
            $table->decimal('amount', 15, 2);
            $table->timestamps();

            $table->index('expense_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expense_items');
        Schema::dropIfExists('expenses');
    }
};
