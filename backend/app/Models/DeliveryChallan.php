<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeliveryChallan extends Model
{
    use HasFactory;

    protected $fillable = [
        'organization_id',
        'user_id',
        'party_id',
        'challan_number',
        'challan_date',
        'subtotal',
        'tax_amount',
        'total_amount',
        'notes',
        'terms_conditions',
    ];

    protected $casts = [
        'challan_date' => 'date',
        'subtotal' => 'decimal:2',
        'tax_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
    ];

    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function party()
    {
        return $this->belongsTo(Party::class);
    }

    public function items()
    {
        return $this->hasMany(DeliveryChallanItem::class);
    }
}
