import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/chat/bloc/inbox_cubit.dart';
import 'package:sehatapp/features/chat/presentation/widgets/chat_list_item.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  // Search controller and query to filter conversations by other user's name
  final TextEditingController _searchCtl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InboxCubit>().start();
    });
    _searchCtl.addListener(() {
      final q = _searchCtl.text.trim();
      if (_query != q) {
        setState(() => _query = q);
      }
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = const Color(0xFFEDEFF3);
    final tx = AppTexts.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(child: Text(tx.inboxTitle, style: Theme.of(context).textTheme.titleLarge)),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<InboxCubit, InboxState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Friendly error handling: do not display raw Firestore index URLs
                    if (state.error != null && state.error!.isNotEmpty) {
                      final err = state.error!;
                      final isIndexError = err.contains('failed-precondition') || err.contains('requires an index');
                      final message = isIndexError
                          ? 'No message yet'
                          : 'Something went wrong. Please try again later';
                      return Center(child: Text(message, style: const TextStyle(color: Colors.red)));
                    }

                    final convs = state.conversations;

                    // If no conversations, hide search bar and show empty state
                    if (convs.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Empty message
                          SizedBox(height: 8.h),
                          Center(child: Text('No message yet')),
                        ],
                      );
                    }

                    // When conversations exist, show search bar
                    final showSearch = convs.isNotEmpty;

                    // Apply client-side filtering by other user's name
                    final filtered = _query.isEmpty
                        ? convs
                        : convs.where((c) {
                            final name = (c.otherName.isNotEmpty ? c.otherName : c.otherUid).toLowerCase();
                            return name.contains(_query.toLowerCase());
                          }).toList();

                    return Column(
                      children: [
                        if (showSearch) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(children: [
                              const Icon(Icons.search, color: Colors.black38),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtl,
                                  decoration: InputDecoration.collapsed(hintText: tx.searchNameHint),
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(height: 16.h),
                        ],
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No messages found'))
                              : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
                                  itemBuilder: (context, i) {
                                    final c = filtered[i];
                                    final title = c.otherName.isEmpty ? c.otherUid : c.otherName;
                                    final subtitle = c.otherTyping
                                        ? 'typing…'
                                        : (c.lastMessage.isEmpty ? 'No message yet' : c.lastMessage);
                                    final item = ChatListItem(
                                      title: title,
                                      subtitle: subtitle,
                                      time: _formatTime(c.lastMessageAt),
                                      unreadCount: c.unreadCount,
                                      leadingIcon: CircleAvatar(
                                        radius: 22.r,
                                        backgroundColor: const Color(0xFFEDEDED),
                                        child: const Icon(Icons.person, color: Colors.black45),
                                      ),
                                    );
                                    return InkWell(
                                      onTap: () {
                                        context.pushNamed('chat', extra: {'title': title, 'uid': c.otherUid});
                                      },
                                      child: item,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
