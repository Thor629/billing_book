<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ItemCustomField extends Model
{
    use HasFactory;

    protected $fillable = [
        'item_id',
        'field_name',
        'field_value',
        'field_type',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}
