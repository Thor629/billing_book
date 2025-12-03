import 'dart:convert';
import '../models/credit_note_model.dart';
import 'api_client.dart';

class CreditNoteService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getCreditNotes({
    required int organizationId,
    String? dateFilter,
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
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final queryString = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get('/credit-notes?$queryString');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'credit_notes': (data['credit_notes']['data'] as List)
              .map((json) => CreditNote.fromJson(json))
              .toList(),
          'pagination': {
            'current_page': data['credit_notes']['current_page'],
            'last_page': data['credit_notes']['last_page'],
            'total': data['credit_notes']['total'],
          },
        };
      } else {
        throw Exception('Failed to load credit notes');
      }
    } catch (e) {
      throw Exception('Error fetching credit notes: $e');
    }
  }

  Future<CreditNote> getCreditNote(int id) async {
    try {
      final response = await _apiClient.get('/credit-notes/$id');

      if (response.statusCode == 200) {
        return CreditNote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load credit note');
      }
    } catch (e) {
      throw Exception('Error fetching credit note: $e');
    }
  }

  Future<CreditNote> createCreditNote(
      Map<String, dynamic> creditNoteData) async {
    try {
      final response = await _apiClient.post('/credit-notes', creditNoteData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return CreditNote.fromJson(data['credit_note']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create credit note');
      }
    } catch (e) {
      throw Exception('Error creating credit note: $e');
    }
  }

  Future<CreditNote> updateCreditNote(
      int id, Map<String, dynamic> creditNoteData) async {
    try {
      final response =
          await _apiClient.put('/credit-notes/$id', creditNoteData);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CreditNote.fromJson(data['credit_note']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update credit note');
      }
    } catch (e) {
      throw Exception('Error updating credit note: $e');
    }
  }

  Future<void> deleteCreditNote(int id) async {
    try {
      final response = await _apiClient.delete('/credit-notes/$id');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete credit note');
      }
    } catch (e) {
      throw Exception('Error deleting credit note: $e');
    }
  }

  Future<Map<String, dynamic>> getNextCreditNoteNumber(
      int organizationId) async {
    try {
      final response = await _apiClient
          .get('/credit-notes/next-number?organization_id=$organizationId');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get next credit note number');
      }
    } catch (e) {
      throw Exception('Error fetching next credit note number: $e');
    }
  }
}
