import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

Future<Map<String, dynamic>> readJsonObject(Request request) async {
  final text = await request.readAsString();
  final decoded = jsonDecode(text);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('È richiesto un oggetto JSON.');
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
