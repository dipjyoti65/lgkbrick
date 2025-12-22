<?php

namespace Database\Seeders;

use App\Models\BrickType;
use Illuminate\Database\Seeder;

class BrickTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $brickTypes = [
            [
                'name' => 'Standard Red Brick',
                'description' => 'High-quality standard red clay brick for construction',
                'current_price' => 8.50,
                'unit' => 'piece',
                'category' => 'Standard',
                'status' => 'active',
            ],
            [
                'name' => 'Fly Ash Brick',
                'description' => 'Eco-friendly fly ash brick with superior strength',
                'current_price' => 12.00,
                'unit' => 'piece',
                'category' => 'Eco-Friendly',
                'status' => 'active',
            ],
            [
                'name' => 'Concrete Block',
                'description' => 'Heavy-duty concrete block for structural applications',
                'current_price' => 25.00,
                'unit' => 'piece',
                'category' => 'Structural',
                'status' => 'active',
            ],
            [
                'name' => 'Perforated Brick',
                'description' => 'Lightweight perforated brick for thermal insulation',
                'current_price' => 15.75,
                'unit' => 'piece',
                'category' => 'Insulation',
                'status' => 'active',
            ],
            [
                'name' => 'Fire Brick',
                'description' => 'Heat-resistant fire brick for furnace applications',
                'current_price' => 35.00,
                'unit' => 'piece',
                'category' => 'Specialty',
                'status' => 'active',
            ],
            [
                'name' => 'Hollow Brick',
                'description' => 'Lightweight hollow brick for partition walls',
                'current_price' => 18.25,
                'unit' => 'piece',
                'category' => 'Partition',
                'status' => 'active',
            ],
            [
                'name' => 'Old Clay Brick',
                'description' => 'Discontinued old clay brick model',
                'current_price' => 6.00,
                'unit' => 'piece',
                'category' => 'Standard',
                'status' => 'inactive',
            ],
        ];

        foreach ($brickTypes as $brickTypeData) {
            BrickType::firstOrCreate(
                ['name' => $brickTypeData['name']],
                $brickTypeData
            );
        }
    }
}