import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostRepository {
  PostRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<String> createPost(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }
    final hospital = (data['hospital'] ?? '') as String;
    final name = (data['name'] ?? '') as String;
    final doc = await _db.collection('posts').add({
      ...data,
      'uid': uid,
      'hospitalLowercase': hospital.toLowerCase(),
      'nameLowercase': name.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Stream posts from other users (exclude current user's own posts) ordered by createdAt desc.
  Stream<List<Map<String, dynamic>>> streamPosts({int limit = 50}) {
    final uid = _auth.currentUser?.uid;
    Query query = _db.collection('posts').orderBy('createdAt', descending: true).limit(limit);
    if (uid != null) {
      query = query.where('uid', isNotEqualTo: uid);
    }
    return query.snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            ...data,
            'id': d.id,
          };
        }).toList());
  }

  // Search posts by term: if term matches a blood group, filter by bloodGroup; else prefix match on hospitalLowercase.
 }
