import 'dart:convert';
import '../models/expense_model.dart';
import 'api_client.dart';

class ExpenseService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getExpenses({
    required int organizationId,
    String? dateFilter,
    String? category,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{
        'organization_id': organizationId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
      if (category != null) queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      print('DEBUG ExpenseService: Calling /expenses?$queryString');
      final response = await _apiClient.get('/expenses?$queryString');

      print('DEBUG ExpenseService: Response status: ${response.statusCode}');
      print('DEBUG ExpenseService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both paginated and direct array response
        List<Expense> expenses;
        if (data is Map && data.containsKey('expenses')) {
          expenses = (data['expenses']['data'] as List)
              .map((json) => Expense.fromJson(json))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          expenses = (data['data'] as List)
              .map((json) => Expense.fromJson(json))
              .toList();
        } else {
          expenses = [];
        }

        return {
          'expenses': expenses,
          'summary': data['summary'] ?? {'total_expenses': 0, 'total_count': 0},
          'pagination': {
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'total': data['total'] ?? 0,
          },
        };
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG ExpenseService: Error: $e');
      throw Exception('Error fetching expenses: $e');
    }
  }

  Future<Expense> getExpense(int id) async {
    try {
      final response = await _apiClient.get('/expenses/$id');

      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load expense');
      }
    } catch (e) {
      throw Exception('Error fetching expense: $e');
    }
  }

  Future<Expense> createExpense(Map<String, dynamic> expenseData) async {
    try {
      print('DEBUG: Creating expense with data: $expenseData');
      final response = await _apiClient.post('/expenses', expenseData);
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Expense.fromJson(data['expense']);
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(error['message'] ??
              'Failed to create expense (${response.statusCode})');
        } catch (e) {
          throw Exception(
              'Failed to create expense (${response.statusCode}): ${response.body}');
        }
      }
    } catch (e) {
      print('DEBUG: Error in createExpense: $e');
      throw Exception('Error creating expense: $e');
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final response = await _apiClient.delete('/expenses/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete expense');
      }
    } catch (e) {
      throw Exception('Error deleting expense: $e');
    }
  }

  Future<int> getNextExpenseNumber(int organizationId) async {
    try {
      final response = await _apiClient
          .get('/expenses/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['next_number'];
      } else {
        throw Exception('Failed to get next expense number');
      }
    } catch (e) {
      throw Exception('Error fetching next expense number: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/expenses/categories');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['categories']);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<dynamic>> getBankAccounts(int organizationId) async {
    try {
      final response = await _apiClient
          .get('/bank-accounts?organization_id=$organizationId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['accounts'] as List;
      } else {
        throw Exception('Failed to load bank accounts');
      }
    } catch (e) {
      throw Exception('Error fetching bank accounts: $e');
    }
  }
}
