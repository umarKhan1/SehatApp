class RecentlyViewedEntry { // ISO string

  factory RecentlyViewedEntry.fromMap(Map<String, dynamic> map) => RecentlyViewedEntry(
        id: (map['id'] ?? '').toString(),
        uid: (map['uid'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        bloodGroup: (map['bloodGroup'] ?? '').toString(),
        hospital: (map['hospital'] ?? '').toString(),
        dateDisplay: (map['date'] ?? '').toString(),
        contactPerson: (map['contactPerson'] ?? '').toString(),
        mobile: (map['mobile'] ?? '').toString(),
        bags: (map['bags'] ?? '').toString(),
        country: (map['country'] ?? '').toString(),
        city: (map['city'] ?? '').toString(),
        reason: (map['reason'] ?? '').toString(),
        createdAtIso: (map['createdAt'] ?? '').toString(),
      );
  RecentlyViewedEntry({
    required this.id,
    required this.uid,
    required this.name,
    required this.bloodGroup,
    required this.hospital,
    required this.dateDisplay,
    this.contactPerson,
    this.mobile,
    this.bags,
    this.country,
    this.city,
    this.reason,
    this.createdAtIso,
  });

  final String id;
  final String uid;
  final String name;
  final String bloodGroup;
  final String hospital;
  final String dateDisplay; // formatted for UI
  final String? contactPerson;
  final String? mobile;
  final String? bags;
  final String? country;
  final String? city;
  final String? reason;
  final String? createdAtIso;

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'name': name,
        'bloodGroup': bloodGroup,
        'hospital': hospital,
        'date': dateDisplay,
        'contactPerson': contactPerson ?? '',
        'mobile': mobile ?? '',
        'bags': bags ?? '',
        'country': country ?? '',
        'city': city ?? '',
        'reason': reason ?? '',
        'createdAt': createdAtIso ?? '',
      };
}
