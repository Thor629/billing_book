<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Update all items where stock_qty is 0 but opening_stock is greater than 0
        // This fixes items that were created with opening stock but stock_qty wasn't set
        DB::statement('UPDATE items SET stock_qty = CAST(opening_stock AS INTEGER) WHERE stock_qty = 0 AND opening_stock > 0');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No need to reverse this data fix
    }
};
