import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatapp/features/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IUserRepository {
  Future<UserModel?> getUser(String uid);
  Future<Map<String, dynamic>> getUserWithCache(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  // Added to match implementation
  Future<void> createInitialUser({required String uid, required String name, required String email});
  Future<void> saveStep1(String uid, {
    required String name,
    required String phone,
    required String bloodGroup,
    required String country,
    required String city,
    bool? wantToDonate,
  });
  Future<void> completeProfile(String uid, Map<String, dynamic> data);
}

class UserRepository implements IUserRepository {
  UserRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  @override
  Future<void> createInitialUser({required String uid, required String name, required String email}) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'profileCompleted': false,
      'profileStep': 1, // 1: before step1, 2: after step1, 3: completed
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // cache basic info
    await saveUserToCache({'name': name});
  }

  @override
  Future<void> saveStep1(String uid, {
    required String name,
    required String phone,
    required String bloodGroup,
    required String country,
    required String city,
    bool? wantToDonate,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'country': country,
      'city': city,
      if (wantToDonate != null) 'wantToDonate': wantToDonate,
      'profileStep': 2,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await saveUserToCache({'name': name, 'bloodGroup': bloodGroup, 'country': country, 'city': city, if (wantToDonate != null) 'wantToDonate': wantToDonate});
  }

  @override
  Future<void> completeProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'profileCompleted': true,
      'profileStep': 3,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await saveUserToCache(data);
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<Map<String, dynamic>> getUserWithCache(String uid) async {
    // keep existing behavior to avoid changing callers
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data() ?? {})..addAll({'id': doc.id});
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Cache helpers
  Future<void> saveUserToCache(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    if (data.containsKey('name')) await sp.setString('user.name', (data['name'] ?? '') as String);
    if (data.containsKey('bloodGroup')) await sp.setString('user.bloodGroup', (data['bloodGroup'] ?? '') as String);
    if (data.containsKey('wantToDonate')) await sp.setBool('user.wantToDonate', (data['wantToDonate'] ?? false) as bool);
  }

  Future<Map<String, dynamic>> getCachedUser() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'name': sp.getString('user.name') ?? '',
      'bloodGroup': sp.getString('user.bloodGroup') ?? '',
      'wantToDonate': sp.getBool('user.wantToDonate') ?? false,
    };
  }
}
