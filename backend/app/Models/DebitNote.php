<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DebitNote extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'party_id',
        'purchase_invoice_id',
        'debit_note_number',
        'debit_note_date',
        'subtotal',
        'tax_amount',
        'total_amount',
        'payment_mode',
        'bank_account_id',
        'amount_paid',
        'status',
        'reason',
        'notes',
    ];

    protected $casts = [
        'debit_note_date' => 'date',
        'subtotal' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }

    public function purchaseInvoice()
    {
        return $this->belongsTo(PurchaseInvoice::class);
    }

    public function items()
    {
        return $this->hasMany(DebitNoteItem::class);
    }

    public function bankAccount()
    {
        return $this->belongsTo(BankAccount::class);
    }
}
