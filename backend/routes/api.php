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
    
    // Quotation routes
    Route::prefix('quotations')->group(function () {
        Route::get('/', [App\Http\Controllers\QuotationController::class, 'index']);
        Route::post('/', [App\Http\Controllers\QuotationController::class, 'store']);
        Route::get('/next-number', [App\Http\Controllers\QuotationController::class, 'getNextQuotationNumber']);
        Route::get('/{id}', [App\Http\Controllers\QuotationController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\QuotationController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\QuotationController::class, 'destroy']);
    });
    
    // Payment In routes
    Route::prefix('payment-ins')->group(function () {
        Route::get('/', [App\Http\Controllers\PaymentInController::class, 'index']);
        Route::post('/', [App\Http\Controllers\PaymentInController::class, 'store']);
        Route::get('/next-number', [App\Http\Controllers\PaymentInController::class, 'getNextPaymentNumber']);
        Route::get('/{id}', [App\Http\Controllers\PaymentInController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\PaymentInController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\PaymentInController::class, 'destroy']);
    });
    
    // Sales Invoice routes
    Route::prefix('sales-invoices')->group(function () {
        Route::get('/', [App\Http\Controllers\SalesInvoiceController::class, 'index']);
        Route::post('/', [App\Http\Controllers\SalesInvoiceController::class, 'store']);
        Route::get('/next-number', [App\Http\Controllers\SalesInvoiceController::class, 'getNextInvoiceNumber']);
        Route::get('/{id}', [App\Http\Controllers\SalesInvoiceController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\SalesInvoiceController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\SalesInvoiceController::class, 'destroy']);
    });
    
    // Sales Return routes
    Route::prefix('sales-returns')->group(function () {
        Route::get('/', [App\Http\Controllers\SalesReturnController::class, 'index']);
        Route::post('/', [App\Http\Controllers\SalesReturnController::class, 'store']);
        Route::get('/next-number', [App\Http\Controllers\SalesReturnController::class, 'getNextReturnNumber']);
        Route::get('/{id}', [App\Http\Controllers\SalesReturnController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\SalesReturnController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\SalesReturnController::class, 'destroy']);
    });
    
    // Credit Note routes
    Route::prefix('credit-notes')->group(function () {
        Route::get('/', [App\Http\Controllers\CreditNoteController::class, 'index']);
        Route::post('/', [App\Http\Controllers\CreditNoteController::class, 'store']);
        Route::get('/next-number', [App\Http\Controllers\CreditNoteController::class, 'getNextNumber']);
        Route::get('/{id}', [App\Http\Controllers\CreditNoteController::class, 'show']);
        Route::put('/{id}', [App\Http\Controllers\CreditNoteController::class, 'update']);
        Route::delete('/{id}', [App\Http\Controllers\CreditNoteController::class, 'destroy']);
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
