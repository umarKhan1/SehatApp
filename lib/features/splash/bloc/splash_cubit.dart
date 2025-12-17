import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class SplashState {}

class SplashVisible extends SplashState {}

class SplashFadingIn extends SplashState {}

class SplashFinished extends SplashState {
  SplashFinished({required this.nextRoute});
  final String nextRoute;
}

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashVisible());

  Future<void> start() async {
    // Fade in over 2s, then finish and navigate.
    emit(SplashFadingIn());
    await Future<void>.delayed(const Duration(seconds: 2));

    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Check if permissions onboarding is completed
        final prefs = await SharedPreferences.getInstance();
        final bool permissionsCompleted =
            prefs.getBool('permissions_onboarding_complete') ?? false;

        // If permissions not completed, route to permissions onboarding
        if (!permissionsCompleted) {
          emit(SplashFinished(nextRoute: 'permissionsOnboarding'));
          return;
        }

        // Fetch user doc directly to get step info
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final userData = UserModel.fromFirestore(doc);
          final int step = userData.profileStep;
          final bool completed = userData.profileCompleted;

          if (completed || step >= 3) {
            emit(SplashFinished(nextRoute: 'shell'));
          } else if (step == 2) {
            emit(SplashFinished(nextRoute: 'profileSetupStep2'));
          } else {
            emit(SplashFinished(nextRoute: 'profileSetupStep1'));
          }
        } else {
          // No user doc? Should go to setup or onboarding?
          // Assuming step 1
          emit(SplashFinished(nextRoute: 'profileSetupStep1'));
        }
      } catch (e) {
        // Fallback on error
        emit(SplashFinished(nextRoute: 'shell'));
      }
    } else {
      emit(SplashFinished(nextRoute: 'onboarding'));
    }
  }
}
