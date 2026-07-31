part of 'onboarding_cubit.dart';

abstract class OnboardingState {}

// Initial state before any check
class OnboardingInitial extends OnboardingState {}

// Checking Firestore
class OnboardingChecking extends OnboardingState {}

// First time — show onboarding slides
class OnboardingFirstLaunch extends OnboardingState {}

// Already used or onboarding done — go home
class OnboardingComplete extends OnboardingState {}
