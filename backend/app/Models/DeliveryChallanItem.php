<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeliveryChallanItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'delivery_challan_id',
        'item_id',
        'item_name',
        'hsn_sac',
        'quantity',
        'price',
        'discount_percent',
        'tax_percent',
        'amount',
    ];

    protected $casts = [
        'quantity' => 'decimal:2',
        'price' => 'decimal:2',
        'discount_percent' => 'decimal:2',
        'tax_percent' => 'decimal:2',
        'amount' => 'decimal:2',
    ];

    public function deliveryChallan()
    {
        return $this->belongsTo(DeliveryChallan::class);
    }

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}
