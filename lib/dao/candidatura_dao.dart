import '../models/candidatura.dart';
import 'json_store.dart';

class CandidaturaDao {
  final JsonCollection _collection;

  CandidaturaDao(this._collection);

  Future<void> load() {
    return _collection.load();
  }

  Candidatura? findById(int id) {
    for (final item in _collection.all()) {
      if (item['id'] == id) {
        return Candidatura.fromJson(item);
      }
    }

    return null;
  }

  List<Candidatura> byAnnuncio(int annuncioId) {
    return _collection
        .all()
        .where((item) => item['annuncioId'] == annuncioId)
        .map(Candidatura.fromJson)
        .toList();
  }

  Future<Candidatura> create({
    required int annuncioId,
    required String nome,
    required String cognome,
    required String email,
    required String cvNomeOriginale,
    required String cvNomeMemorizzato,
    required int cvDimensione,
  }) async {
    final candidatura = Candidatura(
      id: _collection.nextId(),
      annuncioId: annuncioId,
      nome: nome.trim(),
      cognome: cognome.trim(),
      email: email.trim().toLowerCase(),
      cvNomeOriginale: cvNomeOriginale,
      cvNomeMemorizzato: cvNomeMemorizzato,
      cvDimensione: cvDimensione,
    );

    await _collection.addAndSave(candidatura.toJson());

    return candidatura;
  }
}
