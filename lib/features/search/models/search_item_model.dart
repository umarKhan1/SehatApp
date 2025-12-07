class SearchItemModel {

  factory SearchItemModel.fromPost(Map<String, dynamic> post) => SearchItemModel(
        id: (post['id'] ?? post['docId'] ?? '').toString(),
        uid: (post['uid'] ?? '').toString(),
        name: (post['name'] ?? '').toString(),
        hospital: (post['hospital'] ?? '').toString(),
        bloodGroup: (post['bloodGroup'] ?? '').toString(),
        dateDisplay: (post['date'] ?? '').toString(),
      );
  SearchItemModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.hospital,
    required this.bloodGroup,
    this.dateDisplay,
  });

  final String id;
  final String uid;
  final String name;
  final String hospital;
  final String bloodGroup;
  final String? dateDisplay;

  Map<String, dynamic> toMap() => {
        'id': id,
        'uid': uid,
        'name': name,
        'hospital': hospital,
        'bloodGroup': bloodGroup,
        'date': dateDisplay ?? '',
      };
}
