<?php

namespace App\Http\Controllers;

use App\Models\Plan;
use App\Models\Subscription;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Carbon\Carbon;

class SubscriptionController extends Controller
{
    /**
     * Display the user's current subscription.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request)
    {
        $subscription = $request->user()
            ->subscriptions()
            ->with('plan')
            ->where('status', 'active')
            ->first();

        if (!$subscription) {
            return response()->json([
                'subscription' => null,
                'message' => 'No active subscription found',
            ], 200);
        }

        return response()->json([
            'subscription' => [
                'id' => $subscription->id,
                'plan' => $subscription->plan,
                'billing_cycle' => $subscription->billing_cycle,
                'status' => $subscription->status,
                'started_at' => $subscription->started_at,
                'expires_at' => $subscription->expires_at,
            ],
        ], 200);
    }

    /**
     * Subscribe to a plan.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function subscribe(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:plans,id',
            'billing_cycle' => ['required', Rule::in(['monthly', 'yearly'])],
        ]);

        $plan = Plan::findOrFail($validated['plan_id']);
        $user = $request->user();

        // Check if plan is active
        if (!$plan->is_active) {
            return response()->json([
                'message' => 'This plan is not available',
            ], 400);
        }

        // Cancel any existing active subscriptions
        $user->subscriptions()
            ->where('status', 'active')
            ->update(['status' => 'cancelled']);

        // Calculate expiration date
        $startedAt = now();
        $expiresAt = Subscription::calculateExpirationDate($validated['billing_cycle'], $startedAt);

        // Create new subscription
        $subscription = Subscription::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'billing_cycle' => $validated['billing_cycle'],
            'status' => 'active',
            'started_at' => $startedAt,
            'expires_at' => $expiresAt,
        ]);

        // Update user status to active
        $user->status = 'active';
        $user->save();

        // Load plan relationship
        $subscription->load('plan');

        // TODO: Send confirmation email (Task 6)

        return response()->json([
            'subscription' => $subscription,
            'message' => 'Subscription created successfully',
        ], 201);
    }

    /**
     * Change subscription plan.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePlan(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:plans,id',
        ]);

        $user = $request->user();
        $currentSubscription = $user->activeSubscription;

        if (!$currentSubscription) {
            return response()->json([
                'message' => 'No active subscription found',
            ], 400);
        }

        $newPlan = Plan::findOrFail($validated['plan_id']);

        // Check if plan is active
        if (!$newPlan->is_active) {
            return response()->json([
                'message' => 'This plan is not available',
            ], 400);
        }

        // Update subscription plan
        $currentSubscription->plan_id = $newPlan->id;
        $currentSubscription->save();
        $currentSubscription->load('plan');

        return response()->json([
            'subscription' => $currentSubscription,
            'message' => 'Subscription plan changed successfully',
        ], 200);
    }

    /**
     * Cancel subscription.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function cancel(Request $request)
    {
        $user = $request->user();
        $subscription = $user->activeSubscription;

        if (!$subscription) {
            return response()->json([
                'message' => 'No active subscription found',
            ], 400);
        }

        // Cancel subscription
        $subscription->status = 'cancelled';
        $subscription->save();

        return response()->json([
            'message' => 'Subscription cancelled successfully',
        ], 200);
    }
}
