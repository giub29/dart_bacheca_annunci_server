import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordService {
  static final Random _random = Random.secure();

  static String generateSalt() {
    final bytes = List<int>.generate(
      16,
          (_) => _random.nextInt(256),
    );

    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) {
    return sha256
        .convert(utf8.encode('$salt:$password'))
        .toString();
  }

  static bool verify(
      String password,
      String salt,
      String expectedHash,
      ) {
    final actualHash = hash(password, salt);

    if (actualHash.length != expectedHash.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < actualHash.length; i++) {
      difference |=
      actualHash.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }

    return difference == 0;
  }
}