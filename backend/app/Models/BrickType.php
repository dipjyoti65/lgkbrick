<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BrickType extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'description',
        'current_price',
        'unit',
        'category',
        'status',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'current_price' => 'decimal:2',
        'status' => 'string',
    ];

    /**
     * Get the requisitions for the brick type.
     */
    public function requisitions(): HasMany
    {
        return $this->hasMany(Requisition::class);
    }

    /**
     * Scope a query to only include active brick types.
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    /**
     * Scope a query to only include inactive brick types.
     */
    public function scopeInactive($query)
    {
        return $query->where('status', 'inactive');
    }
}
