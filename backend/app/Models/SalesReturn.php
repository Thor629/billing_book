<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SalesReturn extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'party_id',
        'user_id',
        'sales_invoice_id',
        'return_number',
        'return_date',
        'invoice_number',
        'subtotal',
        'discount',
        'tax',
        'total_amount',
        'amount_paid',
        'payment_mode',
        'bank_account_id',
        'status',
        'notes',
        'terms_conditions',
    ];

    protected $casts = [
        'return_date' => 'date',
        'subtotal' => 'decimal:2',
        'discount' => 'decimal:2',
        'tax' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'amount_paid' => 'decimal:2',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function salesInvoice()
    {
        return $this->belongsTo(SalesInvoice::class);
    }

    public function items()
    {
        return $this->hasMany(SalesReturnItem::class);
    }

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }
}
