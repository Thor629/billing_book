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
        // E-Invoice fields
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
        // E-Invoice casts
        'ack_date' => 'datetime',
        'way_bill_date' => 'datetime',
        'is_einvoice_generated' => 'boolean',
        'is_reconciled' => 'boolean',
        'reconciled_at' => 'datetime',
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

    public function getIsDraftAttribute()
    {
        return $this->invoice_status === 'draft';
    }

    public function getIsFinalAttribute()
    {
        return $this->invoice_status === 'final';
    }

    public function getIsEditableAttribute()
    {
        return $this->is_draft && !$this->is_einvoice_generated;
    }

    public function getHasIrnAttribute()
    {
        return !empty($this->irn);
    }

    public function getHasWayBillAttribute()
    {
        return !empty($this->way_bill_no);
    }
}
