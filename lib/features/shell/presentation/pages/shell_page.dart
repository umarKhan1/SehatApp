import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/chat/presentation/pages/inbox_page.dart';
import 'package:sehatapp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sehatapp/features/more/presentation/pages/more_page.dart';
import 'package:sehatapp/features/shell/bloc/shell_cubit.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.redAccent;
    final inactive = Colors.black45;
    final tx = AppTexts.of(context);

    return BlocProvider(
      create: (_) => ShellCubit(),
      child: BlocBuilder<ShellCubit, ShellState>(
        builder: (context, state) {
          final pages = const [
            DashboardPage(),
            InboxPage(),
            MorePage(),
          ];
          return Scaffold(
            body: pages[state.index],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: primary,
              unselectedItemColor: inactive,
              selectedFontSize: 15,
              unselectedFontSize: 14,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              currentIndex: state.index,
              onTap: (i) => context.read<ShellCubit>().setTab(i),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: tx.navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.message),
                  activeIcon: const Icon(Icons.message),
                  label: tx.navInbox,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.grid_view),
                  activeIcon: const Icon(Icons.grid_view),
                  label: tx.navMore,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
