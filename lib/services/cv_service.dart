import 'dart:io';
import 'dart:math';

class CvService {
  final Directory directory;
  final Random _random = Random.secure();

  CvService(this.directory);

  Future<String> salva(List<int> bytes) async {
    await directory.create(recursive: true);

    final codice = List<int>.generate(
      32,
      (_) => _random.nextInt(256),
    ).map((numero) {
      return numero.toRadixString(16).padLeft(2, '0');
    }).join();

    final nomeMemorizzato = '$codice.pdf';

    final file = File(
      '${directory.path}/$nomeMemorizzato',
    );

    await file.writeAsBytes(bytes, flush: true);

    return nomeMemorizzato;
  }

  Future<void> elimina(String nomeMemorizzato) async {
    final formatoNome = RegExp(r'^[a-f0-9]{64}\.pdf$');

    if (!formatoNome.hasMatch(nomeMemorizzato)) {
      throw const FormatException(
        'Nome del file CV memorizzato non valido.',
      );
    }

    final file = File(
      '${directory.path}/$nomeMemorizzato',
    );

    if (await file.exists()) {
      await file.delete();
    }
  }
}
