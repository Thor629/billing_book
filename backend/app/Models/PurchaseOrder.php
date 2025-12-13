<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PurchaseOrder extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'party_id',
        'order_number',
        'order_date',
        'expected_delivery_date',
        'subtotal',
        'tax_amount',
        'discount_amount',
        'additional_charges',
        'round_off',
        'auto_round_off',
        'total_amount',
        'fully_paid',
        'bank_account_id',
        'status',
        'notes',
        'terms',
    ];

    protected $casts = [
        'order_date' => 'date',
        'expected_delivery_date' => 'date',
        'subtotal' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'additional_charges' => 'decimal:2',
        'round_off' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'auto_round_off' => 'boolean',
        'fully_paid' => 'boolean',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }

    public function items()
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }
}
