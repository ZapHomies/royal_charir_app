import '../../../../core/api/api_client.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSource({required this.apiClient});

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await apiClient.get('/api/v1/users');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<void> syncUsers(List<Map<String, dynamic>> users) async {
    await apiClient.post('/api/v1/users/batch-sync', data: {'users': users});
  }
}
