# Quotation Screen Enhancement Guide

## Overview
This guide shows you how to enhance the Create Quotation screen with the same features as the Sales Invoice screen:
- ✅ Searchable party selection
- ✅ Searchable item selection  
- ✅ Real bank account fetching from Cash & Bank
- ✅ Functional discount and additional charges

## Step 1: Add Required Imports

Add these imports at the top of `create_quotation_screen.dart`:

```dart
import 'package:provider/provider.dart';
import '../../models/party_model.dart';
import '../../models/item_model.dart';
import '../../models/bank_account_model.dart';
import '../../services/party_service.dart';
import '../../services/item_service.dart';
import '../../services/bank_account_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';
```

## Step 2: Add State Variables

In the `_CreateQuotationScreenState` class, add these state variables:

```dart
// Party and Items
PartyModel? _selectedParty;
List<QuotationItem> _quotationItems = [];

// Bank Accounts
BankAccount? _selectedBankAccount;
List<BankAccount> _bankAccounts = [];

// Discount and Charges
double _discountAmount = 0;
double _additionalCharges = 0;

bool _isLoading = false;
```

## Step 3: Create QuotationItem Class

Add this class before the `_CreateQuotationScreenState` class:

```dart
class QuotationItem {
  final ItemModel item;
  double quantity;
  double pricePerUnit;
  double discountPercent;
  double taxPercent;

  QuotationItem({
    required this.item,
    this.quantity = 1,
    double? pricePerUnit,
    this.discountPercent = 0,
    double? taxPercent,
  })  : pricePerUnit = pricePerUnit ?? item.sellingPrice,
        taxPercent = taxPercent ?? item.gstRate;

  double get subtotal => quantity * pricePerUnit;
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get lineTotal => taxableAmount + taxAmount;
}
```

## Step 4: Add initState to Load Bank Accounts

```dart
@override
void initState() {
  super.initState();
  _loadBankAccounts();
}

Future<void> _loadBankAccounts() async {
  setState(() => _isLoading = true);
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);

    if (orgProvider.selectedOrganization == null) {
      setState(() => _isLoading = false);
      return;
    }

    final token = await authProvider.token;
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final bankAccountService = BankAccountService();
    final accounts = await bankAccountService.getBankAccounts(
      token,
      orgProvider.selectedOrganization!.id,
    );
    
    setState(() {
      _bankAccounts = accounts;
      if (accounts.isNotEmpty) {
        _selectedBankAccount = accounts.first;
      }
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bank accounts: $e')),
      );
    }
  }
}
```

## Step 5: Add Party Selection Method

```dart
Future<void> _showPartySelectionDialog() async {
  final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);

  if (orgProvider.selectedOrganization == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an organization first')),
    );
    return;
  }

  final partyService = PartyService();

  try {
    final parties = await partyService.getParties(
      orgProvider.selectedOrganization!.id,
    );

    if (!mounted) return;

    final selectedParty = await showDialog<PartyModel>(
      context: context,
      builder: (context) => _PartySearchDialog(parties: parties),
    );

    if (selectedParty != null) {
      setState(() => _selectedParty = selectedParty);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading parties: $e')),
      );
    }
  }
}
```

## Step 6: Add Item Selection Method

```dart
Future<void> _showItemSelectionDialog() async {
  final orgProvider = Provider.of<OrganizationProvider>(context, listen: false);

  if (orgProvider.selectedOrganization == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an organization first')),
    );
    return;
  }

  final itemService = ItemService();

  try {
    final items = await itemService.getItems(
      orgProvider.selectedOrganization!.id,
    );

    if (!mounted) return;

    final selectedItem = await showDialog<ItemModel>(
      context: context,
      builder: (context) => _ItemSearchDialog(items: items),
    );

    if (selectedItem != null) {
      setState(() {
        _quotationItems.add(QuotationItem(item: selectedItem));
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }
}
```

## Step 7: Add Discount Dialog

```dart
Future<void> _showDiscountDialog() async {
  final controller = TextEditingController(text: _discountAmount.toString());
  
  final result = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Discount'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Discount Amount',
          prefixText: '₹ ',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(controller.text) ?? 0;
            Navigator.pop(context, amount);
          },
          child: const Text('Apply'),
        ),
      ],
    ),
  );

  if (result != null) {
    setState(() => _discountAmount = result);
  }
}
```

## Step 8: Add Additional Charges Dialog

```dart
Future<void> _showAdditionalChargesDialog() async {
  final controller = TextEditingController(text: _additionalCharges.toString());
  
  final result = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Additional Charges'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Additional Charges',
          prefixText: '₹ ',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(controller.text) ?? 0;
            Navigator.pop(context, amount);
          },
          child: const Text('Apply'),
        ),
      ],
    ),
  );

  if (result != null) {
    setState(() => _additionalCharges = result);
  }
}
```

## Step 9: Copy Search Dialog Widgets

At the end of the file (before the closing brace), copy these two widget classes from `create_sales_invoice_screen.dart`:

1. `_PartySearchDialog` - The searchable party selection dialog
2. `_ItemSearchDialog` - The searchable item selection dialog

You can find these at the end of the `create_sales_invoice_screen.dart` file (lines ~1305-1550).

## Step 10: Update Calculations

Add these getter methods for calculations:

```dart
double get _subtotal =>
    _quotationItems.fold(0, (sum, item) => sum + item.subtotal);
    
double get _totalDiscount =>
    _quotationItems.fold(0, (sum, item) => sum + item.discountAmount) + _discountAmount;
    
double get _totalTax =>
    _quotationItems.fold(0, (sum, item) => sum + item.taxAmount);
    
double get _totalAmount =>
    _subtotal - _discountAmount + _totalTax + _additionalCharges;
```

## Step 11: Update UI Elements

### Bill To Section:
Replace the "+ Add Party" button's onTap with:
```dart
onTap: _showPartySelectionDialog
```

### Items Table:
Replace the "+ Add Item" button's onTap with:
```dart
onTap: _showItemSelectionDialog
```

### Add Discount Button:
```dart
TextButton.icon(
  onPressed: _showDiscountDialog,
  icon: const Icon(Icons.add, size: 18),
  label: const Text('Add Discount'),
)
```

### Add Additional Charges Button:
```dart
TextButton.icon(
  onPressed: _showAdditionalChargesDialog,
  icon: const Icon(Icons.add, size: 18),
  label: const Text('Add Additional Charges'),
)
```

### Bank Details Section:
Update to use `_selectedBankAccount` and `_bankAccounts` from state instead of hardcoded values.

## Testing Checklist

After implementation, test:
- [ ] Party selection with search
- [ ] Item selection with search
- [ ] Bank account dropdown shows real accounts
- [ ] Discount dialog opens and applies discount
- [ ] Additional charges dialog opens and applies charges
- [ ] Total calculations are correct
- [ ] Save functionality works

## Notes

- The quotation screen doesn't need payment tracking (unlike sales invoice)
- Bank details are shown for reference only
- All calculations should update in real-time
- Search is case-insensitive and searches multiple fields

## Need Help?

If you encounter any issues:
1. Check that all imports are added
2. Verify Provider is set up in your app
3. Ensure models (PartyModel, ItemModel, BankAccount) exist
4. Check that services (PartyService, ItemService, BankAccountService) are implemented
