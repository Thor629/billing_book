# Debug Payment Out Validation Error

## Steps to Debug

1. **Restart backend server:**
   ```bash
   cd backend
   php artisan serve
   ```

2. **Hot reload Flutter:**
   - Press `R` in the Flutter terminal

3. **Try to save payment and check logs:**

### Flutter Console
Look for these debug prints:
```
💾 Creating payment out with data: {...}
📡 Create payment response status: 422
📡 Create payment response body: {...}
```

### Backend Logs
Check the file: `backend/storage/logs/laravel.log`

Look for:
```
Payment Out Store Request: {...}
Payment Out Validation Failed: {...}
```

## Common Validation Issues

1. **party_id** - Must exist in parties table
2. **payment_number** - Must be unique (PO-000001)
3. **payment_date** - Must be valid date format (YYYY-MM-DD)
4. **amount** - Must be numeric and > 0.01
5. **payment_method** - Must be one of: cash, bank_transfer, cheque, card, upi, other
6. **bank_account_id** - Must exist in bank_accounts table (if provided)
7. **status** - Must be one of: pending, completed, failed, cancelled

## Check Data Being Sent

The Flutter console will show exactly what data is being sent. Compare it with the validation rules above.

## Next Steps

After you try to save and see the error logs, share:
1. The Flutter console output (💾 and 📡 lines)
2. The backend log validation errors

This will help identify the exact field causing the issue.
