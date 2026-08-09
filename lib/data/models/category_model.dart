import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String type; // 'expense' | 'income' | 'both'

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.type,
  });

  static final List<CategoryModel> _customCategories = [];

  static void addCustomCategory(CategoryModel category) {
    if (!_customCategories.any((c) => c.id == category.id)) {
      _customCategories.add(category);
    }
  }

  static List<CategoryModel> get customCategories => List.unmodifiable(_customCategories);

  static List<CategoryModel> get defaultExpenseCategories => const [
        CategoryModel(
          id: 'food',
          name: 'Makan',
          icon: Icons.restaurant_rounded,
          color: Color(0xFFE5484D),
          bgColor: Color(0xFFFEECED),
          type: 'expense',
        ),
        CategoryModel(
          id: 'transport',
          name: 'Transport',
          icon: Icons.directions_car_rounded,
          color: Color(0xFF2196F3),
          bgColor: Color(0xFFE3F2FD),
          type: 'expense',
        ),
        CategoryModel(
          id: 'shopping',
          name: 'Belanja',
          icon: Icons.shopping_bag_rounded,
          color: Color(0xFF9C27B0),
          bgColor: Color(0xFFF3E5F5),
          type: 'expense',
        ),
        CategoryModel(
          id: 'entertainment',
          name: 'Hiburan',
          icon: Icons.movie_rounded,
          color: Color(0xFFFF9800),
          bgColor: Color(0xFFFFF3E0),
          type: 'expense',
        ),
        CategoryModel(
          id: 'health',
          name: 'Kesehatan',
          icon: Icons.local_hospital_rounded,
          color: Color(0xFF0E6B4F),
          bgColor: Color(0xFFE6F7EF),
          type: 'expense',
        ),
        CategoryModel(
          id: 'education',
          name: 'Pendidikan',
          icon: Icons.school_rounded,
          color: Color(0xFF607D8B),
          bgColor: Color(0xFFECEFF1),
          type: 'expense',
        ),
        CategoryModel(
          id: 'bills',
          name: 'Tagihan',
          icon: Icons.receipt_long_rounded,
          color: Color(0xFF795548),
          bgColor: Color(0xFFEFEBE9),
          type: 'expense',
        ),
        CategoryModel(
          id: 'other_expense',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          color: Color(0xFF6B7280),
          bgColor: Color(0xFFF3F4F6),
          type: 'expense',
        ),
      ];

  static List<CategoryModel> get defaultIncomeCategories => const [
        CategoryModel(
          id: 'salary',
          name: 'Gaji',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF1CAA6B),
          bgColor: Color(0xFFE6F7EF),
          type: 'income',
        ),
        CategoryModel(
          id: 'freelance',
          name: 'Freelance',
          icon: Icons.work_rounded,
          color: Color(0xFF0FA968),
          bgColor: Color(0xFFE6F7EF),
          type: 'income',
        ),
        CategoryModel(
          id: 'investment',
          name: 'Investasi',
          icon: Icons.trending_up_rounded,
          color: Color(0xFF0E6B4F),
          bgColor: Color(0xFFE6F7EF),
          type: 'income',
        ),
        CategoryModel(
          id: 'gift',
          name: 'Hadiah',
          icon: Icons.card_giftcard_rounded,
          color: Color(0xFFFF9800),
          bgColor: Color(0xFFFFF3E0),
          type: 'income',
        ),
        CategoryModel(
          id: 'bonus',
          name: 'Bonus',
          icon: Icons.stars_rounded,
          color: Color(0xFF2196F3),
          bgColor: Color(0xFFE3F2FD),
          type: 'income',
        ),
        CategoryModel(
          id: 'other_income',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          color: Color(0xFF6B7280),
          bgColor: Color(0xFFF3F4F6),
          type: 'income',
        ),
      ];

  static CategoryModel findById(String id) {
    final all = [
      ...defaultExpenseCategories,
      ...defaultIncomeCategories,
      ..._customCategories,
    ];
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryModel(
        id: id,
        name: id,
        icon: Icons.category_rounded,
        color: const Color(0xFF6B7280),
        bgColor: const Color(0xFFF3F4F6),
        type: 'both',
      ),
    );
  }
}
