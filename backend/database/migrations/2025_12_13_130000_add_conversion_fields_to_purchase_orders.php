<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->boolean('converted_to_invoice')->default(false)->after('status');
            $table->unsignedBigInteger('purchase_invoice_id')->nullable()->after('converted_to_invoice');
            $table->timestamp('converted_at')->nullable()->after('purchase_invoice_id');
            
            // Foreign key to purchase_invoices table
            $table->foreign('purchase_invoice_id')
                  ->references('id')
                  ->on('purchase_invoices')
                  ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->dropForeign(['purchase_invoice_id']);
            $table->dropColumn(['converted_to_invoice', 'purchase_invoice_id', 'converted_at']);
        });
    }
};
