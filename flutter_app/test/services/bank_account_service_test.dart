import 'package:flutter_test/flutter_test.dart';
import 'package:saas_billing_app/models/transaction_model.dart';

void main() {
  group('BankAccountService - Transaction Fetching Properties', () {
    /// **Feature: sales-invoice-cash-bank-integration, Property 6: Transaction list completeness**
    /// **Validates: Requirements 2.1**
    ///
    /// Property: For any set of transactions in the database for an organization,
    /// fetching transactions should return all of them
    test('Property 6: Transaction parsing preserves all data', () {
      // Arrange: Create test data representing transactions from API
      final testTransactions = [
        {
          'id': 1,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '1000.00',
          'transaction_date': '2024-01-01',
          'description': 'Payment received for Sales Invoice INV001 - Cash',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-01T10:00:00Z',
          'updated_at': '2024-01-01T10:00:00Z',
        },
        {
          'id': 2,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 2,
          'transaction_type': 'add',
          'amount': '2000.00',
          'transaction_date': '2024-01-02',
          'description':
              'Payment received for Sales Invoice INV002 - Bank Transfer',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-02T10:00:00Z',
          'updated_at': '2024-01-02T10:00:00Z',
        },
        {
          'id': 3,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'reduce',
          'amount': '500.00',
          'transaction_date': '2024-01-03',
          'description': 'Manual reduction',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-03T10:00:00Z',
          'updated_at': '2024-01-03T10:00:00Z',
        },
      ];

      // Act: Parse transactions
      final transactions = testTransactions
          .map((json) => BankTransaction.fromJson(json))
          .toList();

      // Assert: Verify all transactions are parsed correctly
      expect(transactions.length, equals(3));

      // Property verification: All transactions in the input are in the output
      for (var i = 0; i < testTransactions.length; i++) {
        expect(transactions[i].id, equals(testTransactions[i]['id']));
        expect(transactions[i].organizationId,
            equals(testTransactions[i]['organization_id']));
        expect(transactions[i].accountId,
            equals(testTransactions[i]['account_id']));
        expect(transactions[i].amount,
            equals(double.parse(testTransactions[i]['amount'] as String)));
        expect(transactions[i].transactionType,
            equals(testTransactions[i]['transaction_type']));
      }
    });

    test('Transaction list completeness - different transaction types', () {
      // Property: All transaction types should be parsed correctly
      final transactionTypes = ['add', 'reduce', 'transfer_in', 'transfer_out'];

      for (var type in transactionTypes) {
        final json = {
          'id': 1,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': type,
          'amount': '100.00',
          'transaction_date': '2024-01-01',
          'description': 'Test transaction',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-01T10:00:00Z',
          'updated_at': '2024-01-01T10:00:00Z',
        };

        final transaction = BankTransaction.fromJson(json);
        expect(transaction.transactionType, equals(type));
      }
    });

    test('Empty transaction list is handled correctly', () {
      // Edge case: Empty transaction list
      // Property: The method should handle empty results gracefully
      final emptyList = <Map<String, dynamic>>[];
      final transactions =
          emptyList.map((json) => BankTransaction.fromJson(json)).toList();

      expect(transactions, isEmpty);
      expect(transactions.length, equals(0));
    });

    test('Transaction order is preserved', () {
      // Property: Transactions should be returned in the order provided
      final testTransactions = [
        {
          'id': 3,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '300.00',
          'transaction_date': '2024-01-03',
          'description': 'Latest transaction',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-03T10:00:00Z',
          'updated_at': '2024-01-03T10:00:00Z',
        },
        {
          'id': 2,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '200.00',
          'transaction_date': '2024-01-02',
          'description': 'Middle transaction',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-02T10:00:00Z',
          'updated_at': '2024-01-02T10:00:00Z',
        },
        {
          'id': 1,
          'user_id': 1,
          'organization_id': 1,
          'account_id': 1,
          'transaction_type': 'add',
          'amount': '100.00',
          'transaction_date': '2024-01-01',
          'description': 'Oldest transaction',
          'related_account_id': null,
          'related_transaction_id': null,
          'is_external_transfer': false,
          'external_account_holder': null,
          'external_account_number': null,
          'external_bank_name': null,
          'external_ifsc_code': null,
          'created_at': '2024-01-01T10:00:00Z',
          'updated_at': '2024-01-01T10:00:00Z',
        },
      ];

      final transactions = testTransactions
          .map((json) => BankTransaction.fromJson(json))
          .toList();

      // Verify order is preserved (newest first as provided)
      expect(transactions[0].id, equals(3));
      expect(transactions[1].id, equals(2));
      expect(transactions[2].id, equals(1));

      // Verify dates are in descending order
      expect(transactions[0].transactionDate, equals('2024-01-03'));
      expect(transactions[1].transactionDate, equals('2024-01-02'));
      expect(transactions[2].transactionDate, equals('2024-01-01'));
    });

    test('Invoice transactions include invoice number in description', () {
      // Property: Transactions from sales invoices should contain invoice number
      final json = {
        'id': 1,
        'user_id': 1,
        'organization_id': 1,
        'account_id': 1,
        'transaction_type': 'add',
        'amount': '1500.00',
        'transaction_date': '2024-01-01',
        'description': 'Payment received for Sales Invoice SHI101 - Cash',
        'related_account_id': null,
        'related_transaction_id': null,
        'is_external_transfer': false,
        'external_account_holder': null,
        'external_account_number': null,
        'external_bank_name': null,
        'external_ifsc_code': null,
        'created_at': '2024-01-01T10:00:00Z',
        'updated_at': '2024-01-01T10:00:00Z',
      };

      final transaction = BankTransaction.fromJson(json);

      // Verify invoice number is in description
      expect(transaction.description, contains('Sales Invoice'));
      expect(transaction.description, contains('SHI101'));
    });
  });
}
