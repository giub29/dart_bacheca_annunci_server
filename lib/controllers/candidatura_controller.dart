import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../services/cv_service.dart';
import '../utils/validators.dart';

class CandidaturaController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;
  final CvService cvService;

  CandidaturaController(
    this.annunci,
    this.candidature,
    this.cvService,
  );

  Router get router {
    final router = Router();

    router.post(
      '/api/annunci/<id>/candidature',
      _create,
    );

    router.get(
      '/api/annunci/<id>/candidature',
      (Request request, String id) {
        return guard(
          (Request authenticatedRequest) {
            return _list(authenticatedRequest, id);
          },
        )(request);
      },
    );

    router.get(
      '/api/candidature/<id>/cv',
      (Request request, String id) {
        return guard(
          (Request authenticatedRequest) {
            return _downloadCv(authenticatedRequest, id);
          },
        )(request);
      },
    );

    return router;
  }

  Response _list(Request request, String id) {
    final azienda = currentAzienda(request)!;

    final annuncioId = int.tryParse(id);

    if (annuncioId == null || annuncioId <= 0) {
      throw const ApiException(
        400,
        'Identificatore annuncio non valido.',
      );
    }

    final annuncio = annunci.findById(annuncioId);

    if (annuncio == null) {
      throw const ApiException(
        404,
        'Annuncio non trovato.',
      );
    }

    if (annuncio.aziendaId != azienda.id) {
      throw const ApiException(
        403,
        'Non puoi consultare le candidature di questo annuncio.',
      );
    }

    final risultati = candidature.byAnnuncio(annuncioId);

    return jsonResponse(
      risultati.map((candidatura) {
        return candidatura.toPublicJson();
      }).toList(),
    );
  }

  Future<Response> _downloadCv(Request request, String id) async {
    final azienda = currentAzienda(request)!;

    final candidaturaId = int.tryParse(id);

    if (candidaturaId == null || candidaturaId <= 0) {
      throw const ApiException(
        400,
        'Identificatore candidatura non valido.',
      );
    }

    final candidatura = candidature.findById(candidaturaId);

    if (candidatura == null) {
      throw const ApiException(
        404,
        'Candidatura non trovata.',
      );
    }

    final annuncio = annunci.findById(candidatura.annuncioId);

    if (annuncio == null) {
      throw const ApiException(
        404,
        'Annuncio non trovato.',
      );
    }

    if (annuncio.aziendaId != azienda.id) {
      throw const ApiException(
        403,
        'Non puoi accedere al curriculum di questa candidatura.',
      );
    }

    final bytes = await cvService.leggi(
      candidatura.cvNomeMemorizzato,
    );

    return Response.ok(
      bytes,
      headers: {
        'content-type': 'application/pdf',
        'content-disposition':
            'attachment; filename="cv-${candidatura.id}.pdf"',
        'cache-control': 'no-store',
      },
    );
  }

  Future<Response> _create(Request request, String id) async {
    if (currentAzienda(request) != null) {
      throw const ApiException(
        403,
        'Le aziende non possono inviare candidature.',
      );
    }

    final annuncioId = int.tryParse(id);

    if (annuncioId == null || annuncioId <= 0) {
      throw const ApiException(
        400,
        'Identificatore annuncio non valido.',
      );
    }

    if (annunci.findById(annuncioId) == null) {
      throw const ApiException(
        404,
        'Annuncio non trovato.',
      );
    }

    final body = await readJsonObject(
      request,
      maxBytes: 8 * 1024 * 1024,
    );

    final input = validateCandidatura(body);
    final cv = validateCv(body);

    final nomeMemorizzato = await cvService.salva(cv.bytes);

    try {
      final candidatura = await candidature.create(
        annuncioId: annuncioId,
        nome: input.nome,
        cognome: input.cognome,
        email: input.email,
        cvNomeOriginale: cv.nomeOriginale,
        cvNomeMemorizzato: nomeMemorizzato,
        cvDimensione: cv.bytes.length,
      );

      return jsonResponse(
        {'id': candidatura.id, 'message': 'Candidatura inviata.'},
        status: 201,
      );
    } catch (_) {
      try {
        await cvService.elimina(nomeMemorizzato);
      } catch (_) {
        stderr.writeln(
          'Impossibile eliminare il CV dopo il mancato '
          'salvataggio della candidatura.',
        );
      }

      rethrow;
    }
  }
}
