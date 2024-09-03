import 'dart:convert';

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? picture;

  const UserModel(
      {required this.id,
      required this.email,
      required this.name,
      this.picture});

  static const empty = UserModel(id: "", email: "", name: "", picture: "");

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
  }) {
    return UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        picture: picture ?? this.picture);
  }

  String toJson(UserModel user) {
    return jsonEncode(toMap(user));
  }

  Map<String, dynamic> toMap(UserModel user) => {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        if (user.picture != null) 'picture': user.picture,
      };

  UserModel fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      picture: map['picture'], // No need for null check here
    );
  }

  bool get isEmpty => this == UserModel.empty;
  bool get isNotEmpty => this != UserModel.empty;

  @override
  List<Object?> get props => [id, email, name, picture];
}
