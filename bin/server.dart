import 'dart:convert';
import 'dart:io';

import '../lib/dao/azienda_dao.dart';
import '../lib/dao/json_store.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

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
    return Response.ok(
      jsonEncode({'status': 'ok'}),
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
  });

  final server = await io.serve(
    router.call,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server avviato sulla porta ${server.port}');
}