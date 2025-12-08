# Purchase Invoice SharedPreferences Removed

## Issue
The `purchase_invoice_service.dart` was using SharedPreferences to store and retrieve the organization ID, which is unnecessary since you're using a backend database and the OrganizationProvider already manages this state.

## Changes Made

### 1. Removed SharedPreferences from Service
**File**: `flutter_app/lib/services/purchase_invoice_service.dart`

- Removed `import 'package:shared_preferences/shared_preferences.dart';`
- Removed `_getSelectedOrganizationId()` method that was reading from SharedPreferences
- Updated all methods to accept `organizationId` as a parameter instead:
  - `getPurchaseInvoices()` - now accepts optional `organizationId` parameter
  - `createPurchaseInvoice()` - now reads `organizationId` from the invoiceData map
  - `deletePurchaseInvoice()` - now accepts `organizationId` as a parameter

### 2. Updated Screen to Pass Organization ID
**File**: `flutter_app/lib/screens/user/purchase_invoices_screen.dart`

- Updated `_loadInvoices()` to pass organization ID from OrganizationProvider
- Updated delete functionality to pass organization ID from OrganizationProvider

## Why This is Better

1. **Single Source of Truth**: Organization ID comes from OrganizationProvider, not duplicated in SharedPreferences
2. **Backend-First**: All data flows through your Laravel backend and database
3. **No Sync Issues**: No risk of SharedPreferences being out of sync with the actual selected organization
4. **Cleaner Architecture**: Services don't manage state, they just make API calls
5. **Type Safety**: Organization ID is passed explicitly, making the code more predictable

## Testing
Test the purchase invoice functionality:
1. Create a new purchase invoice - should work normally
2. View purchase invoices list - should load correctly
3. Delete a purchase invoice - should work properly

All operations now properly use the organization from OrganizationProvider instead of SharedPreferences.
