<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Plan;
use App\Models\Subscription;
use Illuminate\Database\Seeder;

class SampleSubscriptionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $john = User::where('email', 'john@example.com')->first();
        $jane = User::where('email', 'jane@example.com')->first();

        $basicPlan = Plan::where('name', 'Basic')->first();
        $proPlan = Plan::where('name', 'Pro')->first();

        if ($john && $basicPlan) {
            Subscription::create([
                'user_id' => $john->id,
                'plan_id' => $basicPlan->id,
                'billing_cycle' => 'monthly',
                'status' => 'active',
                'started_at' => now(),
                'expires_at' => now()->addDays(30),
            ]);
        }

        if ($jane && $proPlan) {
            Subscription::create([
                'user_id' => $jane->id,
                'plan_id' => $proPlan->id,
                'billing_cycle' => 'yearly',
                'status' => 'active',
                'started_at' => now(),
                'expires_at' => now()->addDays(365),
            ]);
        }

        $this->command->info('Sample subscriptions created');
    }
}
