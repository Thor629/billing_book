import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_config.dart';
import '../models/bank_account_model.dart';
import '../models/transaction_model.dart';

class BankAccountService {
  Future<List<BankAccount>> getBankAccounts(
      String token, int? organizationId) async {
    final url = organizationId != null
        ? '${AppConfig.apiBaseUrl}/bank-accounts?organization_id=$organizationId'
        : '${AppConfig.apiBaseUrl}/bank-accounts';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BankAccount.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bank accounts');
    }
  }

  Future<BankAccount> createBankAccount(
      String token, BankAccount account) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/bank-accounts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(account.toJson()),
    );

    if (response.statusCode == 201) {
      return BankAccount.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create bank account');
    }
  }

  Future<BankAccount> updateBankAccount(
      String token, int id, BankAccount account) async {
    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/bank-accounts/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(account.toJson()),
    );

    if (response.statusCode == 200) {
      return BankAccount.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update bank account');
    }
  }

  Future<void> deleteBankAccount(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.apiBaseUrl}/bank-accounts/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete bank account');
    }
  }

  Future<BankTransaction> addTransaction(
      String token, BankTransaction transaction) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/bank-transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode == 201) {
      return BankTransaction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add transaction');
    }
  }

  Future<Map<String, dynamic>> transferMoney({
    required String token,
    required int fromAccountId,
    int? toAccountId,
    required double amount,
    required String date,
    String? description,
    bool isExternal = false,
    String? externalAccountHolder,
    String? externalAccountNumber,
    String? externalBankName,
    String? externalIfscCode,
  }) async {
    final Map<String, dynamic> body = {
      'from_account_id': fromAccountId,
      'amount': amount,
      'transaction_date': date,
      'description': description,
      'is_external_transfer': isExternal,
    };

    if (isExternal) {
      body['external_account_holder'] = externalAccountHolder;
      body['external_account_number'] = externalAccountNumber;
      body['external_bank_name'] = externalBankName;
      body['external_ifsc_code'] = externalIfscCode;
    } else {
      body['to_account_id'] = toAccountId;
    }

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/bank-transactions/transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to transfer money');
    }
  }

  Future<List<BankTransaction>> getTransactions(
    String token,
    int accountId,
    String? startDate,
    String? endDate,
  ) async {
    String url =
        '${AppConfig.apiBaseUrl}/bank-transactions?account_id=$accountId';
    if (startDate != null) url += '&start_date=$startDate';
    if (endDate != null) url += '&end_date=$endDate';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BankTransaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
