<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('item_custom_fields', function (Blueprint $table) {
            $table->id();
            $table->foreignId('item_id')->constrained()->onDelete('cascade');
            $table->string('field_name');
            $table->text('field_value')->nullable();
            $table->string('field_type')->default('text'); // text, number, date, dropdown
            $table->timestamps();
            
            $table->index('item_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('item_custom_fields');
    }
};
