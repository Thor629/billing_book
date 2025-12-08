<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // For MySQL, we need to use raw SQL to modify ENUM
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in', 'expense', 'payment_in', 'payment_out') NOT NULL");
    }

    public function down(): void
    {
        // Revert back to original ENUM values
        DB::statement("ALTER TABLE bank_transactions MODIFY COLUMN transaction_type ENUM('add', 'reduce', 'transfer_out', 'transfer_in') NOT NULL");
    }
};
