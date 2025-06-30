import 'package:intl/intl.dart';

class NumberFormatter {
  NumberFormatter._();

  static String formatNumberWithCommas(double value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value.round());
  }

  static String formatCurrency(double value) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(value.round())}円';
  }
}
