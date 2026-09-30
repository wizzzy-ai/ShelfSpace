/// 42000 -> ₦42,000
String formatNaira(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}₦$buffer';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 2026-09-28 -> 28 Sep 2026
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
