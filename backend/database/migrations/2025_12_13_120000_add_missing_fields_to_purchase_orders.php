<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->decimal('additional_charges', 15, 2)->default(0)->after('discount_amount');
            $table->decimal('round_off', 15, 2)->default(0)->after('additional_charges');
            $table->boolean('auto_round_off')->default(false)->after('round_off');
            $table->boolean('fully_paid')->default(false)->after('auto_round_off');
            $table->foreignId('bank_account_id')->nullable()->after('fully_paid')->constrained('bank_accounts')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->dropForeign(['bank_account_id']);
            $table->dropColumn([
                'additional_charges',
                'round_off',
                'auto_round_off',
                'fully_paid',
                'bank_account_id',
            ]);
        });
    }
};
