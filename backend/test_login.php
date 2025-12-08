<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "=== Testing Login System ===\n\n";

// Check if users exist
$users = User::all();
echo "Total users in database: " . $users->count() . "\n\n";

if ($users->count() > 0) {
    echo "Existing users:\n";
    foreach ($users as $user) {
        echo "- ID: {$user->id}, Name: {$user->name}, Email: {$user->email}, Role: {$user->role}\n";
    }
    echo "\n";
} else {
    echo "No users found in database!\n";
    echo "Creating a test user...\n\n";
    
    $user = User::create([
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => Hash::make('password'),
        'role' => 'user',
    ]);
    
    echo "Test user created:\n";
    echo "Email: test@example.com\n";
    echo "Password: password\n\n";
}

// Test password verification
echo "=== Testing Password Verification ===\n";
$testEmail = 'test@example.com';
$testPassword = 'password';

$user = User::where('email', $testEmail)->first();
if ($user) {
    echo "User found: {$user->email}\n";
    
    if (Hash::check($testPassword, $user->password)) {
        echo "✓ Password verification: SUCCESS\n";
    } else {
        echo "✗ Password verification: FAILED\n";
        echo "The password in database might be incorrect.\n";
    }
} else {
    echo "User with email {$testEmail} not found.\n";
}

echo "\n=== Test Complete ===\n";
