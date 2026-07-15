import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Simple cubit — state is just a ThemeMode
// ThemeMode.dark, ThemeMode.light, ThemeMode.system
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark); // default to dark

  void setDark() => emit(ThemeMode.dark);
  void setLight() => emit(ThemeMode.light);

  void toggle() {
    // Switch between dark and light
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
