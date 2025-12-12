import 'dart:math';

class BarcodeGenerator {
  /// Generate a unique item code
  static String generateItemCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'ITM-${timestamp.toString().substring(7)}-$random';
  }

  /// Generate EAN-13 barcode (13 digits)
  static String generateEAN13() {
    // Generate 12 random digits
    final random = Random();
    String code = '';
    for (int i = 0; i < 12; i++) {
      code += random.nextInt(10).toString();
    }

    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(code[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checkDigit = (10 - (sum % 10)) % 10;

    return code + checkDigit.toString();
  }

  /// Generate Code128 barcode with prefix
  static String generateCode128(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return '$prefix${timestamp % 1000000}$random';
  }

  /// Generate simple numeric barcode
  static String generateNumericBarcode({int length = 12}) {
    final random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  /// Validate EAN-13 barcode
  static bool validateEAN13(String barcode) {
    if (barcode.length != 13) return false;

    try {
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        int digit = int.parse(barcode[i]);
        sum += (i % 2 == 0) ? digit : digit * 3;
      }
      int checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == int.parse(barcode[12]);
    } catch (e) {
      return false;
    }
  }
}
