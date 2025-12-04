<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BankTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'organization_id',
        'account_id',
        'transaction_type',
        'amount',
        'transaction_date',
        'description',
        'related_account_id',
        'related_transaction_id',
        'is_external_transfer',
        'external_account_holder',
        'external_account_number',
        'external_bank_name',
        'external_ifsc_code',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'transaction_date' => 'date',
        'is_external_transfer' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function account()
    {
        return $this->belongsTo(BankAccount::class, 'account_id');
    }

    public function relatedAccount()
    {
        return $this->belongsTo(BankAccount::class, 'related_account_id');
    }

    public function relatedTransaction()
    {
        return $this->belongsTo(BankTransaction::class, 'related_transaction_id');
    }
}
