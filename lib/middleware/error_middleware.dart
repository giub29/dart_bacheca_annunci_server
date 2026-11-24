import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

Response jsonResponse(Object? body, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(body),
    headers: {
      'content-type': 'application/json; charset=utf-8',
    },
  );
}

Response jsonError(int status, String message) {
  return jsonResponse(
    {'error': message},
    status: status,
  );
}

Middleware errorMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      try {
        return await inner(request);
      } on ApiException catch (error) {
        return jsonError(error.status, error.message);
      } on FormatException {
        return jsonError(400, 'Formato dei dati non valido.');
      } catch (error, stackTrace) {
        stderr.writeln(
          'Errore interno (${error.runtimeType}): $stackTrace',
        );

        return jsonError(500, 'Errore interno del server.');
      }
    };
  };
}