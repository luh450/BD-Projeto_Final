import 'package:intl/intl.dart';

final formatCurrency =
    NumberFormat.simpleCurrency(locale: 'pt_BR', name: 'R\$');

extension StringExtension on String {
  String capitalize() {
    // ignore: unnecessary_this
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension DoubleToCurrency on double {
  currencyFormat() {
    return formatCurrency.format(this);
  }
}
