import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../dao/annuncio_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../utils/validators.dart';

class AnnuncioController {
  final AnnuncioDao annunci;

  AnnuncioController(this.annunci);

  Router get router {
    final router = Router();

    router.get('/api/annunci', _list);
    router.get('/api/annunci/<id>', _detail);
    router.post('/api/annunci', guard(_create));
    router.get('/api/azienda/annunci', guard(_mine));

    return router;
  }

  Response _list(Request request) {
    final risultati = annunci.all();

    return jsonResponse(
      risultati.map((annuncio) => annuncio.toJson()).toList(),
    );
  }

  Response _detail(Request request, String id) {
    final annuncioId = int.tryParse(id);

    if (annuncioId == null || annuncioId <= 0) {
      throw const ApiException(400, 'Identificatore non valido.');
    }

    final annuncio = annunci.findById(annuncioId);

    if (annuncio == null) {
      throw const ApiException(404, 'Annuncio non trovato.');
    }

    return jsonResponse(annuncio.toJson());
  }

  Future<Response> _create(Request request) async {
    final azienda = currentAzienda(request)!;

    final body = await readJsonObject(request);
    final input = validateAnnuncio(body);

    final annuncio = await annunci.create(
      aziendaId: azienda.id,
      titolo: input.titolo,
      descrizione: input.descrizione,
    );

    return jsonResponse(
      annuncio.toJson(),
      status: 201,
    );
  }

  Response _mine(Request request) {
    final azienda = currentAzienda(request)!;
    final risultati = annunci.byAzienda(azienda.id);

    return jsonResponse(
      risultati.map((annuncio) => annuncio.toJson()).toList(),
    );
  }
}