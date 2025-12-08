import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/navigation/navigator_service.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';
import 'package:sehatapp/features/call/presentation/pages/call_page.dart';
import 'package:sehatapp/features/call/presentation/pages/incoming_call_page.dart';

/// CallListener handles incoming call navigation automatically.
///
/// This widget listens to CallCubit state changes and navigates to the appropriate
/// call screen when a call is initiated or received. It uses NavigatorService
/// for safe navigation from background listeners.
class CallListener extends StatefulWidget {
  const CallListener({super.key, required this.child});
  final Widget child;

  @override
  State<CallListener> createState() => _CallListenerState();
}

class _CallListenerState extends State<CallListener> {
  bool _showingIncomingCall = false;
  bool _showingCallPage = false;

  @override
  void initState() {
    super.initState();
    // Start listening for incoming calls after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          if (kDebugMode) {
            print('[CallListener] Starting incoming call listener');
          }
          context.read<CallCubit>().startIncomingListener();
        } catch (e) {
          if (kDebugMode) {
            print('[CallListener] Error starting incoming listener: $e');
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure listener is active whenever dependencies change
    // This helps if the user logs in after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<CallCubit>().startIncomingListener();
        } catch (e) {
          // Silently fail - listener might already be active
        }
      }
    });
  }

  /// Handle navigation based on call state changes
  void _handleNavigation(CallState state) {
    if (!mounted) return;

    if (kDebugMode) {
      print(
        '[CallListener] State changed - Phase: ${state.phase}, Session: ${state.session?.id}',
      );
      print(
        '[CallListener] Flags - Showing incoming: $_showingIncomingCall, Showing call: $_showingCallPage',
      );
    }

    // Use post-frame callback to ensure Navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final navigator = NavigatorService.navigator;
        if (navigator == null) {
          if (kDebugMode) {
            print(
              '[CallListener] Navigator not available yet, skipping navigation',
            );
          }
          return;
        }

        // Handle incoming call
        if (state.phase == CallPhase.incoming &&
            state.session != null &&
            !_showingIncomingCall) {
          // Incoming call should always take priority over any existing call screen
          if (_showingCallPage && NavigatorService.canPop()) {
            NavigatorService.pop();
            _showingCallPage = false;
          }

          _showingIncomingCall = true;
          if (kDebugMode) {
            print(
              '[CallListener] Navigating to incoming call screen for ${state.session!.callerName}',
            );
          }

          final route = MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => BlocProvider.value(
              value: context.read<CallCubit>(),
              child: IncomingCallPage(session: state.session!),
            ),
          );

          NavigatorService.push(route)
              ?.then((_) {
                // Reset flag when the route is popped
                if (kDebugMode) {
                  print('[CallListener] Incoming call screen popped');
                }
                _showingIncomingCall = false;

                // Re-evaluate navigation state in case we need to transition
                // to CallPage (e.g. accepted call)
                if (mounted) {
                  _handleNavigation(context.read<CallCubit>().state);
                }
              })
              .catchError((error) {
                if (kDebugMode) {
                  print(
                    '[CallListener] Error navigating to incoming call: $error',
                  );
                }
                _showingIncomingCall = false;
              });
        }
        // Handle outgoing/connecting/live calls (call page)
        else if ((state.phase == CallPhase.outgoing ||
                state.phase == CallPhase.connecting ||
                state.phase == CallPhase.live) &&
            !_showingCallPage) {
          // Only navigate if we're not already showing incoming call
          if (!_showingIncomingCall) {
            _showingCallPage = true;
            if (kDebugMode) {
              print('[CallListener] Navigating to call screen');
            }

            NavigatorService.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => BlocProvider.value(
                  value: context.read<CallCubit>(),
                  child: const CallPage(),
                ),
              ),
            )?.then((_) {
              // Reset flag when the route is popped
              _showingCallPage = false;
            });
          }
        }
        // Handle call ended
        else if (state.phase == CallPhase.ended) {
          _showingIncomingCall = false;
          _showingCallPage = false;

          // Pop call screens if they're showing
          if (NavigatorService.canPop()) {
            if (kDebugMode) {
              print('[CallListener] Popping call screen');
            }
            NavigatorService.pop();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('[CallListener] Navigation error: $e');
        }
        // Reset flags on error
        if (state.phase == CallPhase.ended) {
          _showingIncomingCall = false;
          _showingCallPage = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallCubit, CallState>(
      listenWhen: (prev, next) =>
          prev.phase != next.phase || prev.session?.id != next.session?.id,
      listener: (ctx, state) {
        _handleNavigation(state);
      },
      child: widget.child,
    );
  }
}
