<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Party extends Model
{
    use HasFactory;

    protected $fillable = [
        'organization_id',
        'name',
        'contact_person',
        'email',
        'phone',
        'gst_no',
        'billing_address',
        'shipping_address',
        'party_type',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    /**
     * Get the organization that owns the party.
     */
    public function organization()
    {
        return $this->belongsTo(Organization::class);
    }
}
