<?php

namespace App\Http\Controllers;

use App\Models\Godown;
use Illuminate\Http\Request;

class GodownController extends Controller
{
    public function index(Request $request)
    {
        $organizationId = $request->query('organization_id');

        if (!$organizationId) {
            return response()->json(['message' => 'Organization ID is required'], 400);
        }

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $organizationId)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $godowns = Godown::where('organization_id', $organizationId)
            ->orderBy('name')->get();

        return response()->json(['data' => $godowns], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'organization_id' => 'required|exists:organizations,id',
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:255|unique:godowns',
            'address' => 'nullable|string',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
        ]);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $validated['organization_id'])->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $godown = Godown::create($validated);

        return response()->json([
            'godown' => $godown,
            'message' => 'Godown created successfully'
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $godown = Godown::findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $godown->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        return response()->json(['godown' => $godown], 200);
    }

    public function update(Request $request, $id)
    {
        $godown = Godown::findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $godown->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'code' => 'sometimes|required|string|max:255|unique:godowns,code,' . $id,
            'address' => 'nullable|string',
            'contact_person' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
            'is_active' => 'sometimes|boolean',
        ]);

        $godown->update($validated);

        return response()->json([
            'godown' => $godown,
            'message' => 'Godown updated successfully'
        ], 200);
    }

    public function destroy(Request $request, $id)
    {
        $godown = Godown::findOrFail($id);

        $hasAccess = $request->user()->organizations()
            ->where('organizations.id', $godown->organization_id)->exists();

        if (!$hasAccess) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $godown->delete();

        return response()->json(['message' => 'Godown deleted successfully'], 200);
    }
}
