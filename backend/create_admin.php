<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

// Check if admin exists
$admin = User::where('email', 'admin@example.com')->first();

if ($admin) {
    echo "✅ Admin user already exists\n";
    echo "📧 Email: admin@example.com\n";
    echo "🔑 Password: password123\n";
    echo "👤 Role: {$admin->role}\n";
} else {
    // Create admin user
    $admin = User::create([
        'name' => 'Admin',
        'email' => 'admin@example.com',
        'phone' => '1234567890',
        'password' => Hash::make('password123'),
        'role' => 'admin',
        'status' => 'active',
    ]);

    echo "✅ Admin user created successfully!\n";
    echo "📧 Email: admin@example.com\n";
    echo "🔑 Password: password123\n";
    echo "👤 Role: admin\n";
}
