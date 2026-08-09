class TransactionModel {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final String userId;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.userId,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'expense',
      amount: (map['amount'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] is String
          ? DateTime.parse(map['date'])
          : (map['date']?.toDate() ?? DateTime.now()),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt']?.toDate() ?? DateTime.now()),
      userId: map['userId'] ?? '',
    );
  }

  // Sample mock data
  static List<TransactionModel> get mockData => [
        TransactionModel(
          id: '1',
          type: 'expense',
          amount: 45000,
          categoryId: 'food',
          note: 'Makan Siang',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '2',
          type: 'expense',
          amount: 28000,
          categoryId: 'transport',
          note: 'Gojek ke Kantor',
          date: DateTime.now().subtract(const Duration(hours: 6)),
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '3',
          type: 'income',
          amount: 8500000,
          categoryId: 'salary',
          note: 'Gaji Bulanan',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '4',
          type: 'expense',
          amount: 350000,
          categoryId: 'shopping',
          note: 'Belanja Bulanan',
          date: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 15)),
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1, hours: 4, minutes: 15)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '5',
          type: 'expense',
          amount: 80000,
          categoryId: 'entertainment',
          note: 'Tiket Bioskop',
          date: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 30)),
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1, hours: 3, minutes: 30)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '6',
          type: 'expense',
          amount: 120000,
          categoryId: 'food',
          note: 'Dinner Keluarga',
          date: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '7',
          type: 'expense',
          amount: 150000,
          categoryId: 'health',
          note: 'Beli Obat',
          date: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
          userId: 'mock_user',
        ),
        TransactionModel(
          id: '8',
          type: 'income',
          amount: 500000,
          categoryId: 'freelance',
          note: 'Project Design',
          date: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
          userId: 'mock_user',
        ),
      ];
}
