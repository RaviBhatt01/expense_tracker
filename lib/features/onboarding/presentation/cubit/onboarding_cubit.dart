import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  /// Check if app has been used before
  /// Uses categories collection as first-launch signal
  /// If categories exist → not first time → go home
  /// If empty → first time → show onboarding
  Future<void> checkFirstLaunch() async {
    emit(OnboardingChecking());
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // First launch — no categories seeded yet
        emit(OnboardingFirstLaunch());
      } else {
        // Already used — skip onboarding
        emit(OnboardingComplete());
      }
    } catch (e) {
      // On error default to showing onboarding
      emit(OnboardingFirstLaunch());
    }
  }

  /// Called when user finishes onboarding
  /// Categories will be seeded by CategoryCubit automatically
  void completeOnboarding() {
    emit(OnboardingComplete());
  }
}
