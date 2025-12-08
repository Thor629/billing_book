<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

echo "=== Checking User Passwords ===\n\n";

$testPasswords = ['password', 'password123', 'admin123', '123456'];

$users = User::all();

foreach ($users as $user) {
    echo "User: {$user->email}\n";
    echo "Trying passwords: ";
    
    $found = false;
    foreach ($testPasswords as $password) {
        if (Hash::check($password, $user->password)) {
            echo "\n✓ Password is: {$password}\n";
            $found = true;
            break;
        }
    }
    
    if (!$found) {
        echo "\n✗ None of the common passwords work\n";
        echo "Password hash: " . substr($user->password, 0, 30) . "...\n";
    }
    echo "\n";
}

echo "=== Test Complete ===\n";
echo "\nYou can use these credentials to login:\n";
echo "Admin: admin@example.com\n";
echo "User: john@example.com (or jane@example.com or bob@example.com)\n";
echo "Try password: password or password123\n";
