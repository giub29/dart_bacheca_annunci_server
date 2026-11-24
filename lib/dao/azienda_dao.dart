import '../models/azienda.dart';
import 'json_store.dart';
import '../errors/api_exception.dart';

class AziendaDao {
  final JsonCollection _collection;

  AziendaDao(this._collection);

  Future<void> load() {
    return _collection.load();
  }

  Azienda? findById(int id) {
    for (final item in _collection.all()) {
      if (item['id'] == id) {
        return Azienda.fromJson(item);
      }
    }

    return null;
  }

  Azienda? findByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final item in _collection.all()) {
      final storedEmail = item['email'] as String;

      if (storedEmail.trim().toLowerCase() == normalizedEmail) {
        return Azienda.fromJson(item);
      }
    }

    return null;
  }

  bool emailExists(String email) {
    return findByEmail(email) != null;
  }

  Future<Azienda> create({
    required String nome,
    required String email,
    required String passwordHash,
    required String salt,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (emailExists(normalizedEmail)) {
      throw ApiException(409, 'Email già registrata.');
    }

    final azienda = Azienda(
      id: _collection.nextId(),
      nome: nome.trim(),
      email: normalizedEmail,
      passwordHash: passwordHash,
      salt: salt,
    );

    _collection.add(azienda.toJson());

    await _collection.save();

    return azienda;
  }
}