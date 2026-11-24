import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../dao/azienda_dao.dart';
import '../middleware/error_middleware.dart';
import '../services/password_service.dart';
import '../utils/validators.dart';
import '../errors/api_exception.dart';
import '../services/token_service.dart';
import '../middleware/auth_middleware.dart';

class AuthController {
  final AziendaDao aziende;
  final TokenService tokens;

  AuthController(this.aziende, this.tokens);

  Router get router {
    final router = Router();

    router.post('/api/auth/register', _register);
    router.post('/api/auth/login', _login);
    router.post('/api/auth/logout', guard(_logout));
    router.get('/api/auth/me', guard(_me));

    return router;
  }

  Future<Response> _register(Request request) async {
    final body = await readJsonObject(request);
    final input = validateRegister(body);

    final salt = PasswordService.generateSalt();

    final passwordHash = PasswordService.hash(
      input.password,
      salt,
    );

    final azienda = await aziende.create(
      nome: input.nome,
      email: input.email,
      passwordHash: passwordHash,
      salt: salt,
    );

    return jsonResponse(
      azienda.toPublicJson(),
      status: 201,
    );
  }

  Future<Response> _login(Request request) async {
    final body = await readJsonObject(request);

    final email = body['email'];
    final password = body['password'];

    if (email is! String || password is! String) {
      throw const ApiException(
        422,
        'Email e password obbligatorie.',
      );
    }

    if (email.trim().isEmpty || password.isEmpty) {
      throw const ApiException(
        422,
        'Email e password obbligatorie.',
      );
    }

    final azienda = aziende.findByEmail(email);

    if (azienda == null) {
      throw const ApiException(401, 'Credenziali non valide.');
    }

    final passwordCorretta = PasswordService.verify(
      password,
      azienda.salt,
      azienda.passwordHash,
    );

    if (!passwordCorretta) {
      throw const ApiException(401, 'Credenziali non valide.');
    }

    final token = tokens.issue(azienda.id);

    return jsonResponse({
      'token': token,
      'azienda': azienda.toPublicJson(),
    });
  }

  Response _me(Request request) {
    final azienda = currentAzienda(request)!;

    return jsonResponse(azienda.toPublicJson());
  }

  Response _logout(Request request) {
    final token = currentToken(request)!;

    tokens.revoke(token);

    return Response(204);
  }
}