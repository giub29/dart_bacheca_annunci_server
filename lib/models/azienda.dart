class Azienda {
  final int id;
  final String nome;
  final String email;
  final String passwordHash;
  final String salt;

  const Azienda({
    required this.id,
    required this.nome,
    required this.email,
    required this.passwordHash,
    required this.salt,
  });

  factory Azienda.fromJson(Map<String, dynamic> json) {
    return Azienda(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      salt: json['salt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
    };
  }

  Map<String, dynamic> toPublicJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }
}