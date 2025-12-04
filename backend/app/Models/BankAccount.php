<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BankAccount extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'organization_id',
        'account_name',
        'opening_balance',
        'as_of_date',
        'bank_account_no',
        'ifsc_code',
        'account_holder_name',
        'upi_id',
        'bank_name',
        'branch_name',
        'current_balance',
        'account_type',
    ];

    protected $casts = [
        'opening_balance' => 'decimal:2',
        'current_balance' => 'decimal:2',
        'as_of_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function transactions()
    {
        return $this->hasMany(BankTransaction::class, 'account_id');
    }
}
