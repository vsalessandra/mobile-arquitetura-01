import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/failures.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerFailure(
          _parseErrorMessage(response.body, 'Erro ao consultar API. Status: ${response.statusCode}'),
        );
      }

      return jsonDecode(response.body);
    } on http.ClientException catch (error) {
      throw NetworkFailure('Falha de conexão: ${error.message}');
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ServerFailure('Erro inesperado ao consultar a API.');
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerFailure(
          _parseErrorMessage(response.body, 'Erro ao realizar requisição. Status: ${response.statusCode}'),
        );
      }

      return jsonDecode(response.body);
    } on http.ClientException catch (error) {
      throw NetworkFailure('Falha de conexão: ${error.message}');
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ServerFailure('Erro inesperado na requisição.');
    }
  }

  String _parseErrorMessage(String body, String defaultMessage) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return defaultMessage;
  }

  Future<List<dynamic>> getList(String url) async {
    final response = await get(url);
    if (response is! List<dynamic>) {
      throw ServerFailure('Resposta inválida da API (esperava uma lista).');
    }
    return response;
  }
}
