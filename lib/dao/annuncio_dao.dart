import '../models/annuncio.dart';
import 'json_store.dart';

class AnnuncioDao {
  final JsonCollection _collection;

  AnnuncioDao(this._collection);

  Future<void> load() {
    return _collection.load();
  }

  List<Annuncio> all() {
    return _collection
        .all()
        .map((item) => Annuncio.fromJson(item))
        .toList();
  }

  Annuncio? findById(int id) {
    for (final item in _collection.all()) {
      if (item['id'] == id) {
        return Annuncio.fromJson(item);
      }
    }

    return null;
  }

  List<Annuncio> byAzienda(int aziendaId) {
    return all()
        .where((annuncio) => annuncio.aziendaId == aziendaId)
        .toList();
  }

  Future<Annuncio> create({
    required int aziendaId,
    required String titolo,
    required String descrizione,
  }) async {
    final annuncio = Annuncio(
      id: _collection.nextId(),
      aziendaId: aziendaId,
      titolo: titolo.trim(),
      descrizione: descrizione.trim(),
    );

    _collection.add(annuncio.toJson());

    await _collection.save();

    return annuncio;
  }
}