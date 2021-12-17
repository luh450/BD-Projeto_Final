import 'dart:convert';

class Produto {
  String nome;
  String imagem;
  String categoria;
  String uid;
  double valor;
  String marca;
  String descricao;
  Produto({
    required this.nome,
    required this.imagem,
    required this.categoria,
    required this.uid,
    required this.valor,
    required this.marca,
    required this.descricao,
  });

  Produto copyWith({
    String? nome,
    String? imagem,
    String? categoria,
    String? uid,
    double? valor,
    String? marca,
    String? descricao,
  }) {
    return Produto(
      nome: nome ?? this.nome,
      imagem: imagem ?? this.imagem,
      categoria: categoria ?? this.categoria,
      uid: uid ?? this.uid,
      valor: valor ?? this.valor,
      marca: marca ?? this.marca,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'imagem': imagem,
      'categoria': categoria,
      'uid': uid,
      'valor': valor,
      'marca': marca,
      'descricao': descricao,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      nome: map['nome'] ?? '',
      imagem: map['imagem'] ?? '',
      categoria: map['categoria'] ?? '',
      uid: map['uid'] ?? '',
      valor: map['valor']?.toDouble() ?? 0.0,
      marca: map['marca'] ?? '',
      descricao: map['descricao'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Produto.fromJson(String source) =>
      Produto.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Produto(nome: $nome, imagem: $imagem, categoria: $categoria, uid: $uid, valor: $valor, marca: $marca, descricao: $descricao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Produto &&
        other.nome == nome &&
        other.imagem == imagem &&
        other.categoria == categoria &&
        other.uid == uid &&
        other.valor == valor &&
        other.marca == marca &&
        other.descricao == descricao;
  }

  @override
  int get hashCode {
    return nome.hashCode ^
        imagem.hashCode ^
        categoria.hashCode ^
        uid.hashCode ^
        valor.hashCode ^
        marca.hashCode ^
        descricao.hashCode;
  }
}
