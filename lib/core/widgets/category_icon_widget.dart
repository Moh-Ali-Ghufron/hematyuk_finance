import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryIconWidget extends StatelessWidget {
  final String categoryId;
  final double size;
  final double iconSize;

  const CategoryIconWidget({
    super.key,
    required this.categoryId,
    this.size = 48,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryModel.findById(categoryId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(category.icon, color: category.color, size: iconSize),
    );
  }
}
