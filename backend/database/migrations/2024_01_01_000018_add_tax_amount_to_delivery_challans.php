<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('delivery_challans', function (Blueprint $table) {
            if (!Schema::hasColumn('delivery_challans', 'tax_amount')) {
                $table->decimal('tax_amount', 15, 2)->default(0)->after('subtotal');
            }
        });
    }

    public function down(): void
    {
        Schema::table('delivery_challans', function (Blueprint $table) {
            if (Schema::hasColumn('delivery_challans', 'tax_amount')) {
                $table->dropColumn('tax_amount');
            }
        });
    }
};
