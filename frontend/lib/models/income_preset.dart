import 'package:flutter/material.dart';

class IncomePreset {
  const IncomePreset({
    required this.name,
    required this.amount,
    required this.assetPath,
  });

  final String name;
  final double amount;
  final String assetPath;

  // ユーザーの年収と比較して適切なカテゴリーを返す
  String getCategoryComparison(double userIncome) {
    if (amount > userIncome) {
      return '多い';
    } else if (amount < userIncome) {
      return '少ない';
    } else {
      return '同じ';
    }
  }

  // 比較に基づいて色を決定
  Color getComparisonColor(double userIncome) {
    if (amount > userIncome) {
      return Colors.blue; // より多い場合は青
    }
    if (amount < userIncome) {
      return Colors.red; // より少ない場合は赤
    }
    return Colors.green; // 同じ場合は青
  }
}
