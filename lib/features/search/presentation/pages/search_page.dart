import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_details_page.dart';
import 'package:sehatapp/features/search/models/search_item.dart';
import 'package:sehatapp/features/search/presentation/widgets/search_result_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController(text: 'B+ Blood');

  final List<SearchItem> _items = const [
    SearchItem(type: SearchType.need, title: 'Emergency B+ Blood Needed', subtitle: 'Hospital Name', date: '12 Feb 2022', bloodGroup: 'B+'),
    SearchItem(type: SearchType.need, title: 'Emergency B+ Blood Needed', subtitle: 'Hospital Name', date: '12 Feb 2022', bloodGroup: 'B+'),
    SearchItem(type: SearchType.need, title: 'Emergency B+ Blood Needed', subtitle: 'Hospital Name', date: '12 Feb 2022', bloodGroup: 'B+'),
    SearchItem(type: SearchType.person, title: 'Cameron Williamson', subtitle: '+88 01818 121212', bloodGroup: 'B+'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h + MediaQuery.of(context).padding.top, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: back button and centered title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Navigate back to dashboard explicitly
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      tx.searchTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SizedBox(width: 48.w), // spacer to balance back button width
              ],
            ),
            SizedBox(height: 12.h),
            // Search bar with hero animation
            Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black38),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          decoration: InputDecoration.collapsed(hintText: tx.searchHint),
                          onChanged: (v) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(text: tx.searchResultFor('')), // prefix only
                  TextSpan(text: ' "${_ctrl.text}"', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_,_) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return SearchResultCard(
                    item: item,
                    onTap: () {
                      if (item.type == SearchType.need) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BloodRequestDetailsPage(
                              title: item.title,
                              bloodGroup: item.bloodGroup,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
