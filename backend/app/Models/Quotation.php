<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Quotation extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'party_id',
        'user_id',
        'quotation_number',
        'quotation_date',
        'valid_for',
        'validity_date',
        'subtotal',
        'discount_amount',
        'tax_amount',
        'additional_charges',
        'round_off',
        'total_amount',
        'status',
        'notes',
        'terms_conditions',
        'bank_details',
        'show_bank_details',
        'auto_round_off',
    ];

    protected $casts = [
        'quotation_date' => 'date',
        'validity_date' => 'date',
        'subtotal' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'additional_charges' => 'decimal:2',
        'round_off' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'show_bank_details' => 'boolean',
        'auto_round_off' => 'boolean',
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

    public function items()
    {
        return $this->hasMany(QuotationItem::class);
    }

    public function getDueInAttribute()
    {
        if ($this->status === 'expired' || $this->status === 'converted') {
            return '-';
        }
        
        $today = now()->startOfDay();
        $validityDate = $this->validity_date->startOfDay();
        
        if ($today->greaterThan($validityDate)) {
            return 'Expired';
        }
        
        $days = $validityDate->diffInDays($today);
        return "{$days} Days";
    }

    public function getIsExpiredAttribute()
    {
        return now()->startOfDay()->greaterThan($this->validity_date->startOfDay());
    }
}
