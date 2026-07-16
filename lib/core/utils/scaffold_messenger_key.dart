import 'package:flutter/material.dart';

// Global scaffold messenger key
// Allows showing snackbars from anywhere without context
// Persists across widget rebuilds — fixes snackbar timer reset
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
