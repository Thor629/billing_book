import 'dart:convert';
import '../models/debit_note_model.dart';
import 'api_client.dart';

class DebitNoteService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDebitNotes({
    required int organizationId,
    String? dateFilter,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (dateFilter != null) queryParams['date_filter'] = dateFilter;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '/debit-notes?$queryString',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'debit_notes': (data['data'] as List)
              .map((json) => DebitNote.fromJson(json))
              .toList(),
          'pagination': {
            'current_page': data['current_page'],
            'last_page': data['last_page'],
            'total': data['total'],
          },
        };
      } else {
        throw Exception('Failed to load debit notes');
      }
    } catch (e) {
      throw Exception('Error fetching debit notes: $e');
    }
  }

  Future<DebitNote> getDebitNote(int id, int organizationId) async {
    try {
      final response = await _apiClient.get(
        '/debit-notes/$id',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        return DebitNote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load debit note');
      }
    } catch (e) {
      throw Exception('Error fetching debit note: $e');
    }
  }

  Future<DebitNote> createDebitNote(
      int organizationId, Map<String, dynamic> debitNoteData) async {
    try {
      final response = await _apiClient.post(
        '/debit-notes',
        debitNoteData,
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return DebitNote.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create debit note');
      }
    } catch (e) {
      throw Exception('Error creating debit note: $e');
    }
  }

  Future<void> deleteDebitNote(int id, int organizationId) async {
    try {
      final response = await _apiClient.delete(
        '/debit-notes/$id',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete debit note');
      }
    } catch (e) {
      throw Exception('Error deleting debit note: $e');
    }
  }

  Future<Map<String, dynamic>> getNextDebitNoteNumber(
      int organizationId) async {
    try {
      final response = await _apiClient.get(
        '/debit-notes/next-number',
        customHeaders: {'X-Organization-Id': organizationId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next debit note number');
      }
    } catch (e) {
      throw Exception('Error fetching next debit note number: $e');
    }
  }
}
