<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Http\Kernel');

use Illuminate\Http\Request;

echo "=== Testing Delivery Challan API ===\n\n";

// Create a test request
$request = Request::create(
    '/api/delivery-challans',
    'POST',
    [
        'organization_id' => 1,
        'party_id' => 1,
        'challan_number' => 'TEST-001',
        'challan_date' => date('Y-m-d'),
        'subtotal' => 1000,
        'tax_amount' => 180,
        'total_amount' => 1180,
        'notes' => 'Test challan',
        'terms_conditions' => 'Test terms',
        'items' => [
            [
                'item_id' => 1,
                'item_name' => 'Test Item',
                'hsn_sac' => '1234',
                'quantity' => 1,
                'price' => 1000,
                'discount_percent' => 0,
                'tax_percent' => 18,
                'amount' => 1000,
            ]
        ]
    ]
);

// Add authentication header (you'll need a valid token)
// $request->headers->set('Authorization', 'Bearer YOUR_TOKEN_HERE');

try {
    $response = $kernel->handle($request);
    
    echo "Status Code: " . $response->getStatusCode() . "\n";
    echo "Response Body:\n";
    echo $response->getContent() . "\n";
    
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}

echo "\n=== Test Complete ===\n";
