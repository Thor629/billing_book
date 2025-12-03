<?php

namespace App\Http\Controllers;

use App\Models\Party;
use Illuminate\Http\Request;

class PartyController extends Controller
{
    /**
     * Get parties for the selected organization.
     */
    public function index(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json([
                'message' => 'Organization ID is required',
            ], 400);
        }

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $organizationId)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied to this organization',
            ], 403);
        }

        $parties = Party::where('organization_id', $organizationId)
            ->orderBy('name')
            ->get();

        return response()->json([
            'data' => $parties,
        ], 200);
    }

    /**
     * Create a new party.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'organization_id' => 'required|exists:organizations,id',
            'name' => 'required|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'phone' => 'required|string|max:20',
            'gst_no' => 'nullable|string|max:50',
            'billing_address' => 'nullable|string',
            'shipping_address' => 'nullable|string',
            'party_type' => 'required|in:customer,vendor,both',
        ]);

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $validated['organization_id'])
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied to this organization',
            ], 403);
        }

        $party = Party::create($validated);

        return response()->json([
            'party' => $party,
            'message' => 'Party created successfully',
        ], 201);
    }

    /**
     * Get a specific party.
     */
    public function show(Request $request, $id)
    {
        $party = Party::findOrFail($id);

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $party->organization_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied',
            ], 403);
        }

        return response()->json([
            'party' => $party,
        ], 200);
    }

    /**
     * Update party.
     */
    public function update(Request $request, $id)
    {
        $party = Party::findOrFail($id);

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $party->organization_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'contact_person' => 'nullable|string|max:255',
            'email' => 'nullable|email|max:255',
            'phone' => 'sometimes|required|string|max:20',
            'gst_no' => 'nullable|string|max:50',
            'billing_address' => 'nullable|string',
            'shipping_address' => 'nullable|string',
            'party_type' => 'sometimes|required|in:customer,vendor,both',
            'is_active' => 'sometimes|boolean',
        ]);

        $party->update($validated);

        return response()->json([
            'party' => $party,
            'message' => 'Party updated successfully',
        ], 200);
    }

    /**
     * Delete party.
     */
    public function destroy(Request $request, $id)
    {
        $party = Party::findOrFail($id);

        // Verify user has access to this organization
        $hasAccess = $request->user()
            ->organizations()
            ->where('organizations.id', $party->organization_id)
            ->exists();

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Access denied',
            ], 403);
        }

        $party->delete();

        return response()->json([
            'message' => 'Party deleted successfully',
        ], 200);
    }
}
