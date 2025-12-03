<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Organization;

class InitialDataSeeder extends Seeder
{
    public function run(): void
    {
        // Create a test user
        $user = User::create([
            'name' => 'VC',
            'email' => 'vc@gmail.com',
            'phone' => '6969696969',
            'password' => Hash::make('password'),
            'role' => 'user',
            'status' => 'active',
        ]);

        // Create an organization for the user
        $organization = Organization::create([
            'name' => 'xyzzz',
            'gst_no' => null,
            'billing_address' => null,
            'mobile_no' => '6969696969',
            'email' => 'vc@gmail.com',
            'created_by' => $user->id,
            'is_active' => true,
        ]);

        // Attach user to organization as owner
        $organization->users()->attach($user->id, ['role' => 'owner']);

        $this->command->info('Initial data seeded successfully!');
    }
}
