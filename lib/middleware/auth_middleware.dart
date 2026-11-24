import 'package:shelf/shelf.dart';

import '../dao/azienda_dao.dart';
import '../models/azienda.dart';
import '../services/token_service.dart';
import 'error_middleware.dart';

const String _aziendaKey = 'bacheca.azienda';
const String _tokenKey = 'bacheca.token';

Azienda? currentAzienda(Request request) {
  return request.context[_aziendaKey] as Azienda?;
}

String? currentToken(Request request) {
  return request.context[_tokenKey] as String?;
}

Middleware authMiddleware(
    TokenService tokens,
    AziendaDao aziende,
    ) {
  return (Handler inner) {
    return (Request request) {
      var authenticatedRequest = request;

      final header = request.headers['authorization'];

      if (header != null &&
          header.toLowerCase().startsWith('bearer ')) {
        final token = header.substring(7).trim();
        final aziendaId = tokens.aziendaIdFor(token);

        if (aziendaId != null) {
          final azienda = aziende.findById(aziendaId);

          if (azienda != null) {
            authenticatedRequest = request.change(
              context: {
                _aziendaKey: azienda,
                _tokenKey: token,
              },
            );
          }
        }
      }

      return inner(authenticatedRequest);
    };
  };
}

Handler guard(Handler handler) {
  return (Request request) {
    if (currentAzienda(request) == null) {
      return jsonError(401, 'Autenticazione richiesta.');
    }

    return handler(request);
  };
}