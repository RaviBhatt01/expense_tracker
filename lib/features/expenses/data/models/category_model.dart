import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final String type;
  final bool isCustom;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    required this.isCustom,
  });

  // Convert FROM Firestore document → CategoryModel
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      iconCode: data['iconCode'] as int,
      colorValue: data['colorValue'] as int,
      type: data['type'] as String,
      isCustom: data['isCustom'] as bool? ?? false,
    );
  }

  // Convert TO Firestore document → Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type,
      'isCustom': isCustom,
    };
  }

  // Convert CategoryModel → Category entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      type: type,
      isCustom: isCustom,
    );
  }

  // Convert Category entity → CategoryModel
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      type: category.type,
      isCustom: category.isCustom,
    );
  }
}
