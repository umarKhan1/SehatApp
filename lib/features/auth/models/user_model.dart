import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: (data['email'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      wantToDonate: (data['wantToDonate'] ?? false) as bool,
      profileCompleted: (data['profileCompleted'] ?? false) as bool,
      // Read 'profileStep' from Firestore (with fallback to 'currentStep' for edge cases)
      profileStep: (data['profileStep'] ?? data['currentStep'] ?? 1) as int,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    wantToDonate: (json['wantToDonate'] ?? false) as bool,
    profileCompleted: (json['profileCompleted'] ?? false) as bool,
    profileStep: (json['profileStep'] ?? json['currentStep'] ?? 1) as int,
  );
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.wantToDonate = false,
    this.profileCompleted = false,
    this.profileStep = 1,
  });

  final String id;
  final String email;
  final String name;
  final bool wantToDonate;
  final bool profileCompleted;
  final int profileStep;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'wantToDonate': wantToDonate,
    'profileCompleted': profileCompleted,
    'profileStep': profileStep,
  };
}
