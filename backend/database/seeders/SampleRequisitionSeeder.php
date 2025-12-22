<?php

namespace Database\Seeders;

use App\Models\Requisition;
use App\Models\DeliveryChallan;
use App\Models\Payment;
use App\Models\User;
use App\Models\BrickType;
use App\Models\Role;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class SampleRequisitionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get sales executives
        $salesRole = Role::where('name', 'Sales Executive')->first();
        $salesUsers = User::where('role_id', $salesRole->id)->where('status', 'active')->get();
        
        // Get active brick types
        $brickTypes = BrickType::where('status', 'active')->get();

        if ($salesUsers->isEmpty() || $brickTypes->isEmpty()) {
            $this->command->error('Sales users or brick types not found. Please run previous seeders first.');
            return;
        }

        // Sample customer data
        $customers = [
            [
                'name' => 'ABC Construction Ltd',
                'phone' => '+91-9876543210',
                'address' => '123 Industrial Area, Sector 15',
                'location' => 'Gurgaon, Haryana'
            ],
            [
                'name' => 'XYZ Builders Pvt Ltd',
                'phone' => '+91-9876543211',
                'address' => '456 Commercial Complex, Phase 2',
                'location' => 'Noida, UP'
            ],
            [
                'name' => 'Modern Homes Construction',
                'phone' => '+91-9876543212',
                'address' => '789 Residential Plot, Block A',
                'location' => 'Faridabad, Haryana'
            ],
            [
                'name' => 'Elite Infrastructure',
                'phone' => '+91-9876543213',
                'address' => '321 Business Park, Tower B',
                'location' => 'Delhi, NCR'
            ],
            [
                'name' => 'Green Valley Developers',
                'phone' => '+91-9876543214',
                'address' => '654 Green Avenue, Sector 22',
                'location' => 'Ghaziabad, UP'
            ],
        ];

        $requisitions = [];
        
        // Get the highest existing order number to avoid duplicates
        $lastRequisition = Requisition::orderBy('order_number', 'desc')->first();
        $orderNumber = $lastRequisition ? 
            (int) substr($lastRequisition->order_number, 4) + 1 : 1001;

        // Create requisitions with different statuses
        for ($i = 0; $i < 15; $i++) {
            $customer = $customers[$i % count($customers)];
            $salesUser = $salesUsers->random();
            $brickType = $brickTypes->random();
            $quantity = rand(100, 1000);
            $pricePerUnit = $brickType->current_price;
            $totalAmount = $quantity * $pricePerUnit;

            // Determine status based on index for variety
            $status = match($i % 5) {
                0 => Requisition::STATUS_SUBMITTED,
                1 => Requisition::STATUS_ASSIGNED,
                2 => Requisition::STATUS_DELIVERED,
                3 => Requisition::STATUS_PAID,
                4 => Requisition::STATUS_COMPLETE,
            };

            $requisition = Requisition::create([
                'order_number' => 'ORD-' . str_pad($orderNumber++, 6, '0', STR_PAD_LEFT),
                'date' => Carbon::now()->subDays(rand(1, 30)),
                'user_id' => $salesUser->id,
                'brick_type_id' => $brickType->id,
                'quantity' => $quantity,
                'price_per_unit' => $pricePerUnit,
                'entered_price' => $pricePerUnit, // Add the entered_price field
                'total_amount' => $totalAmount,
                'customer_name' => $customer['name'],
                'customer_phone' => $customer['phone'],
                'customer_address' => $customer['address'],
                'customer_location' => $customer['location'],
                'status' => $status,
            ]);

            $requisitions[] = $requisition;

            // Create delivery challan for requisitions that are assigned or beyond
            if (in_array($status, [
                Requisition::STATUS_ASSIGNED,
                Requisition::STATUS_DELIVERED,
                Requisition::STATUS_PAID,
                Requisition::STATUS_COMPLETE
            ])) {
                // Get the highest existing challan number to avoid duplicates
                $lastChallan = DeliveryChallan::orderBy('challan_number', 'desc')->first();
                $challanCounter = $lastChallan ? 
                    (int) substr($lastChallan->challan_number, 3) + 1 : 1;
                $challanNumber = 'CH-' . str_pad($challanCounter, 6, '0', STR_PAD_LEFT);
                
                $deliveryStatus = match($status) {
                    Requisition::STATUS_ASSIGNED => DeliveryChallan::STATUS_ASSIGNED,
                    Requisition::STATUS_DELIVERED => DeliveryChallan::STATUS_DELIVERED,
                    Requisition::STATUS_PAID => DeliveryChallan::STATUS_DELIVERED,
                    Requisition::STATUS_COMPLETE => DeliveryChallan::STATUS_DELIVERED,
                };

                $challan = DeliveryChallan::create([
                    'challan_number' => $challanNumber,
                    'requisition_id' => $requisition->id,
                    'order_number' => $requisition->order_number,
                    'date' => $requisition->date->addDay(),
                    'vehicle_number' => 'HR-' . rand(10, 99) . '-' . chr(rand(65, 90)) . '-' . rand(1000, 9999),
                    'driver_name' => $this->getRandomDriverName(),
                    'vehicle_type' => $this->getRandomVehicleType(),
                    'location' => $customer['location'],
                    'remarks' => $i % 3 == 0 ? 'Handle with care - fragile items' : null,
                    'delivery_status' => $deliveryStatus,
                    'delivery_date' => $deliveryStatus === DeliveryChallan::STATUS_DELIVERED ? 
                        $requisition->date->addDays(2) : null,
                    'print_count' => rand(1, 3),
                ]);

                // Create payment record for some delivered challans (not all)
                if (in_array($status, [
                    Requisition::STATUS_PAID,
                    Requisition::STATUS_COMPLETE
                ])) {
                    $paymentStatus = match($status) {
                        Requisition::STATUS_DELIVERED => 'pending',
                        Requisition::STATUS_PAID => 'paid',
                        Requisition::STATUS_COMPLETE => 'approved',
                    };

                    $amountReceived = $paymentStatus === 'pending' ? 0 : 
                        ($paymentStatus === 'paid' ? $totalAmount * 0.8 : $totalAmount);

                    Payment::create([
                        'delivery_challan_id' => $challan->id,
                        'payment_status' => $paymentStatus,
                        'total_amount' => $totalAmount,
                        'amount_received' => $amountReceived,
                        'payment_date' => $paymentStatus !== 'pending' ? 
                            $challan->delivery_date->addDays(rand(1, 5)) : null,
                        'payment_method' => $this->getRandomPaymentMethod(),
                        'reference_number' => $paymentStatus !== 'pending' ? 
                            'REF-' . rand(100000, 999999) : null,
                        'remarks' => $i % 4 == 0 ? 'Partial payment received' : null,
                        'approved_by' => $paymentStatus === 'approved' ? 
                            User::whereHas('role', fn($q) => $q->where('name', 'Accounts'))->first()?->id : null,
                        'approved_at' => $paymentStatus === 'approved' ? 
                            Carbon::now()->subDays(rand(1, 10)) : null,
                    ]);
                }
            }
        }

        $this->command->info('Sample requisitions, challans, and payments created for testing.');
    }

    /**
     * Get a random driver name for testing.
     */
    private function getRandomDriverName(): string
    {
        $names = [
            'Ramesh Singh',
            'Sunil Kumar',
            'Vijay Sharma',
            'Ravi Patel',
            'Manoj Gupta',
            'Ashok Yadav',
            'Dinesh Verma',
            'Santosh Jha',
        ];

        return $names[array_rand($names)];
    }

    /**
     * Get a random vehicle type for testing.
     */
    private function getRandomVehicleType(): string
    {
        $types = [
            'Truck',
            'Mini Truck',
            'Tempo',
            'Pickup Van',
            'Heavy Truck',
        ];

        return $types[array_rand($types)];
    }

    /**
     * Get a random payment method for testing.
     */
    private function getRandomPaymentMethod(): string
    {
        $methods = [
            'cash',
            'cheque',
            'bank_transfer',
            'upi',
        ];

        return $methods[array_rand($methods)];
    }
}