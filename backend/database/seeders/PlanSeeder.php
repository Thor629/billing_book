<?php

namespace Database\Seeders;

use App\Models\Plan;
use Illuminate\Database\Seeder;

class PlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $plans = [
            [
                'name' => 'Basic',
                'description' => 'Perfect for individuals and small projects',
                'price_monthly' => 9.99,
                'price_yearly' => 99.99,
                'features' => [
                    '10 Projects',
                    '5 GB Storage',
                    'Email Support',
                    'Basic Analytics',
                ],
                'is_active' => true,
            ],
            [
                'name' => 'Pro',
                'description' => 'Ideal for growing businesses and teams',
                'price_monthly' => 29.99,
                'price_yearly' => 299.99,
                'features' => [
                    'Unlimited Projects',
                    '50 GB Storage',
                    'Priority Email Support',
                    'Advanced Analytics',
                    'Team Collaboration',
                    'API Access',
                ],
                'is_active' => true,
            ],
            [
                'name' => 'Enterprise',
                'description' => 'For large organizations with advanced needs',
                'price_monthly' => 99.99,
                'price_yearly' => 999.99,
                'features' => [
                    'Unlimited Everything',
                    '500 GB Storage',
                    '24/7 Phone Support',
                    'Custom Analytics',
                    'Advanced Team Management',
                    'Full API Access',
                    'Custom Integrations',
                    'Dedicated Account Manager',
                ],
                'is_active' => true,
            ],
        ];

        foreach ($plans as $plan) {
            Plan::create($plan);
        }

        $this->command->info('Sample plans created: Basic, Pro, Enterprise');
    }
}
