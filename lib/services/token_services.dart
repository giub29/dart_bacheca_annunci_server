import 'dart:convert';
import 'dart:math';

class TokenService {
  final Map<String, int> _tokens = {};
  final Random _random = Random.secure();

  String issue(int aziendaId) {
    final bytes = List<int>.generate(
      32,
          (_) => _random.nextInt(256),
    );

    final token = base64Url.encode(bytes).replaceAll('=', '');

    _tokens[token] = aziendaId;

    return token;
  }

  int? aziendaIdFor(String token) {
    return _tokens[token];
  }

  void revoke(String token) {
    _tokens.remove(token);
  }
}