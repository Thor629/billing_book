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
        Schema::table('sales_invoices', function (Blueprint $table) {
            // E-Invoice fields
            $table->string('irn', 64)->nullable()->after('updated_at');
            $table->string('ack_no', 20)->nullable()->after('irn');
            $table->timestamp('ack_date')->nullable()->after('ack_no');
            $table->text('qr_code_data')->nullable()->after('ack_date');
            $table->text('qr_code_image')->nullable()->after('qr_code_data');
            $table->text('signed_invoice')->nullable()->after('qr_code_image');
            
            // Way Bill fields
            $table->string('way_bill_no', 20)->nullable()->after('signed_invoice');
            $table->timestamp('way_bill_date')->nullable()->after('way_bill_no');
            
            // Status and reconciliation fields
            $table->string('invoice_status', 20)->default('draft')->after('way_bill_date');
            $table->boolean('is_einvoice_generated')->default(false)->after('invoice_status');
            $table->boolean('is_reconciled')->default(false)->after('is_einvoice_generated');
            $table->timestamp('reconciled_at')->nullable()->after('is_reconciled');
            
            // Indexes for performance
            $table->index('irn');
            $table->index('invoice_status');
            $table->index('is_einvoice_generated');
            $table->index('is_reconciled');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sales_invoices', function (Blueprint $table) {
            $table->dropIndex(['irn']);
            $table->dropIndex(['invoice_status']);
            $table->dropIndex(['is_einvoice_generated']);
            $table->dropIndex(['is_reconciled']);
            
            $table->dropColumn([
                'irn',
                'ack_no',
                'ack_date',
                'qr_code_data',
                'qr_code_image',
                'signed_invoice',
                'way_bill_no',
                'way_bill_date',
                'invoice_status',
                'is_einvoice_generated',
                'is_reconciled',
                'reconciled_at',
            ]);
        });
    }
};

