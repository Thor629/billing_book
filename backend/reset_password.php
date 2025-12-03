<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$user = User::where('email', 'vc@gmail.com')->first();

if ($user) {
    $user->password = Hash::make('password123');
    $user->save();
    echo "✅ Password reset successfully for: {$user->email}\n";
    echo "📧 Email: vc@gmail.com\n";
    echo "🔑 Password: password123\n";
} else {
    echo "❌ User not found\n";
}
