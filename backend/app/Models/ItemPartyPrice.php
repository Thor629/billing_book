<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ItemPartyPrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'item_id',
        'party_id',
        'selling_price',
        'purchase_price',
        'price_with_tax',
    ];

    protected $casts = [
        'selling_price' => 'decimal:2',
        'purchase_price' => 'decimal:2',
        'price_with_tax' => 'boolean',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }
}
