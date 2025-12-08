import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatapp/features/recently_viewed/models/recently_viewed_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IRecentlyViewedRepository {
  Future<List<RecentlyViewedEntry>> getAll(String uid);
  Future<List<RecentlyViewedEntry>> getPreview(String uid);
  Future<void> addItem(String uid, Map<String, dynamic> post);
  Future<void> clear(String uid);
}

class RecentlyViewedRepository implements IRecentlyViewedRepository {
  RecentlyViewedRepository({this.maxItems = 10});
  static const _keyPrefix = 'recently_viewed_';
  final int maxItems;

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      DateTime dt;
      if (raw is String) {
        dt = DateTime.parse(raw);
      } else if (raw is Timestamp) {
        dt = raw.toDate();
      } else if (raw is DateTime) {
        dt = raw;
      } else {
        return raw.toString();
      }
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  String _toIsoString(dynamic raw) {
    if (raw == null) return '';
    try {
      if (raw is String) return raw; // already a string
      if (raw is Timestamp) return raw.toDate().toIso8601String();
      if (raw is DateTime) return raw.toIso8601String();
      return raw.toString();
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Future<List<RecentlyViewedEntry>> getAll(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_keyPrefix$uid');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List list = json.decode(jsonStr) as List;
    return list
        .map((e) => RecentlyViewedEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecentlyViewedEntry>> getPreview(String uid) async {
    final items = await getAll(uid);
    return items.length <= 3 ? items : items.sublist(0, 3);
  }

  @override
  Future<void> addItem(String uid, Map<String, dynamic> post) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll(uid);
    final id =
        (post['id'] ??
                post['docId'] ??
                post['uid'] ??
                DateTime.now().millisecondsSinceEpoch.toString())
            .toString();
    final existingIndex = items.indexWhere((e) => e.id == id);
    final entry = RecentlyViewedEntry(
      id: id,
      uid: (post['uid'] ?? '').toString(),
      name: (post['name'] ?? '').toString(),
      bloodGroup: (post['bloodGroup'] ?? '').toString(),
      hospital: (post['hospital'] ?? '').toString(),
      dateDisplay: _formatDate(post['date'] ?? post['createdAt']),
      contactPerson: (post['contactPerson'] ?? '').toString(),
      mobile: (post['mobile'] ?? '').toString(),
      bags: (post['bags'] ?? '').toString(),
      country: (post['country'] ?? '').toString(),
      city: (post['city'] ?? '').toString(),
      reason: (post['reason'] ?? '').toString(),
      createdAtIso: _toIsoString(post['createdAt'] ?? post['date']),
    );
    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    }
    items.insert(0, entry);
    if (items.length > maxItems) {
      items.removeRange(maxItems, items.length);
    }
    await prefs.setString(
      '$_keyPrefix$uid',
      json.encode(items.map((e) => e.toMap()).toList()),
    );
  }

  @override
  Future<void> clear(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$uid');
  }
}
