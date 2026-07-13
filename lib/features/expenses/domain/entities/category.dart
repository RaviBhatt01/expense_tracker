import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,

    // Stored as int in Firestore, converted to IconData in UI
    required int iconCode,

    // Stored as int in Firestore (color value)
    required int colorValue,

    // Whether this is expense or income category
    // stored as string in Firestore e.g. "expense"
    required String type,

    // false = default category, true = user created
    @Default(false) bool isCustom,
  }) = _Category;

  // Private constructor needed for custom getters in freezed
  const Category._();

  // Convenience getter — converts stored int back to IconData
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  // Convenience getter — converts stored int back to Color
  Color get color => Color(colorValue);
}
