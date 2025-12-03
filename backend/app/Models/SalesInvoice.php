<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SalesInvoice extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'organization_id',
        'party_id',
        'user_id',
        'invoice_prefix',
        'invoice_number',
        'invoice_date',
        'payment_terms',
        'due_date',
        'subtotal',
        'discount_amount',
        'tax_amount',
        'additional_charges',
        'round_off',
        'total_amount',
        'amount_received',
        'balance_amount',
        'payment_mode',
        'payment_status',
        'notes',
        'terms_conditions',
        'bank_details',
        'show_bank_details',
        'auto_round_off',
    ];

    protected $casts = [
        'invoice_date' => 'date',
        'due_date' => 'date',
        'subtotal' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'additional_charges' => 'decimal:2',
        'round_off' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'amount_received' => 'decimal:2',
        'balance_amount' => 'decimal:2',
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
        return $this->hasMany(SalesInvoiceItem::class);
    }

    public function getFullInvoiceNumberAttribute()
    {
        return $this->invoice_prefix . $this->invoice_number;
    }

    public function getDaysOverdueAttribute()
    {
        if ($this->payment_status === 'paid') {
            return 0;
        }
        
        $today = now()->startOfDay();
        $dueDate = $this->due_date->startOfDay();
        
        if ($today->greaterThan($dueDate)) {
            return $today->diffInDays($dueDate);
        }
        
        return 0;
    }

    public function getDueInAttribute()
    {
        if ($this->payment_status === 'paid') {
            return '-';
        }
        
        $today = now()->startOfDay();
        $dueDate = $this->due_date->startOfDay();
        
        if ($today->greaterThan($dueDate)) {
            $days = $today->diffInDays($dueDate);
            return "Overdue by {$days} days";
        }
        
        $days = $dueDate->diffInDays($today);
        return "{$days} Days";
    }
}
