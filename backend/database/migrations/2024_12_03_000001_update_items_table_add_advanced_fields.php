<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('items', function (Blueprint $table) {
            // Pricing fields
            $table->boolean('selling_price_with_tax')->default(false)->after('selling_price');
            $table->boolean('purchase_price_with_tax')->default(false)->after('purchase_price');
            
            // Stock fields
            $table->decimal('opening_stock', 10, 2)->default(0)->after('stock_qty');
            $table->date('opening_stock_date')->nullable()->after('opening_stock');
            $table->string('alternative_unit')->nullable()->after('unit');
            $table->decimal('alternative_unit_conversion', 10, 4)->nullable()->after('alternative_unit');
            $table->boolean('enable_low_stock_warning')->default(false)->after('low_stock_alert');
            
            // Barcode
            $table->string('barcode')->nullable()->after('item_code');
            
            // Image
            $table->string('image_url')->nullable()->after('description');
        });
    }

    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropColumn([
                'selling_price_with_tax',
                'purchase_price_with_tax',
                'opening_stock',
                'opening_stock_date',
                'alternative_unit',
                'alternative_unit_conversion',
                'enable_low_stock_warning',
                'barcode',
                'image_url'
            ]);
        });
    }
};
