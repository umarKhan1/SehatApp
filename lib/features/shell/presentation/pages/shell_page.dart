import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/chat/presentation/pages/inbox_page.dart';
import 'package:sehatapp/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sehatapp/features/more/presentation/pages/more_page.dart';
import 'package:sehatapp/features/shell/bloc/shell_cubit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          final pages = const [DashboardPage(), InboxPage(), MorePage()];
          return Scaffold(
            body: pages[state.index],
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: primary,
                unselectedItemColor: inactive,
                selectedFontSize: 15,
                unselectedFontSize: 14,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                currentIndex: state.index,
                onTap: (i) => context.read<ShellCubit>().setTab(i),
                items: [
                  BottomNavigationBarItem(
                    icon: const FaIcon(FontAwesomeIcons.house, size: 20),
                    activeIcon: const FaIcon(FontAwesomeIcons.house, size: 20),
                    label: tx.navHome,
                  ),
                  BottomNavigationBarItem(
                    icon: const FaIcon(FontAwesomeIcons.message, size: 20),
                    activeIcon: const FaIcon(
                      FontAwesomeIcons.solidMessage,
                      size: 20,
                    ),
                    label: tx.navInbox,
                  ),
                  BottomNavigationBarItem(
                    icon: const FaIcon(FontAwesomeIcons.grip, size: 20),
                    activeIcon: const FaIcon(FontAwesomeIcons.grip, size: 20),
                    label: tx.navMore,
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
