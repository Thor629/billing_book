<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('item_party_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('item_id')->constrained()->onDelete('cascade');
            $table->foreignId('party_id')->constrained()->onDelete('cascade');
            $table->decimal('selling_price', 10, 2);
            $table->decimal('purchase_price', 10, 2)->nullable();
            $table->boolean('price_with_tax')->default(false);
            $table->timestamps();
            
            $table->unique(['item_id', 'party_id']);
            $table->index('item_id');
            $table->index('party_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('item_party_prices');
    }
};
