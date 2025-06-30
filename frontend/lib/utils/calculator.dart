class Calculator {
  Calculator._();

  static double calculateRelativeValue({
    required double currentValue,
    required double myIncome,
    required double targetIncome,
  }) {
    if (myIncome == 0 || targetIncome == 0) {
      return 0;
    }
    return (currentValue * myIncome) / targetIncome;
  }
}
