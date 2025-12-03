<?php

namespace App\Services;

use App\Models\User;
use App\Models\Subscription;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    /**
     * Send welcome email to new user.
     *
     * @param User $user
     * @return void
     */
    public function sendWelcomeEmail(User $user): void
    {
        try {
            // TODO: Implement actual email sending with Mail facade
            // For now, just log it
            Log::info('Welcome email sent', [
                'user_id' => $user->id,
                'email' => $user->email,
                'name' => $user->name,
            ]);

            // Example implementation:
            // Mail::to($user->email)->send(new WelcomeEmail($user));
        } catch (\Exception $e) {
            Log::error('Failed to send welcome email', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Send account status change notification.
     *
     * @param User $user
     * @param string $oldStatus
     * @param string $newStatus
     * @return void
     */
    public function sendStatusChangeEmail(User $user, string $oldStatus, string $newStatus): void
    {
        try {
            Log::info('Status change email sent', [
                'user_id' => $user->id,
                'email' => $user->email,
                'old_status' => $oldStatus,
                'new_status' => $newStatus,
            ]);

            // Example implementation:
            // Mail::to($user->email)->send(new StatusChangeEmail($user, $oldStatus, $newStatus));
        } catch (\Exception $e) {
            Log::error('Failed to send status change email', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Send subscription confirmation email.
     *
     * @param Subscription $subscription
     * @return void
     */
    public function sendSubscriptionConfirmationEmail(Subscription $subscription): void
    {
        try {
            $subscription->load('user', 'plan');

            Log::info('Subscription confirmation email sent', [
                'user_id' => $subscription->user_id,
                'email' => $subscription->user->email,
                'plan' => $subscription->plan->name,
                'billing_cycle' => $subscription->billing_cycle,
            ]);

            // Example implementation:
            // Mail::to($subscription->user->email)->send(new SubscriptionConfirmationEmail($subscription));
        } catch (\Exception $e) {
            Log::error('Failed to send subscription confirmation email', [
                'subscription_id' => $subscription->id,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
