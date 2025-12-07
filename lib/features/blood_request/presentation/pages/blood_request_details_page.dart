import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';

class BloodRequestDetailsPage extends StatefulWidget {
  const BloodRequestDetailsPage({super.key, required this.post});
  final Map<String, dynamic> post;

  @override
  State<BloodRequestDetailsPage> createState() => _BloodRequestDetailsPageState();
}

class _BloodRequestDetailsPageState extends State<BloodRequestDetailsPage> {
  late Map<String, dynamic> _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.post);
    // Remove addViewed here to avoid duplicate calls; it's already called on tap before navigation
    _maybeFetchFullDoc();
  }

  Future<void> _maybeFetchFullDoc() async {
    final needs = [
      (_data['contactPerson'] ?? ''),
      (_data['mobile'] ?? ''),
      (_data['bags'] ?? ''),
      (_data['country'] ?? ''),
      (_data['city'] ?? ''),
      (_data['reason'] ?? ''),
    ];
    final hasMissing = needs.any((v) => (v is String ? v.isEmpty : false));
    final id = _data['id'] as String?;
    if (!hasMissing || id == null || id.isEmpty) return;
    setState(() => _loading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('posts').doc(id).get();
      if (doc.exists) {
        final full = doc.data() as Map<String, dynamic>;
        setState(() {
          _data = {..._data, ...full};
        });
      }
    } catch (_) {
      // ignore errors, show partial
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    final title = (_data['name'] ?? '') as String;
    final bloodGroup = (_data['bloodGroup'] ?? '') as String;
    final contactPerson = (_data['contactPerson'] ?? '') as String;
    final mobile = (_data['mobile'] ?? '') as String;
    final bags = (_data['bags'] ?? '') as String;
    final country = (_data['country'] ?? '') as String;
    final city = (_data['city'] ?? '') as String;
    final hospital = (_data['hospital'] ?? '') as String;
    final reason = (_data['reason'] ?? '') as String;
    final date = _formatDate(_data['date'] ?? _data['createdAt']);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                  Expanded(child: Center(child: Text(tx.postDetailsTitle, style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              SizedBox(height: 20.h),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent), color: const Color(0xFFFFEEEE)),
                      alignment: Alignment.center,
                      child: Text(bloodGroup, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(height: 12.h),
                    Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const Divider(),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.person, label: tx.contactPersonLabel, value: contactPerson.isEmpty ? '-' : contactPerson),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.phone, label: tx.mobileNumberLabel, value: mobile.isEmpty ? '-' : mobile),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.bloodtype, label: tx.howManyBagsLabel, value: bags.toString().isEmpty ? '-' : bags.toString()),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.public, label: tx.countryLabel, value: country.isEmpty ? '-' : country),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.location_on, label: tx.cityLabel, value: city.isEmpty ? '-' : city),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.local_hospital, label: tx.hospitalLabel, value: hospital.isEmpty ? '-' : hospital),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.access_time, label: 'Date', value: date.isEmpty ? '-' : date),
              SizedBox(height: 12.h),
              Text(tx.whyNeedBloodTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              Text(reason.isEmpty ? '-' : reason, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushNamed('chat', extra: {'title': title, 'uid': _data['uid']}),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: Text(tx.chatNow, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
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

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(16.r)),
              child: Icon(icon, color: Colors.redAccent, size: 18),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  Text(value, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Divider(height: 1),
      ],
    );
  }
}
