import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

Future<Map<String, dynamic>> readJsonObject(
  Request request, {
  int maxBytes = 64 * 1024,
}) async {
  final bytes = <int>[];

  await for (final chunk in request.read()) {
    if (bytes.length + chunk.length > maxBytes) {
      throw const ApiException(
        413,
        'La richiesta supera la dimensione consentita.',
      );
    }

    bytes.addAll(chunk);
  }

  final text = utf8.decode(bytes);
  final decoded = jsonDecode(text);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'È richiesto un oggetto JSON.',
    );
  }

  return decoded;
}

class RegistrazioneInput {
  final String nome;
  final String email;
  final String password;

  const RegistrazioneInput({
    required this.nome,
    required this.email,
    required this.password,
  });
}

final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

final RegExp _passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,64}$');

RegistrazioneInput validateRegister(Map<String, dynamic> body) {
  final nome = body['nome'];
  final email = body['email'];
  final password = body['password'];

  if (nome is! String || nome.trim().isEmpty) {
    throw const ApiException(422, 'Nome azienda obbligatorio.');
  }

  if (nome.trim().length > 100) {
    throw const ApiException(
      422,
      'Il nome azienda può contenere al massimo 100 caratteri.',
    );
  }

  if (email is! String || !_emailPattern.hasMatch(email.trim())) {
    throw const ApiException(422, 'Email non valida.');
  }

  if (password is! String || !_passwordPattern.hasMatch(password)) {
    throw const ApiException(
      422,
      'La password deve contenere da 8 a 64 caratteri, '
      'con almeno una lettera e un numero.',
    );
  }

  return RegistrazioneInput(
    nome: nome.trim(),
    email: email.trim().toLowerCase(),
    password: password,
  );
}

class AnnuncioInput {
  final String titolo;
  final String descrizione;

  const AnnuncioInput({
    required this.titolo,
    required this.descrizione,
  });
}

AnnuncioInput validateAnnuncio(Map<String, dynamic> body) {
  final titolo = body['titolo'];
  final descrizione = body['descrizione'];

  if (titolo is! String || titolo.trim().isEmpty) {
    throw const ApiException(422, 'Titolo obbligatorio.');
  }

  if (titolo.trim().length > 100) {
    throw const ApiException(
      422,
      'Il titolo può contenere al massimo 100 caratteri.',
    );
  }

  if (descrizione is! String || descrizione.trim().isEmpty) {
    throw const ApiException(422, 'Descrizione obbligatoria.');
  }

  if (descrizione.trim().length > 5000) {
    throw const ApiException(
      422,
      'La descrizione può contenere al massimo 5000 caratteri.',
    );
  }

  return AnnuncioInput(
    titolo: titolo.trim(),
    descrizione: descrizione.trim(),
  );
}

class CandidaturaInput {
  final String nome;
  final String cognome;
  final String email;

  const CandidaturaInput({
    required this.nome,
    required this.cognome,
    required this.email,
  });
}

CandidaturaInput validateCandidatura(
  Map<String, dynamic> body,
) {
  final nome = body['nome'];
  final cognome = body['cognome'];
  final email = body['email'];

  if (nome is! String || nome.trim().isEmpty) {
    throw const ApiException(422, 'Nome obbligatorio.');
  }

  if (nome.trim().length > 100) {
    throw const ApiException(
      422,
      'Il nome può contenere al massimo 100 caratteri.',
    );
  }

  if (cognome is! String || cognome.trim().isEmpty) {
    throw const ApiException(422, 'Cognome obbligatorio.');
  }

  if (cognome.trim().length > 100) {
    throw const ApiException(
      422,
      'Il cognome può contenere al massimo 100 caratteri.',
    );
  }

  if (email is! String || !_emailPattern.hasMatch(email.trim())) {
    throw const ApiException(422, 'Email non valida.');
  }

  if (email.trim().length > 254) {
    throw const ApiException(
      422,
      'L’email può contenere al massimo 254 caratteri.',
    );
  }

  return CandidaturaInput(
    nome: nome.trim(),
    cognome: cognome.trim(),
    email: email.trim().toLowerCase(),
  );
}

const int maxCvBytes = 5 * 1024 * 1024;

class CvInput {
  final String nomeOriginale;
  final List<int> bytes;

  const CvInput({
    required this.nomeOriginale,
    required this.bytes,
  });
}

CvInput validateCv(Map<String, dynamic> body) {
  final nomeOriginale = body['cvNomeOriginale'];
  final contenuto = body['cvBase64'];

  if (nomeOriginale is! String || nomeOriginale.trim().isEmpty) {
    throw const ApiException(422, 'Nome del curriculum obbligatorio.');
  }

  final nome = nomeOriginale.trim();

  if (nome.length > 200) {
    throw const ApiException(
      422,
      'Il nome del curriculum è troppo lungo.',
    );
  }

  if (!nome.toLowerCase().endsWith('.pdf')) {
    throw const ApiException(
      422,
      'Il curriculum deve essere un file PDF.',
    );
  }

  if (contenuto is! String || contenuto.isEmpty) {
    throw const ApiException(422, 'Curriculum obbligatorio.');
  }

  final maxBase64Length = ((maxCvBytes + 2) ~/ 3) * 4;

  if (contenuto.length > maxBase64Length) {
    throw const ApiException(
      413,
      'Il curriculum supera il limite di 5 MiB.',
    );
  }

  final List<int> bytes;

  try {
    bytes = base64Decode(contenuto);
  } on FormatException {
    throw const ApiException(
      422,
      'Il contenuto del curriculum non è una codifica Base64 valida.',
    );
  }

  if (bytes.isEmpty) {
    throw const ApiException(422, 'Il curriculum è vuoto.');
  }

  if (bytes.length > maxCvBytes) {
    throw const ApiException(
      413,
      'Il curriculum supera il limite di 5 MiB.',
    );
  }

  const firmaPdf = [37, 80, 68, 70, 45];

  if (bytes.length < firmaPdf.length) {
    throw const ApiException(422, 'Il file non ha un’intestazione PDF.');
  }

  for (var i = 0; i < firmaPdf.length; i++) {
    if (bytes[i] != firmaPdf[i]) {
      throw const ApiException(
        422,
        'Il file non ha un’intestazione PDF.',
      );
    }
  }

  return CvInput(
    nomeOriginale: nome,
    bytes: bytes,
  );
}
