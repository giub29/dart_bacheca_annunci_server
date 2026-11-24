import 'dart:io';

import '../lib/dao/azienda_dao.dart';
import '../lib/dao/json_store.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/middleware/error_middleware.dart';

import '../lib/controllers/auth_controller.dart';

Future<void> main() async {
  final dataDirectory = Directory('data');
  await dataDirectory.create(recursive: true);

  final aziende = AziendaDao(
    JsonCollection('${dataDirectory.path}/aziende.json'),
  );

  await aziende.load();

  print('Archivio aziende caricato.');

  final router = Router();

  router.get('/api/health', (Request request) {
    return jsonResponse({'status': 'ok'});
  });

  final api = Cascade()
      .add(router.call)
      .add(AuthController(aziende).router.call)
      .add((Request request) {
    return jsonError(404, 'Risorsa non trovata.');
  })
      .handler;

  final handler = const Pipeline()
      .addMiddleware(errorMiddleware())
      .addHandler(api);

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server avviato sulla porta ${server.port}');
}