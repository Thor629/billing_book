<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('delivery_challan_items', function (Blueprint $table) {
            if (!Schema::hasColumn('delivery_challan_items', 'item_name')) {
                $table->string('item_name')->after('item_id');
            }
            if (!Schema::hasColumn('delivery_challan_items', 'hsn_sac')) {
                $table->string('hsn_sac')->nullable()->after('item_name');
            }
            if (!Schema::hasColumn('delivery_challan_items', 'discount_percent')) {
                $table->decimal('discount_percent', 5, 2)->default(0)->after('price');
            }
            if (!Schema::hasColumn('delivery_challan_items', 'tax_percent')) {
                $table->decimal('tax_percent', 5, 2)->default(0)->after('discount_percent');
            }
            if (!Schema::hasColumn('delivery_challan_items', 'amount')) {
                $table->decimal('amount', 15, 2)->after('tax_percent');
            }
        });
    }

    public function down(): void
    {
        Schema::table('delivery_challan_items', function (Blueprint $table) {
            $columns = ['item_name', 'hsn_sac', 'discount_percent', 'tax_percent', 'amount'];
            foreach ($columns as $column) {
                if (Schema::hasColumn('delivery_challan_items', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
