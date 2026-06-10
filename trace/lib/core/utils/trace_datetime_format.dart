import 'package:intl/intl.dart';

import '../di/app_services.dart';

abstract final class TraceDateTimeFormat {
  static bool get _use24Hour {
    try {
      return AppServices.instance.settings.value.use24Hour;
    } catch (_) {
      return true;
    }
  }

  static String _timePattern([bool? use24Hour]) {
    final effective = use24Hour ?? _use24Hour;
    return effective ? 'HH:mm' : 'h:mm a';
  }

  static DateFormat time([bool? use24Hour]) => DateFormat(_timePattern(use24Hour));

  static DateFormat dateTime([bool? use24Hour]) =>
      DateFormat('MMM d, y • ${_timePattern(use24Hour)}');

  static DateFormat activityLabel([bool? use24Hour]) =>
      DateFormat('MMM d • ${_timePattern(use24Hour)}');

  static String scheduleTimeRange(DateTime start, DateTime end,
          {bool? use24Hour}) =>
      '${time(use24Hour).format(start)} — ${time(use24Hour).format(end)}';
}
