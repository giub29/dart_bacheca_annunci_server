import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../dao/azienda_dao.dart';
import '../middleware/error_middleware.dart';
import '../services/password_service.dart';
import '../utils/validators.dart';

class AuthController {
  final AziendaDao aziende;

  AuthController(this.aziende);

  Router get router {
    final router = Router();

    router.post('/api/auth/register', _register);

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
}