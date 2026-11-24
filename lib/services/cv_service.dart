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
}
