# Barcode & QR Code Implementation Guide

## Overview

The project has barcode/QR code functionality placeholders in multiple screens that need to be implemented.

## Locations Found

### 1. Items Screen - Generate Barcode
**File:** `create_item_screen.dart`
- Button: "Generate Barcode"
- Purpose: Generate unique barcode for items
- Current: Generates item code, needs actual barcode generation

### 2. Sales Invoice - Scan Barcode
**File:** `create_sales_invoice_screen.dart`
- Icon button in app bar
- Button in item selection
- Purpose: Scan item barcodes to add to invoice

### 3. Quotation - Scan Barcode
**File:** `create_quotation_screen.dart`
- Icon button in app bar
- Button in item selection
- Purpose: Scan item barcodes to add to quotation

### 4. Sales Return - Scan Barcode
**File:** `create_sales_return_screen.dart`
- Icon button in app bar
- Button in item selection
- Purpose: Scan item barcodes for returns

### 5. Purchase Return - Scan Barcode
**File:** `create_purchase_return_screen.dart`
- Icon button in app bar
- Button in item selection
- Purpose: Scan item barcodes for returns

### 6. Credit Note - Scan Barcode
**File:** `create_credit_note_screen.dart`
- Button in item selection
- Purpose: Scan item barcodes

### 7. Payment In - QR Scanner
**File:** `create_payment_in_screen.dart`
- Icon button in app bar
- Purpose: Scan QR codes for payment

## Required Packages

Add to `flutter_app/pubspec.yaml`:

```yaml
dependencies:
  # Barcode generation
  barcode_widget: ^2.0.4
  
  # QR code generation
  qr_flutter: ^4.1.0
  
  # Barcode/QR scanning
  mobile_scanner: ^3.5.5
  
  # For generating unique codes
  uuid: ^4.2.2
```

## Implementation Steps

### Step 1: Add Packages

```bash
cd flutter_app
flutter pub add barcode_widget qr_flutter mobile_scanner uuid
```

### Step 2: Create Barcode Generator Utility

Create `flutter_app/lib/utils/barcode_generator.dart`:

```dart
import 'package:uuid/uuid.dart';

class BarcodeGenerator {
  static String generateItemCode() {
    final uuid = Uuid();
    final code = uuid.v4().substring(0, 8).toUpperCase();
    return 'ITM-$code';
  }

  static String generateEAN13() {
    // Generate 12 random digits
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final code = random.substring(random.length - 12);
    
    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checkDigit = (10 - (sum % 10)) % 10;
    
    return code + checkDigit.toString();
  }

  static String generateCode128(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix${timestamp % 1000000}';
  }
}
```

### Step 3: Create Barcode Scanner Screen

Create `flutter_app/lib/screens/user/barcode_scanner_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue);
              return;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
```

### Step 4: Create Barcode Display Widget

Create `flutter_app/lib/widgets/barcode_display.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeDisplay extends StatelessWidget {
  final String data;
  final BarcodeType type;
  final double width;
  final double height;

  const BarcodeDisplay({
    super.key,
    required this.data,
    this.type = BarcodeType.Code128,
    this.width = 200,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return BarcodeWidget(
      barcode: Barcode.code128(),
      data: data,
      width: width,
      height: height,
      drawText: true,
    );
  }
}
```

### Step 5: Update Create Item Screen

In `create_item_screen.dart`, update the Generate Barcode button:

```dart
ElevatedButton(
  onPressed: () {
    final barcode = BarcodeGenerator.generateEAN13();
    _barcodeController.text = barcode;
    _itemCodeController.text = BarcodeGenerator.generateItemCode();
    
    // Show barcode preview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Barcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeDisplay(data: barcode),
            const SizedBox(height: 16),
            Text('Barcode: $barcode'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  },
  child: const Text('Generate Barcode'),
)
```

### Step 6: Update Invoice/Quotation Screens

Add scanner functionality:

```dart
IconButton(
  icon: const Icon(Icons.qr_code_scanner),
  onPressed: () async {
    final barcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );
    
    if (barcode != null) {
      // Find item by barcode and add to list
      _findAndAddItemByBarcode(barcode);
    }
  },
)
```

## Features

### Generate Barcode
- ✅ EAN-13 format (standard retail)
- ✅ Code 128 format (flexible)
- ✅ Unique item codes
- ✅ Visual preview
- ✅ Auto-fill item code field

### Scan Barcode
- ✅ Camera scanner
- ✅ Torch/flash control
- ✅ Camera switch
- ✅ Auto-detect and return
- ✅ Support multiple formats

### Display Barcode
- ✅ Visual barcode widget
- ✅ Multiple formats
- ✅ Customizable size
- ✅ Text display

## Testing

1. **Generate Barcode:**
   - Go to Create Item
   - Click "Generate Barcode"
   - See barcode preview
   - Barcode saved to item

2. **Scan Barcode:**
   - Go to Create Invoice
   - Click scanner icon
   - Scan item barcode
   - Item added to invoice

3. **View Barcode:**
   - View item details
   - See barcode displayed
   - Can scan with phone

## Benefits

✅ **Faster Data Entry** - Scan instead of type
✅ **Reduce Errors** - No manual entry mistakes
✅ **Professional** - Standard barcode formats
✅ **Inventory Management** - Track items easily
✅ **Mobile Friendly** - Works on phones/tablets

## Next Steps

1. Install packages
2. Create utility files
3. Update screens
4. Test functionality
5. Add to items database

Ready to implement! Just need to add the packages and create the files.
