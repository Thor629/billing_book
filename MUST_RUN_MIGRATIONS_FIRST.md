# ⚠️ MUST RUN MIGRATIONS FIRST! ⚠️

## The Problem

You're getting errors because the database columns don't exist yet. The migrations haven't been run!

### Current Error
```
Column not found: 1054 Unknown column 'converted_to_invoice' in 'field list'
```

This means the `purchase_orders` table is missing the conversion tracking columns.

## The Solution

**YOU MUST RUN THE MIGRATIONS!**

### Quick Fix - Use This Batch File:

```
RUN_ALL_MIGRATIONS_NOW.bat
```

### Or Run Manually:

```bash
cd backend
php artisan migrate
```

## What the Migrations Will Add

### Migration 1: Add conversion fields to purchase_orders
**File:** `2025_12_13_130000_add_conversion_fields_to_purchase_orders.php`

Adds to `purchase_orders` table:
- `converted_to_invoice` (boolean)
- `purchase_invoice_id` (foreign key)
- `converted_at` (timestamp)

### Migration 2: Add payment fields to purchase_invoices
**File:** `2025_12_13_140000_add_payment_fields_to_purchase_invoices.php`

Adds to `purchase_invoices` table:
- `payment_mode` (string)
- `round_off` (decimal)
- `auto_round_off` (boolean)
- `fully_paid` (boolean)
- `payment_amount` (decimal)

## Step-by-Step Instructions

### Step 1: Stop Backend Server
Press `Ctrl+C` in the terminal running `php artisan serve`

### Step 2: Run Migrations
**Option A: Use Batch File (Easiest)**
```
Double-click: RUN_ALL_MIGRATIONS_NOW.bat
```

**Option B: Manual Commands**
```bash
cd backend
php artisan migrate
```

### Step 3: Verify Migrations Ran
You should see output like:
```
Running migrations.
2025_12_13_130000_add_conversion_fields_to_purchase_orders .... DONE
2025_12_13_140000_add_payment_fields_to_purchase_invoices ... DONE
```

### Step 4: Restart Backend Server
```bash
cd backend
php artisan serve
```

### Step 5: Test Conversion
1. Go to Purchase Orders screen
2. Click "Convert to Invoice"
3. Should work now! ✅

## Why This Happens

The code expects database columns that don't exist yet. Migrations create these columns.

### Without Migrations
```
Code tries to update: converted_to_invoice
    ↓
Database: "What column? I don't have that!"
    ↓
ERROR: Column not found
```

### With Migrations
```
Migration creates: converted_to_invoice column
    ↓
Code tries to update: converted_to_invoice
    ↓
Database: "Got it! Updating..."
    ↓
SUCCESS!
```

## Common Migration Commands

### Run all pending migrations
```bash
php artisan migrate
```

### Check migration status
```bash
php artisan migrate:status
```

### Rollback last migration
```bash
php artisan migrate:rollback
```

### Rollback all migrations and re-run
```bash
php artisan migrate:fresh
```
⚠️ **WARNING:** This will delete all data!

### Run specific migration
```bash
php artisan migrate --path=/database/migrations/2025_12_13_130000_add_conversion_fields_to_purchase_orders.php
```

## Troubleshooting

### Error: "Nothing to migrate"
This means migrations already ran. Check if columns exist:
```sql
DESCRIBE purchase_orders;
DESCRIBE purchase_invoices;
```

### Error: "Class not found"
Make sure you're in the `backend` directory:
```bash
cd backend
php artisan migrate
```

### Error: "Access denied"
Check your `.env` file database credentials:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

### Error: "Table already exists"
The migration already ran. Skip it or rollback:
```bash
php artisan migrate:rollback --step=1
php artisan migrate
```

## What Happens After Migrations

Once migrations are run, the conversion will work:

1. ✅ Invoice number generated (PI-000001)
2. ✅ Purchase invoice created
3. ✅ Items copied with amounts
4. ✅ Stock updated (stock_qty increased)
5. ✅ Bank balance updated (decreased)
6. ✅ Bank transaction created
7. ✅ Purchase order marked as converted
8. ✅ Success message shown

## Files Created

### Migrations
1. `backend/database/migrations/2025_12_13_130000_add_conversion_fields_to_purchase_orders.php`
2. `backend/database/migrations/2025_12_13_140000_add_payment_fields_to_purchase_invoices.php`

### Batch Files
1. `RUN_ALL_MIGRATIONS_NOW.bat` - Run all migrations
2. `RUN_PURCHASE_ORDER_MIGRATIONS.bat` - Run specific migrations

### Documentation
1. `PURCHASE_ORDER_TO_INVOICE_CONVERSION_COMPLETE.md` - Feature overview
2. `PURCHASE_ORDER_CONVERSION_FIX.md` - Column fixes
3. `PURCHASE_ORDER_CONVERSION_INVOICE_NUMBER_FIX.md` - Invoice number fix
4. `PURCHASE_ORDER_CONVERSION_FINAL_FIX.md` - Stock column fix
5. `MUST_RUN_MIGRATIONS_FIRST.md` - This file

## Quick Checklist

Before testing conversion, make sure:
- [ ] Migrations have been run
- [ ] Backend server is running
- [ ] No error messages in backend console
- [ ] Database has new columns
- [ ] Frontend is connected to backend

## Status: ⚠️ ACTION REQUIRED

**YOU MUST RUN MIGRATIONS BEFORE THE CONVERSION WILL WORK!**

Run this now:
```
RUN_ALL_MIGRATIONS_NOW.bat
```

Or manually:
```bash
cd backend
php artisan migrate
php artisan serve
```

Then test the conversion - it will work! ✅
