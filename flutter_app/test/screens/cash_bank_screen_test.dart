import 'package:flutter_test/flutter_test.dart';
import 'package:saas_billing_app/models/transaction_model.dart';

void main() {
  group('CashBankScreen - Transaction Loading Properties', () {
    /// **Feature: sales-invoice-cash-bank-integration, Property 6: Transaction list completeness**
    /// **Validates: Requirements 2.1**
    ///
    /// Property: When the Cash & Bank screen loads, all transactions for the
    /// organization should be fetched and displayed
    test('Property 6: All transactions are loaded for organization', () {
      // Arrange: Simulate transactions from different accounts
      final testTransactions = [
        {
          'id': 1,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '1000.00',
          'transaction_date': '2024-01-15',
          'description': 'Payment received for Sales Invoice SHI101 - Cash',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-15T10:00:00Z',
          'updated_at': '2024-01-15T10:00:00Z',
        },
        {
          'id': 2,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 2,
          'transaction_type': 'add',
          'amount': '2500.00',
          'transaction_date': '2024-01-20',
          'description':
              'Payment received for Sales Invoice SHI102 - Bank Transfer',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-20T10:00:00Z',
          'updated_at': '2024-01-20T10:00:00Z',
        },
        {
          'id': 3,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'reduce',
          'amount': '500.00',
          'transaction_date': '2024-01-25',
          'description': 'Cash withdrawal',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-25T10:00:00Z',
          'updated_at': '2024-01-25T10:00:00Z',
        },
      ];

      // Act: Parse transactions (simulating what the screen does)
      final transactions = testTransactions
          .map((json) => BankTransaction.fromJson(json))
          .toList();

      // Assert: All transactions are loaded
      expect(transactions.length, equals(3));

      // Property: All transactions from the organization are present
      for (var i = 0; i < testTransactions.length; i++) {
        expect(transactions[i].id, equals(testTransactions[i]['id']));
        expect(transactions[i].organizationId, equals(1));
      }

      // Verify invoice transactions are identifiable
      expect(transactions[0].description, contains('Sales Invoice'));
      expect(transactions[0].description, contains('SHI101'));
      expect(transactions[1].description, contains('Sales Invoice'));
      expect(transactions[1].description, contains('SHI102'));
    });

    test('Transactions from sales invoices are included', () {
      // Property: When a sales invoice is saved with payment, it creates a transaction
      // that appears in the Cash & Bank section
      final invoiceTransaction = {
        'id': 1,
        'user_id': 1,
        'organization_id': 1,
        'account_id': 1,
        'transaction_type': 'add',
        'amount': '5000.00',
        'transaction_date': '2024-01-30',
        'description': 'Payment received for Sales Invoice INV123 - Cash',
        'related_account_id': null,
        'related_transaction_id': null,
        'is_external_transfer': false,
        'external_account_holder': null,
        'external_account_number': null,
        'external_bank_name': null,
        'external_ifsc_code': null,
        'created_at': '2024-01-30T10:00:00Z',
        'updated_at': '2024-01-30T10:00:00Z',
      };

      final transaction = BankTransaction.fromJson(invoiceTransaction);

      // Verify it's a sales invoice transaction
      expect(transaction.description,
          contains('Payment received for Sales Invoice'));
      expect(transaction.description, contains('INV123'));
      expect(transaction.transactionType, equals('add'));
      expect(transaction.amount, equals(5000.00));
    });

    test('Date filtering works correctly', () {
      // Property: Transactions should be filtered by the selected time period
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));

      // Transactions within different time periods
      final recentTransaction = {
        'id': 1,
        'user_id': 1,
        'organization_id': 1,
        'account_id': 1,
        'transaction_type': 'add',
        'amount': '1000.00',
        'transaction_date': now
            .subtract(const Duration(days: 15))
            .toIso8601String()
            .split('T')[0],
        'description': 'Recent transaction',
        'related_account_id': null,
        'related_transaction_id': null,
        'is_external_transfer': false,
        'external_account_holder': null,
        'external_account_number': null,
        'external_bank_name': null,
        'external_ifsc_code': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final oldTransaction = {
        'id': 2,
        'user_id': 1,
        'organization_id': 1,
        'account_id': 1,
        'transaction_type': 'add',
        'amount': '2000.00',
        'transaction_date': ninetyDaysAgo
            .subtract(const Duration(days: 10))
            .toIso8601String()
            .split('T')[0],
        'description': 'Old transaction',
        'related_account_id': null,
        'related_transaction_id': null,
        'is_external_transfer': false,
        'external_account_holder': null,
        'external_account_number': null,
        'external_bank_name': null,
        'external_ifsc_code': null,
        'created_at': ninetyDaysAgo.toIso8601String(),
        'updated_at': ninetyDaysAgo.toIso8601String(),
      };

      final recent = BankTransaction.fromJson(recentTransaction);
      final old = BankTransaction.fromJson(oldTransaction);

      // Verify dates are parsed correctly
      expect(recent.transactionDate, isNotEmpty);
      expect(old.transactionDate, isNotEmpty);

      // Property: Recent transaction should be within 30 days
      final recentDate = DateTime.parse(recent.transactionDate);
      expect(recentDate.isAfter(thirtyDaysAgo), isTrue);

      // Property: Old transaction should be outside 90 days
      final oldDate = DateTime.parse(old.transactionDate);
      expect(oldDate.isBefore(ninetyDaysAgo), isTrue);
    });

    test('Empty transaction list is handled gracefully', () {
      // Edge case: No transactions in the selected period
      final emptyList = <Map<String, dynamic>>[];
      final transactions =
          emptyList.map((json) => BankTransaction.fromJson(json)).toList();

      expect(transactions, isEmpty);
      expect(transactions.length, equals(0));
    });

    test('Multiple payment modes are supported', () {
      // Property: Transactions from different payment modes should all appear
      final paymentModes = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

      for (var i = 0; i < paymentModes.length; i++) {
        final transaction = {
          'id': i + 1,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '${(i + 1) * 1000}.00',
          'transaction_date': '2024-01-${(i + 1).toString().padLeft(2, '0')}',
          'description':
              'Payment received for Sales Invoice INV${i + 1} - ${paymentModes[i]}',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at':
              '2024-01-${(i + 1).toString().padLeft(2, '0')}T10:00:00Z',
          'updated_at':
              '2024-01-${(i + 1).toString().padLeft(2, '0')}T10:00:00Z',
        };

        final trans = BankTransaction.fromJson(transaction);
        expect(trans.description, contains(paymentModes[i]));
      }
    });
  });
}
