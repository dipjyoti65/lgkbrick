<?php

namespace Database\Seeders;

use App\Models\BrickType;
use App\Models\Requisition;
use App\Models\DeliveryChallan;
use App\Models\Payment;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UpdatedBrickTypesSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Clear existing data (but keep users)
        $this->clearExistingData();
        
        // Insert new brick types
        $this->insertNewBrickTypes();
    }

    /**
     * Clear existing requisitions, delivery challans, payments, and brick types
     */
    private function clearExistingData(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        
        // Clear in order of dependencies
        Payment::truncate();
        DeliveryChallan::truncate();
        Requisition::truncate();
        BrickType::truncate();
        
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');
        
        $this->command->info('Cleared existing requisitions, delivery challans, payments, and brick types');
    }

    /**
     * Insert the new brick types
     */
    private function insertNewBrickTypes(): void
    {
        $brickTypes = [
            [
                'name' => '1.0 S',
                'description' => '1.0 Standard brick',
                'current_price' => 8.50,
                'unit' => 'piece',
                'category' => 'Standard',
                'status' => 'active',
            ],
            [
                'name' => '1.5 S',
                'description' => '1.5 Standard brick',
                'current_price' => 12.75,
                'unit' => 'piece',
                'category' => 'Standard',
                'status' => 'active',
            ],
            [
                'name' => '1.0 Broken',
                'description' => '1.0 Broken brick',
                'current_price' => 6.25,
                'unit' => 'piece',
                'category' => 'Broken',
                'status' => 'active',
            ],
            [
                'name' => '1.5 Broken',
                'description' => '1.5 Broken brick',
                'current_price' => 9.50,
                'unit' => 'piece',
                'category' => 'Broken',
                'status' => 'active',
            ],
            [
                'name' => 'Jhama',
                'description' => 'Jhama brick',
                'current_price' => 4.75,
                'unit' => 'piece',
                'category' => 'Jhama',
                'status' => 'active',
            ],
            [
                'name' => 'Jhama Broken',
                'description' => 'Jhama Broken brick',
                'current_price' => 3.25,
                'unit' => 'piece',
                'category' => 'Jhama',
                'status' => 'active',
            ],
            [
                'name' => 'Rubbish',
                'description' => 'Rubbish brick',
                'current_price' => 2.00,
                'unit' => 'piece',
                'category' => 'Rubbish',
                'status' => 'active',
            ],
            [
                'name' => 'Boulder',
                'description' => 'Boulder brick',
                'current_price' => 15.00,
                'unit' => 'piece',
                'category' => 'Boulder',
                'status' => 'active',
            ],
        ];

        foreach ($brickTypes as $brickTypeData) {
            BrickType::create($brickTypeData);
        }

        $this->command->info('Created ' . count($brickTypes) . ' new brick types');
    }
}
