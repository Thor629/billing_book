<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    use HasFactory;

    protected $fillable = [
        'organization_id',
        'item_name',
        'item_code',
        'barcode',
        'selling_price',
        'selling_price_with_tax',
        'purchase_price',
        'purchase_price_with_tax',
        'mrp',
        'stock_qty',
        'opening_stock',
        'opening_stock_date',
        'unit',
        'alternative_unit',
        'alternative_unit_conversion',
        'low_stock_alert',
        'enable_low_stock_warning',
        'category',
        'description',
        'hsn_code',
        'gst_rate',
        'image_url',
        'is_active',
    ];

    protected $casts = [
        'selling_price' => 'decimal:2',
        'purchase_price' => 'decimal:2',
        'mrp' => 'decimal:2',
        'opening_stock' => 'decimal:2',
        'alternative_unit_conversion' => 'decimal:4',
        'gst_rate' => 'decimal:2',
        'stock_qty' => 'integer',
        'low_stock_alert' => 'integer',
        'selling_price_with_tax' => 'boolean',
        'purchase_price_with_tax' => 'boolean',
        'enable_low_stock_warning' => 'boolean',
        'is_active' => 'boolean',
        'opening_stock_date' => 'date',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function godowns()
    {
        return $this->belongsToMany(Godown::class, 'item_godown_stock')
            ->withPivot('quantity')
            ->withTimestamps();
    }

    public function partyPrices()
    {
        return $this->hasMany(ItemPartyPrice::class);
    }

    public function customFields()
    {
        return $this->hasMany(ItemCustomField::class);
    }

    public function isLowStock(): bool
    {
        return $this->stock_qty <= $this->low_stock_alert;
    }
}
