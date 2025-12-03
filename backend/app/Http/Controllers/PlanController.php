<?php

namespace App\Http\Controllers;

use App\Models\Plan;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PlanController extends Controller
{
    /**
     * Display a listing of active plans (public endpoint).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $plans = Plan::active()->get();

        return response()->json([
            'data' => $plans,
        ], 200);
    }

    /**
     * Display all plans for admin.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function adminIndex()
    {
        $plans = Plan::withCount('activeSubscriptions')->get();

        return response()->json([
            'data' => $plans,
        ], 200);
    }

    /**
     * Store a newly created plan.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:plans,name',
            'description' => 'nullable|string',
            'price_monthly' => 'required|numeric|min:0',
            'price_yearly' => 'required|numeric|min:0',
            'features' => 'nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        $plan = Plan::create($validated);

        // Log the activity
        ActivityLog::log(
            $request->user()->id,
            'created',
            'Plan',
            $plan->id,
            [
                'name' => $plan->name,
                'price_monthly' => $plan->price_monthly,
                'price_yearly' => $plan->price_yearly,
            ]
        );

        return response()->json([
            'plan' => $plan,
            'message' => 'Plan created successfully',
        ], 201);
    }

    /**
     * Update the specified plan.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $plan = Plan::findOrFail($id);

        $validated = $request->validate([
            'name' => [
                'sometimes',
                'required',
                'string',
                'max:255',
                Rule::unique('plans', 'name')->ignore($plan->id),
            ],
            'description' => 'sometimes|nullable|string',
            'price_monthly' => 'sometimes|required|numeric|min:0',
            'price_yearly' => 'sometimes|required|numeric|min:0',
            'features' => 'sometimes|nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        $oldData = $plan->only(['name', 'price_monthly', 'price_yearly', 'is_active']);
        $plan->update($validated);

        // Log the activity
        ActivityLog::log(
            $request->user()->id,
            'updated',
            'Plan',
            $plan->id,
            [
                'old' => $oldData,
                'new' => $plan->only(['name', 'price_monthly', 'price_yearly', 'is_active']),
            ]
        );

        return response()->json([
            'plan' => $plan,
            'message' => 'Plan updated successfully',
        ], 200);
    }

    /**
     * Remove the specified plan.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $plan = Plan::findOrFail($id);

        // Check if plan has active subscriptions
        if ($plan->hasActiveSubscriptions()) {
            return response()->json([
                'message' => 'Cannot delete plan with active subscriptions',
            ], 400);
        }

        $planData = $plan->only(['name', 'price_monthly', 'price_yearly']);

        // Log the activity before deletion
        ActivityLog::log(
            $request->user()->id,
            'deleted',
            'Plan',
            $plan->id,
            $planData
        );

        $plan->delete();

        return response()->json([
            'message' => 'Plan deleted successfully',
        ], 200);
    }
}
