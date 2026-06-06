import '../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;
  static const _loginUrl = 'https://dummyjson.com/auth/login';

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _apiClient.post(_loginUrl, {
      'username': username,
      'password': password,
    });

    if (response is! Map<String, dynamic>) {
      throw Exception('Resposta de login inválida.');
    }

    return UserModel.fromJson(response);
  }
}
