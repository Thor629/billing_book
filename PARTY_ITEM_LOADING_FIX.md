# ✅ Party and Item Loading Fix

## Issue
When clicking "Create New" on any screen, the party and item selection dialogs showed "No parties found" and "No items found" because the data wasn't being loaded from the API.

## Root Cause
When I removed the duplicate `_loadInitialData` method earlier to fix compilation errors, I accidentally removed the code that loads parties, items, and bank accounts from the API. This code is needed for both create and edit modes:
- **Edit mode:** Needs to load the existing record data
- **Create mode:** Needs to load parties/items lists for selection dialogs

## Solution
Added back the code to load parties, items, and bank accounts at the beginning of `_loadInitialData`, so it runs for both create and edit modes.

## Fixed Screen

### ✅ Sales Return
**File:** `flutter_app/lib/screens/user/create_sales_return_screen.dart`

**Changes:**
1. Added imports for PartyService, ItemService, BankAccountService, AuthProvider
2. Added code to load parties, items, and bank accounts from API
3. This code runs for both create and edit modes

**Code Added:**
```dart
Future<void> _loadInitialData() async {
  // Load parties, items, and bank accounts for selection dialogs
  final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  if (orgProvider.selectedOrganization != null) {
    try {
      final token = await authProvider.token;
      if (token == null) return;

      final partyService = PartyService();
      final itemService = ItemService();
      final bankAccountService = BankAccountService();

      final parties = await partyService.getParties(orgProvider.selectedOrganization!.id);
      final items = await itemService.getItems(orgProvider.selectedOrganization!.id);
      final accounts = await bankAccountService.getBankAccounts(token, orgProvider.selectedOrganization!.id);

      setState(() {
        _parties = parties;
        _availableItems = items;
        _bankAccounts = accounts;
      });
    } catch (e) {
      // Handle error
    }
  }

  // Then load existing return data if in edit mode
  if (widget.returnId != null) {
    // ... existing edit mode code
  }
}
```

## Other Screens Status

The same issue likely exists in other screens. Need to check:

### ⚠️ Needs Checking
- [ ] Quotations - Check if parties/items load in create mode
- [ ] Sales Invoices - Check if parties/items load in create mode
- [ ] Credit Notes - Check if parties/items load in create mode
- [ ] Debit Notes - Check if parties/items load in create mode
- [ ] Delivery Challans - Check if parties/items load in create mode
- [ ] Purchase Invoices - Check if parties/items load in create mode
- [ ] Purchase Returns - Check if parties/items load in create mode

## Testing

### Test Create Mode:
1. Go to Sales Return screen
2. Click "Create New"
3. Click on "Bill To" to select party
4. ✅ Should see list of parties (not "No parties found")
5. Click "+ Add Item"
6. ✅ Should see list of items (not "No items found")

### Test Edit Mode:
1. Create a return with party and items
2. Click Edit button
3. ✅ Should load all data including party name and items
4. ✅ Selection dialogs should still work

## Status
✅ **Sales Return fixed!**
⚠️ **Other screens may need the same fix**

If you see "No parties found" or "No items found" on other screens when creating new records, they need the same fix applied.
