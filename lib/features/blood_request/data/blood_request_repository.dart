import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestRepository {
  BloodRequestRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<Map<String, dynamic>>> streamRequests({String? bloodGroup, int limit = 100, String? excludeUid}) {
    Query q;
    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      // Filter by bloodGroup only to avoid composite index requirement
      q = _db.collection('posts').where('bloodGroup', isEqualTo: bloodGroup).limit(limit);
    } else {
      q = _db.collection('posts').orderBy('createdAt', descending: true).limit(limit);
    }
    return q.snapshots().map((s) {
      final list = s.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return {...data, 'id': d.id};
      }).toList();
      // Client-side filter to exclude current user's posts if excludeUid provided
      final filtered = excludeUid == null || excludeUid.isEmpty
          ? list
          : list.where((e) => (e['userId'] ?? e['uid'] ?? '') != excludeUid).toList();
      // Client-side sort by createdAt if available
      filtered.sort((a, b) {
        final ca = a['createdAt'];
        final cb = b['createdAt'];
        final da = ca is Timestamp ? ca.toDate() : (ca is DateTime ? ca : null);
        final db = cb is Timestamp ? cb.toDate() : (cb is DateTime ? cb : null);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
      return filtered;
    });
  }
}
