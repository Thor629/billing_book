<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $query = User::query()->with('activeSubscription.plan');

        // Search functionality
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        // Filter by role
        if ($request->has('role') && $request->role) {
            $query->where('role', $request->role);
        }

        // Pagination
        $perPage = $request->get('per_page', 20);
        $users = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'data' => $users->items(),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ], 200);
    }

    /**
     * Store a newly created user.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'role' => ['required', Rule::in(['admin', 'user'])],
        ]);

        // Create user with default inactive status
        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'status' => 'inactive', // Default status
        ]);

        // Log the activity
        ActivityLog::log(
            $request->user()->id,
            'created',
            'User',
            $user->id,
            [
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
            ]
        );

        // TODO: Send welcome email notification (Task 6)

        return response()->json([
            'user' => $user,
            'message' => 'User created successfully',
        ], 201);
    }

    /**
     * Update the specified user.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => [
                'sometimes',
                'required',
                'email',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'role' => ['sometimes', 'required', Rule::in(['admin', 'user'])],
        ]);

        $oldData = $user->only(['name', 'email', 'role']);
        $user->update($validated);

        // Log the activity
        ActivityLog::log(
            $request->user()->id,
            'updated',
            'User',
            $user->id,
            [
                'old' => $oldData,
                'new' => $user->only(['name', 'email', 'role']),
            ]
        );

        return response()->json([
            'user' => $user,
            'message' => 'User updated successfully',
        ], 200);
    }

    /**
     * Update user status (activate/deactivate).
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'status' => ['required', Rule::in(['active', 'inactive'])],
        ]);

        $oldStatus = $user->status;
        $user->status = $validated['status'];
        $user->save();

        // Log the activity
        ActivityLog::log(
            $request->user()->id,
            'status_changed',
            'User',
            $user->id,
            [
                'old_status' => $oldStatus,
                'new_status' => $user->status,
            ]
        );

        // TODO: Send email notification if deactivated (Task 6)

        return response()->json([
            'user' => $user,
            'message' => "User {$user->status} successfully",
        ], 200);
    }

    /**
     * Remove the specified user.
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $user = User::findOrFail($id);

        // Prevent deleting yourself
        if ($user->id === $request->user()->id) {
            return response()->json([
                'message' => 'You cannot delete your own account',
            ], 400);
        }

        $userData = $user->only(['name', 'email', 'role']);

        // Log the activity before deletion
        ActivityLog::log(
            $request->user()->id,
            'deleted',
            'User',
            $user->id,
            $userData
        );

        $user->delete();

        return response()->json([
            'message' => 'User deleted successfully',
        ], 200);
    }
}
