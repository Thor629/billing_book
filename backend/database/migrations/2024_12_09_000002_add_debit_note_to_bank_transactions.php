<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Add 'debit_note' to the transaction_type ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out', 'sales_return', 'purchase_return', 'credit_note', 'debit_note') NOT NULL");
        
        // Add payment fields to debit_notes table
        Schema::table('debit_notes', function (Blueprint $table) {
            if (!Schema::hasColumn('debit_notes', 'payment_mode')) {
                $table->string('payment_mode', 50)->nullable()->after('total_amount');
            }
            if (!Schema::hasColumn('debit_notes', 'bank_account_id')) {
                $table->foreignId('bank_account_id')->nullable()->after('payment_mode')->constrained()->onDelete('set null');
            }
            if (!Schema::hasColumn('debit_notes', 'amount_paid')) {
                $table->decimal('amount_paid', 15, 2)->default(0)->after('bank_account_id');
            }
        });
    }

    public function down(): void
    {
        // Revert transaction_type ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out', 'sales_return', 'purchase_return', 'credit_note') NOT NULL");
        
        // Remove payment fields from debit_notes
        Schema::table('debit_notes', function (Blueprint $table) {
            if (Schema::hasColumn('debit_notes', 'amount_paid')) {
                $table->dropColumn('amount_paid');
            }
            if (Schema::hasColumn('debit_notes', 'bank_account_id')) {
                $table->dropForeign(['bank_account_id']);
                $table->dropColumn('bank_account_id');
            }
            if (Schema::hasColumn('debit_notes', 'payment_mode')) {
                $table->dropColumn('payment_mode');
            }
        });
    }
};
