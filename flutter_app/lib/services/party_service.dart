import '../models/party_model.dart';
import 'api_client.dart';

class PartyService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PartyModel>> getParties(int organizationId) async {
    final response =
        await _apiClient.get('/parties?organization_id=$organizationId');
    final data = _apiClient.handleResponse(response);

    final List<dynamic> partiesJson = data['data'];
    return partiesJson.map((json) => PartyModel.fromJson(json)).toList();
  }

  Future<PartyModel> createParty(Map<String, dynamic> partyData) async {
    final response = await _apiClient.post('/parties', partyData);
    final data = _apiClient.handleResponse(response);
    return PartyModel.fromJson(data['party']);
  }

  Future<PartyModel> getParty(int id) async {
    final response = await _apiClient.get('/parties/$id');
    final data = _apiClient.handleResponse(response);
    return PartyModel.fromJson(data['party']);
  }

  Future<PartyModel> updateParty(int id, Map<String, dynamic> partyData) async {
    final response = await _apiClient.put('/parties/$id', partyData);
    final data = _apiClient.handleResponse(response);
    return PartyModel.fromJson(data['party']);
  }

  Future<void> deleteParty(int id) async {
    final response = await _apiClient.delete('/parties/$id');
    _apiClient.handleResponse(response);
  }
}
