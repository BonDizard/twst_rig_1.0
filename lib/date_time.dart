class DateTimeFormatter {
  static String formatDate(DateTime dateTime) {
    // Format date as Month day, year
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  static String formatTime(DateTime dateTime) {
    // Format time as Hour:Minute AM/PM
    int hour = dateTime.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
