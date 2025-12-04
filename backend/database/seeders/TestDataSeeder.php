<?php

namespace Database\Seeders;

use App\Models\Organization;
use App\Models\Party;
use App\Models\Item;
use Illuminate\Database\Seeder;

class TestDataSeeder extends Seeder
{
    public function run(): void
    {
        // Get first organization
        $org = Organization::first();
        
        if (!$org) {
            $this->command->error('No organization found. Please create an organization first.');
            return;
        }

        $this->command->info("Creating test data for organization: {$org->name}");

        // Create Vendors (Parties)
        $vendors = [
            [
                'organization_id' => $org->id,
                'name' => 'ABC Suppliers Ltd',
                'contact_person' => 'John Smith',
                'email' => 'john@abcsuppliers.com',
                'phone' => '+1-555-0101',
                'gst_no' => 'GST123456',
                'billing_address' => '123 Main St, New York, NY 10001',
                'shipping_address' => '123 Main St, New York, NY 10001',
                'party_type' => 'vendor',
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'name' => 'XYZ Trading Co',
                'contact_person' => 'Jane Doe',
                'email' => 'jane@xyztrading.com',
                'phone' => '+1-555-0102',
                'gst_no' => 'GST789012',
                'billing_address' => '456 Oak Ave, Los Angeles, CA 90001',
                'shipping_address' => '456 Oak Ave, Los Angeles, CA 90001',
                'party_type' => 'vendor',
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'name' => 'Global Imports Inc',
                'contact_person' => 'Mike Johnson',
                'email' => 'mike@globalimports.com',
                'phone' => '+1-555-0103',
                'gst_no' => 'GST345678',
                'billing_address' => '789 Pine Rd, Chicago, IL 60601',
                'shipping_address' => '789 Pine Rd, Chicago, IL 60601',
                'party_type' => 'vendor',
                'is_active' => true,
            ],
        ];

        foreach ($vendors as $vendorData) {
            Party::create($vendorData);
        }

        $this->command->info('Created 3 vendors');

        // Create Items
        $items = [
            [
                'organization_id' => $org->id,
                'item_name' => 'Laptop - Dell XPS 15',
                'item_code' => 'DELL-XPS-15',
                'description' => 'High-performance laptop with 16GB RAM',
                'unit' => 'PCS',
                'purchase_price' => 1200.00,
                'selling_price' => 1500.00,
                'mrp' => 1600.00,
                'gst_rate' => 18.00,
                'stock_qty' => 50,
                'low_stock_alert' => 10,
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'item_name' => 'Wireless Mouse',
                'item_code' => 'MOUSE-WL-001',
                'description' => 'Ergonomic wireless mouse',
                'unit' => 'PCS',
                'purchase_price' => 15.00,
                'selling_price' => 25.00,
                'mrp' => 30.00,
                'gst_rate' => 18.00,
                'stock_qty' => 200,
                'low_stock_alert' => 50,
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'item_name' => 'USB-C Cable',
                'item_code' => 'CABLE-USBC-001',
                'description' => '2m USB-C charging cable',
                'unit' => 'PCS',
                'purchase_price' => 5.00,
                'selling_price' => 10.00,
                'mrp' => 12.00,
                'gst_rate' => 18.00,
                'stock_qty' => 500,
                'low_stock_alert' => 100,
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'item_name' => 'Office Chair',
                'item_code' => 'CHAIR-OFF-001',
                'description' => 'Ergonomic office chair with lumbar support',
                'unit' => 'PCS',
                'purchase_price' => 150.00,
                'selling_price' => 250.00,
                'mrp' => 300.00,
                'gst_rate' => 18.00,
                'stock_qty' => 30,
                'low_stock_alert' => 5,
                'is_active' => true,
            ],
            [
                'organization_id' => $org->id,
                'item_name' => 'Monitor - 27" 4K',
                'item_code' => 'MON-27-4K',
                'description' => '27-inch 4K UHD monitor',
                'unit' => 'PCS',
                'purchase_price' => 300.00,
                'selling_price' => 450.00,
                'mrp' => 500.00,
                'gst_rate' => 18.00,
                'stock_qty' => 25,
                'low_stock_alert' => 5,
                'is_active' => true,
            ],
        ];

        foreach ($items as $itemData) {
            Item::create($itemData);
        }

        $this->command->info('Created 5 items');
        $this->command->info('Test data seeding completed successfully!');
        $this->command->info('You can now create purchase invoices with these vendors and items.');
    }
}
