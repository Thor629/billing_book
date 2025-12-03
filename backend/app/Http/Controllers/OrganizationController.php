<?php

namespace App\Http\Controllers;

use App\Models\Organization;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrganizationController extends Controller
{
    /**
     * Get user's organizations.
     */
    public function index(Request $request)
    {
        $organizations = $request->user()
            ->organizations()
            ->with('creator:id,name,email')
            ->get();

        return response()->json([
            'data' => $organizations,
        ], 200);
    }

    /**
     * Create a new organization.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'gst_no' => 'nullable|string|max:50',
            'billing_address' => 'nullable|string',
            'mobile_no' => 'required|string|max:20',
            'email' => 'required|email|max:255',
        ]);

        DB::beginTransaction();
        try {
            // Create organization
            $organization = Organization::create([
                'name' => $validated['name'],
                'gst_no' => $validated['gst_no'] ?? null,
                'billing_address' => $validated['billing_address'] ?? null,
                'mobile_no' => $validated['mobile_no'],
                'email' => $validated['email'],
                'created_by' => $request->user()->id,
                'is_active' => true,
            ]);

            // Attach creator as owner
            $organization->users()->attach($request->user()->id, [
                'role' => 'owner',
            ]);

            DB::commit();

            return response()->json([
                'organization' => $organization->load('creator:id,name,email'),
                'message' => 'Organization created successfully',
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Get a specific organization.
     */
    public function show(Request $request, $id)
    {
        $organization = Organization::with('creator:id,name,email')
            ->findOrFail($id);

        // Check if user has access
        if (!$organization->hasMember($request->user())) {
            return response()->json([
                'message' => 'Access denied',
            ], 403);
        }

        return response()->json([
            'organization' => $organization,
        ], 200);
    }

    /**
     * Update organization.
     */
    public function update(Request $request, $id)
    {
        $organization = Organization::findOrFail($id);

        // Check if user is owner
        if (!$organization->isOwner($request->user())) {
            return response()->json([
                'message' => 'Only organization owner can update',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'gst_no' => 'nullable|string|max:50',
            'billing_address' => 'nullable|string',
            'mobile_no' => 'sometimes|required|string|max:20',
            'email' => 'sometimes|required|email|max:255',
        ]);

        $organization->update($validated);

        return response()->json([
            'organization' => $organization->load('creator:id,name,email'),
            'message' => 'Organization updated successfully',
        ], 200);
    }

    /**
     * Delete organization.
     */
    public function destroy(Request $request, $id)
    {
        $organization = Organization::findOrFail($id);

        // Check if user is owner
        if (!$organization->isOwner($request->user())) {
            return response()->json([
                'message' => 'Only organization owner can delete',
            ], 403);
        }

        $organization->delete();

        return response()->json([
            'message' => 'Organization deleted successfully',
        ], 200);
    }
}
