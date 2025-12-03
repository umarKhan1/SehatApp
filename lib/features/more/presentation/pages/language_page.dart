import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_locale_cubit.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final List<_LangItem> _langs = const [
    _LangItem('English', Locale('en')),
    _LangItem('বাংলা', Locale('bn')), // optional if you add Bengali later
    _LangItem('हिन्दी', Locale('hi')),
    _LangItem('العربية', Locale('ar')),
    _LangItem('اردو', Locale('ur')),
  ];

  Locale? _selected;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = context.read<AppLocaleCubit>().state;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _langs.where((l) => l.name.toLowerCase().contains(_search.text.toLowerCase())).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
                  Expanded(child: Center(child: Text('Language', style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    final selected = item.locale == _selected;
                    return ListTile(
                      title: Text(item.name),
                      onTap: () => setState(() => _selected = item.locale),
                      leading: Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: selected ? Colors.redAccent : Colors.black38,
                      ),
                      trailing: selected
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEEE),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: Text('Selected', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent)),
                            )
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(vertical: 14.h)),
                  onPressed: _selected == null
                      ? null
                      : () {
                          context.read<AppLocaleCubit>().setLocale(_selected!);
                          Navigator.of(context).pop();
                        },
                  child: const Text('Save'),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangItem {
  const _LangItem(this.name, this.locale);
  final String name;
  final Locale locale;
}
