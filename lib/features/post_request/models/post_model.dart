import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PostModel(
      id: doc.id,
      uid: (data['uid'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      bloodGroup: (data['bloodGroup'] ?? '').toString(),
      hospital: (data['hospital'] ?? '').toString(),
      createdAtIso: _toIso(data['createdAt'] ?? data['date']),
      contactPerson: (data['contactPerson'] ?? '').toString(),
      mobile: (data['mobile'] ?? '').toString(),
      bags: (data['bags'] ?? '').toString(),
      country: (data['country'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      reason: (data['reason'] ?? '').toString(),
      dateDisplay: _formatDate(data['date'] ?? data['createdAt']),
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: (json['id'] ?? '').toString(),
    uid: (json['uid'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    bloodGroup: (json['bloodGroup'] ?? '').toString(),
    hospital: (json['hospital'] ?? '').toString(),
    createdAtIso: (json['createdAt'] ?? '').toString(),
    contactPerson: (json['contactPerson'] ?? '').toString(),
    mobile: (json['mobile'] ?? '').toString(),
    bags: (json['bags'] ?? '').toString(),
    country: (json['country'] ?? '').toString(),
    city: (json['city'] ?? '').toString(),
    reason: (json['reason'] ?? '').toString(),
    dateDisplay: (json['date'] ?? '').toString(),
  );
  PostModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.hospital,
    this.createdAtIso,
    this.contactPerson,
    this.mobile,
    this.bags,
    this.country,
    this.city,
    this.reason,
    this.dateDisplay,
  });

  final String id;
  final String uid;
  final String name;
  final String bloodGroup;
  final String hospital;
  final String? createdAtIso;
  final String? contactPerson;
  final String? mobile;
  final String? bags;
  final String? country;
  final String? city;
  final String? reason;
  final String? dateDisplay;

  static String _toIso(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is Timestamp) return raw.toDate().toIso8601String();
    if (raw is DateTime) return raw.toIso8601String();
    return raw.toString();
  }

  static String _formatDate(dynamic raw) {
    if (raw == null) return '';
    DateTime dt;
    if (raw is String) {
      try { dt = DateTime.parse(raw); } catch (_) { return raw; }
    } else if (raw is Timestamp) {
      dt = raw.toDate();
    } else if (raw is DateTime) {
      dt = raw;
    } else {
      return raw.toString();
    }
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': uid,
    'name': name,
    'bloodGroup': bloodGroup,
    'hospital': hospital,
    'createdAt': createdAtIso ?? '',
    'contactPerson': contactPerson ?? '',
    'mobile': mobile ?? '',
    'bags': bags ?? '',
    'country': country ?? '',
    'city': city ?? '',
    'reason': reason ?? '',
    'date': dateDisplay ?? '',
  };
}
