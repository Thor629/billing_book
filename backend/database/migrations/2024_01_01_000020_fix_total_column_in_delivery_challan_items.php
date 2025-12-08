<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Make the 'total' column nullable or set a default value
        DB::statement('ALTER TABLE `delivery_challan_items` MODIFY `total` DECIMAL(15,2) NULL DEFAULT 0');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE `delivery_challan_items` MODIFY `total` DECIMAL(15,2) NOT NULL');
    }
};
