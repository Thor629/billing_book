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
        Schema::table('purchase_invoices', function (Blueprint $table) {
            $table->foreignId('user_id')->nullable()->after('party_id')->constrained()->onDelete('set null');
            $table->integer('payment_terms')->default(30)->after('invoice_date');
            $table->decimal('additional_charges', 15, 2)->default(0)->after('discount_amount');
            $table->string('payment_status')->default('unpaid')->after('balance_amount');
            $table->foreignId('bank_account_id')->nullable()->after('payment_status')->constrained()->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('purchase_invoices', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['bank_account_id']);
            $table->dropColumn(['user_id', 'payment_terms', 'additional_charges', 'payment_status', 'bank_account_id']);
        });
    }
};
