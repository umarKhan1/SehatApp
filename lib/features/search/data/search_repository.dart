import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatapp/features/search/models/search_item_model.dart';

class SearchRepository {
  SearchRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<List<SearchItemModel>> search(String term, {int limit = 50}) async {
    try {
      final t = term.trim();
      if (t.isEmpty) return [];
      final uid = _auth.currentUser?.uid;

      List<SearchItemModel> toItems(QuerySnapshot snap) => snap.docs
          .map((d) => ({...d.data() as Map<String, dynamic>, 'id': d.id}))
          .where((p) => uid == null ? true : p['uid'] != uid)
          .map((p) => SearchItemModel.fromPost(p))
          .take(limit)
          .toList();

      // Blood group exact match only
      const bloodGroups = ['A+','A-','B+','B-','AB+','AB-','O+','O-'];
      if (bloodGroups.contains(t.toUpperCase())) {
        Query q = _db.collection('posts').where('bloodGroup', isEqualTo: t.toUpperCase());
        q = q.orderBy('createdAt', descending: true).limit(limit * 2);
        final snap = await q.get();
        return toItems(snap);
      }

      // Hospital prefix using \uf8ff; restrict to hospital only
      final end = '$t\uf8ff';
      Query q1 = _db.collection('posts').orderBy('hospital').startAt([t]).endAt([end]).limit(limit * 2);
      final s1 = await q1.get();
      final r1 = toItems(s1);
      if (r1.isNotEmpty) return r1;

      // Fallback: recent posts client-side contains (case-insensitive) by hospital only
      Query q2 = _db.collection('posts').orderBy('createdAt', descending: true).limit(200);
      final s2 = await q2.get();
      final tl = t.toLowerCase();
      return s2.docs
          .map((d) => ({...d.data() as Map<String, dynamic>, 'id': d.id}))
          .where((p) => uid == null ? true : p['uid'] != uid)
          .where((p) {
            final h = (p['hospital'] ?? '') as String;
            return h.toLowerCase().contains(tl);
          })
          .map((p) => SearchItemModel.fromPost(p))
          .take(limit)
          .toList();
    } catch (e) {
      throw Exception('Search failed');
    }
  }
}
