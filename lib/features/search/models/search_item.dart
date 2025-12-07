import 'package:cloud_firestore/cloud_firestore.dart';

enum SearchType { need, person }

class SearchItem {

  factory SearchItem.fromPost(Map<String, dynamic> p) {
    final rawTitle = (p['name'] ?? '') as String;
    final title = rawTitle.isEmpty ? rawTitle : rawTitle[0].toUpperCase() + rawTitle.substring(1);

    final rawDate = p['date'];
    String? dateStr;
    if (rawDate is String && rawDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawDate);
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        dateStr = rawDate; // fallback
      }
    } else if (rawDate is Timestamp) {
      final dt = rawDate.toDate();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }

    return SearchItem(
      type: SearchType.need,
      title: title,
      bloodGroup: (p['bloodGroup'] ?? '') as String,
      subtitle: (p['hospital'] ?? '') as String,
      date: dateStr,
    );
  }
  const SearchItem({required this.type, required this.title, required this.bloodGroup, this.subtitle, this.date});
  final SearchType type;
  final String title;
  final String bloodGroup;
  final String? subtitle;
  final String? date;
}
