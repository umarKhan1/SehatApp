import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      id: doc.id,
      email: (data['email'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      wantToDonate: (data['wantToDonate'] ?? false) as bool,
      profileCompleted: (data['profileCompleted'] ?? false) as bool,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        wantToDonate: (json['wantToDonate'] ?? false) as bool,
        profileCompleted: (json['profileCompleted'] ?? false) as bool,
      );
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.wantToDonate = false,
    this.profileCompleted = false,
  });

  final String id;
  final String email;
  final String name;
  final bool wantToDonate;
  final bool profileCompleted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'wantToDonate': wantToDonate,
        'profileCompleted': profileCompleted,
      };
}
