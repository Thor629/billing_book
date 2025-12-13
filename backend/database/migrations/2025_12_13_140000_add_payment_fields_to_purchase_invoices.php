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
            $table->string('payment_mode')->nullable()->after('bank_account_id');
            $table->decimal('round_off', 15, 2)->default(0)->after('additional_charges');
            $table->boolean('auto_round_off')->default(false)->after('round_off');
            $table->boolean('fully_paid')->default(false)->after('payment_status');
            $table->decimal('payment_amount', 15, 2)->nullable()->after('fully_paid');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('purchase_invoices', function (Blueprint $table) {
            $table->dropColumn(['payment_mode', 'round_off', 'auto_round_off', 'fully_paid', 'payment_amount']);
        });
    }
};
