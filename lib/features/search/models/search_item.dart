enum SearchType { need, person }

class SearchItem {
  const SearchItem({required this.type, required this.title, required this.bloodGroup, this.subtitle, this.date});
  final SearchType type;
  final String title;
  final String bloodGroup;
  final String? subtitle;
  final String? date;
}
