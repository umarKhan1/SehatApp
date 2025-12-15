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

  Route? _incomingRoute;
  Route? _callRoute;

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
          // Close active call screen if open
          if (_showingCallPage && _callRoute != null && _callRoute!.isActive) {
            navigator.removeRoute(_callRoute!);
            _callRoute = null;
            _showingCallPage = false;
          }

          _showingIncomingCall = true;
          if (kDebugMode) {
            print(
              '[CallListener] Navigating to incoming call screen for ${state.session!.callerName}',
            );
          }

          _incomingRoute = MaterialPageRoute(
            fullscreenDialog: true,
            settings: const RouteSettings(name: 'incoming_call'),
            builder: (_) => BlocProvider.value(
              value: context.read<CallCubit>(),
              child: IncomingCallPage(session: state.session!),
            ),
          );

          NavigatorService.push(_incomingRoute!)
              ?.then((_) {
                // Reset flag when the route is popped
                if (kDebugMode) {
                  print('[CallListener] Incoming call screen popped');
                }
                _showingIncomingCall = false;
                _incomingRoute = null;

                // Re-evaluate in case we need to transition
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
                _incomingRoute = null;
              });
        }
        // Handle outgoing/connecting/live calls (call page)
        else if ((state.phase == CallPhase.outgoing ||
                state.phase == CallPhase.connecting ||
                state.phase == CallPhase.live) &&
            !_showingCallPage) {
          // Remove incoming route if present (e.g. accepted call)
          if (_showingIncomingCall) {
            // Let the Navigator handle the transition, or explicitly remove?
            // If we accepted, IncomingPage might have popped itself?
            // If it didn't, we should remove it.
            if (_incomingRoute != null && _incomingRoute!.isActive) {
              navigator.removeRoute(_incomingRoute!);
            }
            _incomingRoute = null;
            _showingIncomingCall = false;
          }

          if (!_showingCallPage) {
            _showingCallPage = true;
            if (kDebugMode) {
              print('[CallListener] Navigating to active call screen');
            }

            _callRoute = MaterialPageRoute(
              fullscreenDialog: true,
              settings: const RouteSettings(name: 'active_call'),
              builder: (_) => BlocProvider.value(
                value: context.read<CallCubit>(),
                child: const CallPage(),
              ),
            );

            NavigatorService.push(_callRoute!)?.then((_) {
              // Reset flag when the route is popped
              _showingCallPage = false;
              _callRoute = null;
            });
          }
        }
        // Handle call ended
        else if (state.phase == CallPhase.ended) {
          if (kDebugMode) print('[CallListener] Call ended, cleaning up UI');

          // Robust cleanup: Pop any route named 'incoming_call' or 'active_call'
          navigator.popUntil((route) {
            final name = route.settings.name;
            if (name == 'incoming_call' || name == 'active_call') {
              if (kDebugMode) {
                print('[CallListener] Popping call route: $name');
              }
              return false; // Continue popping
            }
            return true; // Stop popping
          });

          // Clear manual references
          _incomingRoute = null;
          _callRoute = null;
          _showingIncomingCall = false;
          _showingCallPage = false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('[CallListener] Navigation error: $e');
        }
        // Reset flags on error for safety
        if (state.phase == CallPhase.ended) {
          _incomingRoute = null;
          _callRoute = null;
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
