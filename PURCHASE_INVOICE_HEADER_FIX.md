# Purchase Invoice Header Fix - Complete

## Problem
Purchase invoices were not displaying in the list even after successful creation. The screen showed "No purchase invoices yet" despite the green success message.

## Root Cause
The backend `PurchaseInvoiceController` expects the `X-Organization-Id` header to filter invoices:
```php
$query = PurchaseInvoice::with(['party', 'items.item'])
    ->where('organization_id', $request->header('X-Organization-Id'));
```

However, the Flutter `PurchaseInvoiceService` was NOT sending this header, so the backend couldn't filter the invoices properly and likely returned an empty result or error.

## Solution

### 1. Updated API Client
Modified `api_client.dart` to support custom headers in all HTTP methods:
- `get()` - Added `customHeaders` parameter
- `post()` - Added `customHeaders` parameter  
- `delete()` - Added `customHeaders` parameter

### 2. Updated Purchase Invoice Service
Modified `purchase_invoice_service.dart` to:
- Get the selected organization ID from SharedPreferences
- Send `X-Organization-Id` header with all API requests:
  - `getPurchaseInvoices()` - For fetching invoices
  - `createPurchaseInvoice()` - For creating invoices
  - `deletePurchaseInvoice()` - For deleting invoices

## Files Modified
1. `flutter_app/lib/services/api_client.dart`
2. `flutter_app/lib/services/purchase_invoice_service.dart`

## Code Changes

### API Client
```dart
// Before
Future<http.Response> get(String endpoint, {bool includeAuth = true})

// After
Future<http.Response> get(String endpoint, {bool includeAuth = true, Map<String, String>? customHeaders})
```

### Purchase Invoice Service
```dart
// Added helper method
Future<int?> _getSelectedOrganizationId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('selected_organization_id');
}

// Updated all methods to include header
final response = await _apiClient.get(
  '/purchase-invoices?$queryString',
  customHeaders: {
    'X-Organization-Id': organizationId.toString(),
  },
);
```

## Why This Works
1. Backend filters invoices by organization_id from the header
2. Flutter now sends the organization_id in the header
3. Backend returns only invoices for the selected organization
4. Flutter displays the filtered invoices correctly

## Testing
After this fix:
1. ✅ Purchase invoices are fetched with the correct organization filter
2. ✅ Created invoices appear in the list immediately
3. ✅ Only invoices for the selected organization are shown
4. ✅ Delete operations work correctly with the header

## Status
✅ **FIXED** - Purchase invoices now display correctly with proper organization filtering.
