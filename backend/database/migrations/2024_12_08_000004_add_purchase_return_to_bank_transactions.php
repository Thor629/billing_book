<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Add 'purchase_return' to the transaction_type ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out', 'sales_return', 'purchase_return') NOT NULL");
        
        // Add payment fields to purchase_returns table
        Schema::table('purchase_returns', function (Blueprint $table) {
            if (!Schema::hasColumn('purchase_returns', 'payment_mode')) {
                $table->string('payment_mode', 50)->nullable()->after('total_amount');
            }
            if (!Schema::hasColumn('purchase_returns', 'bank_account_id')) {
                $table->foreignId('bank_account_id')->nullable()->after('payment_mode')->constrained()->onDelete('set null');
            }
            if (!Schema::hasColumn('purchase_returns', 'amount_received')) {
                $table->decimal('amount_received', 15, 2)->default(0)->after('bank_account_id');
            }
        });
    }

    public function down(): void
    {
        // Revert transaction_type ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out', 'sales_return') NOT NULL");
        
        // Remove payment fields from purchase_returns
        Schema::table('purchase_returns', function (Blueprint $table) {
            if (Schema::hasColumn('purchase_returns', 'amount_received')) {
                $table->dropColumn('amount_received');
            }
            if (Schema::hasColumn('purchase_returns', 'bank_account_id')) {
                $table->dropForeign(['bank_account_id']);
                $table->dropColumn('bank_account_id');
            }
            if (Schema::hasColumn('purchase_returns', 'payment_mode')) {
                $table->dropColumn('payment_mode');
            }
        });
    }
};
