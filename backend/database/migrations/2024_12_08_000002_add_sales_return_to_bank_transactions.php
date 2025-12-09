<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Add 'sales_return' to the transaction_type ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out', 'sales_return') NOT NULL");
    }

    public function down(): void
    {
        // Revert back to previous ENUM values
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out') NOT NULL");
    }
};
