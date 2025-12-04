<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DebitNoteItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'debit_note_id',
        'item_id',
        'description',
        'quantity',
        'unit',
        'rate',
        'tax_rate',
        'amount',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'rate' => 'decimal:2',
        'tax_rate' => 'decimal:2',
        'amount' => 'decimal:2',
    ];

    public function debitNote()
    {
        return $this->belongsTo(DebitNote::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}
