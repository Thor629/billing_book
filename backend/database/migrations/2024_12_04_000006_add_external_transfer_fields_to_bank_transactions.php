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
        Schema::table('bank_transactions', function (Blueprint $table) {
            $table->boolean('is_external_transfer')->default(false)->after('related_transaction_id');
            $table->string('external_account_holder', 255)->nullable()->after('is_external_transfer');
            $table->string('external_account_number', 50)->nullable()->after('external_account_holder');
            $table->string('external_bank_name', 255)->nullable()->after('external_account_number');
            $table->string('external_ifsc_code', 11)->nullable()->after('external_bank_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bank_transactions', function (Blueprint $table) {
            $table->dropColumn([
                'is_external_transfer',
                'external_account_holder',
                'external_account_number',
                'external_bank_name',
                'external_ifsc_code',
            ]);
        });
    }
};
