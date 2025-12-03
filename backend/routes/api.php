<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check
Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

// Public routes
Route::post('/auth/login', [App\Http\Controllers\AuthController::class, 'login']);
Route::post('/auth/register', [App\Http\Controllers\AuthController::class, 'register']);
Route::get('/plans', [App\Http\Controllers\PlanController::class, 'index']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Authentication
    Route::post('/auth/logout', [App\Http\Controllers\AuthController::class, 'logout']);
    Route::post('/auth/refresh', [App\Http\Controllers\AuthController::class, 'refresh']);
    
    // Organization routes
    Route::prefix('organizations')->group(function () {
        Route::get('/', [App\Http\Controllers\OrganizationController::class, 'index']);
        Route::post('/', [App\Http\Controllers\OrganizationController::class, 'store']);
        Route::get('/{id}', [App\Http\Controllers\OrganizationController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\OrganizationController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\OrganizationController::class, 'destroy']);
    });
    
    // Party routes
    Route::prefix('parties')->group(function () {
        Route::get('/', [App\Http\Controllers\PartyController::class, 'index']);
        Route::post('/', [App\Http\Controllers\PartyController::class, 'store']);
        Route::get('/{id}', [App\Http\Controllers\PartyController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\PartyController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\PartyController::class, 'destroy']);
    });
    
    // Item routes
    Route::prefix('items')->group(function () {
        Route::get('/', [App\Http\Controllers\ItemController::class, 'index']);
        Route::post('/', [App\Http\Controllers\ItemController::class, 'store']);
        Route::get('/{id}', [App\Http\Controllers\ItemController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\ItemController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\ItemController::class, 'destroy']);
    });
    
    // Godown routes
    Route::prefix('godowns')->group(function () {
        Route::get('/', [App\Http\Controllers\GodownController::class, 'index']);
        Route::post('/', [App\Http\Controllers\GodownController::class, 'store']);
        Route::get('/{id}', [App\Http\Controllers\GodownController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\GodownController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\GodownController::class, 'destroy']);
    });
    
    // User profile routes
    Route::prefix('user')->group(function () {
        Route::get('/profile', [App\Http\Controllers\ProfileController::class, 'show']);
        Route::put('/profile', [App\Http\Controllers\ProfileController::class, 'update']);
        Route::put('/profile/password', [App\Http\Controllers\ProfileController::class, 'updatePassword']);
        
        // User subscription routes
        Route::get('/subscription', [App\Http\Controllers\SubscriptionController::class, 'show']);
        Route::post('/subscribe', [App\Http\Controllers\SubscriptionController::class, 'subscribe']);
        Route::put('/subscription/change-plan', [App\Http\Controllers\SubscriptionController::class, 'changePlan']);
        Route::delete('/subscription/cancel', [App\Http\Controllers\SubscriptionController::class, 'cancel']);
    });
    
    // Admin routes
    Route::middleware('admin')->prefix('admin')->group(function () {
        // User management
        Route::get('/users', [App\Http\Controllers\UserController::class, 'index']);
        Route::post('/users', [App\Http\Controllers\UserController::class, 'store']);
        Route::put('/users/{id}', [App\Http\Controllers\UserController::class, 'update']);
        Route::patch('/users/{id}/status', [App\Http\Controllers\UserController::class, 'updateStatus']);
        Route::delete('/users/{id}', [App\Http\Controllers\UserController::class, 'destroy']);
        
        // Plan management
        Route::get('/plans', [App\Http\Controllers\PlanController::class, 'adminIndex']);
        Route::post('/plans', [App\Http\Controllers\PlanController::class, 'store']);
        Route::put('/plans/{id}', [App\Http\Controllers\PlanController::class, 'update']);
        Route::delete('/plans/{id}', [App\Http\Controllers\PlanController::class, 'destroy']);
        
        // Activity logs
        Route::get('/activity-logs', [App\Http\Controllers\ActivityLogController::class, 'index']);
    });
});
