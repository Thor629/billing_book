<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('organization_id')->constrained()->onDelete('cascade');
            $table->string('item_name');
            $table->string('item_code')->unique();
            $table->decimal('selling_price', 10, 2)->default(0);
            $table->decimal('purchase_price', 10, 2)->default(0);
            $table->decimal('mrp', 10, 2)->default(0);
            $table->integer('stock_qty')->default(0);
            $table->string('unit')->default('PCS'); // PCS, KG, LITER, etc
            $table->integer('low_stock_alert')->default(10);
            $table->string('category')->nullable();
            $table->text('description')->nullable();
            $table->string('hsn_code')->nullable();
            $table->decimal('gst_rate', 5, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('organization_id');
            $table->index('item_code');
            $table->index('category');
            $table->index('is_active');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};
