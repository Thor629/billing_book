<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        // For API requests, return null to send 401 response instead of redirect
        if ($request->is('api/*') || $request->expectsJson()) {
            return null;
        }
        
        // For web requests, redirect to login if route exists
        return route('login');
    }
}
