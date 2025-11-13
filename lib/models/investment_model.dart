import 'package:uuid/uuid.dart';

enum InvestmentType { stock, mutualFund, mp2, bonds, crypto }

class Investment {
  final String id;
  final String userId;
  final String symbol;
  final String name;
  final int quantity;
  final double purchasePrice;
  final double currentPrice;
  final InvestmentType type;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;

  Investment({
    String? id,
    required this.userId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.type,
    DateTime? purchaseDate,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        purchaseDate = purchaseDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * purchasePrice;
  double get gainLoss => totalValue - totalCost;
  double get gainLossPercent => (gainLoss / totalCost) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'currentPrice': currentPrice,
      'type': type.toString(),
      'purchaseDate': purchaseDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'],
      userId: map['userId'],
      symbol: map['symbol'],
      name: map['name'],
      quantity: map['quantity'],
      purchasePrice: map['purchasePrice']?.toDouble() ?? 0.0,
      currentPrice: map['currentPrice']?.toDouble() ?? 0.0,
      type: _parseType(map['type']),
      purchaseDate: DateTime.parse(map['purchaseDate']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  static InvestmentType _parseType(String type) {
    return InvestmentType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => InvestmentType.stock,
    );
  }
}
