import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/number_formatter.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.targetIncomeName,
    required this.targetIncome,
    required this.relativeValue,
    required this.currentValue,
    required this.myIncome,
  });

  final String targetIncomeName;
  final double targetIncome;
  final double relativeValue;
  final double currentValue;
  final double myIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 24, right: 24, top: 24),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$targetIncomeName '
                '(${NumberFormatter.formatNumberWithCommas(targetIncome / 10000)}万円) '
                'の感覚では',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              Text(
                '¥ ${NumberFormatter.formatNumberWithCommas(relativeValue)}',
                style: TextStyle(
                  color:
                      myIncome == targetIncome
                          ? Colors.orange
                          : targetIncome > myIncome
                          ? Colors.blue
                          : Colors.red,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                '入力金額',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                '¥ ${NumberFormatter.formatNumberWithCommas(currentValue)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
