import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/shell/bloc/shell_cubit.dart';
import 'package:sehatapp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sehatapp/features/chat/presentation/pages/inbox_page.dart';
import 'package:sehatapp/features/more/presentation/pages/more_page.dart';

class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.redAccent;
    final inactive = Colors.black45;

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
            bottomNavigationBar: SafeArea(
              top: false,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: primary,
                unselectedItemColor: inactive,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                currentIndex: state.index,
                onTap: (i) => context.read<ShellCubit>().setTab(i),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    activeIcon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view),
                    activeIcon: Icon(Icons.grid_view),
                    label: 'More',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
