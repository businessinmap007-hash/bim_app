import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// One reminder to show on this phone at [at] (the device's own wall clock).
class ReminderPlan {
  final int id;
  final DateTime at;
  final String title;
  final String body;
  const ReminderPlan({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });
}

/// «الإشعارات المحلية للتذكيرات» — reminders the PHONE shows itself, with the user's own words (a private agenda task's
/// title never reaches the server, so a server push could only say «مهمة شخصية»). An abstraction so the sync logic is
/// tested without a device.
abstract class ReminderScheduler {
  /// Asks the system for the right to show notifications (and, on Android, to be on time). False when refused.
  Future<bool> ensurePermission();

  /// Makes exactly [plans] the reminders pending on this phone: whatever this app scheduled before is dropped.
  Future<void> replaceAll(List<ReminderPlan> plans);
}

/// The real thing — Android and iOS only (a browser or a desktop shows nothing).
class DeviceReminderScheduler implements ReminderScheduler {
  static const _channelId = 'agenda_reminders';
  static const _payload = 'agenda';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _init() => _ready ??= _plugin
      .initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // the permission is asked when there is a reminder to show, not at launch
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      )
      .then((_) {});

  @override
  Future<bool> ensurePermission() async {
    if (!supported) return false;
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final allowed = await android?.requestNotificationsPermission() ?? true;
      // Exact timing needs a permission the user grants in system settings; without it reminders still come, a little late.
      if (allowed &&
          !(await android?.canScheduleExactNotifications() ?? true)) {
        await android?.requestExactAlarmsPermission();
      }
      return allowed;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<void> replaceAll(List<ReminderPlan> plans) async {
    if (!supported) return;
    await _init();

    for (final pending in await _plugin.pendingNotificationRequests()) {
      if (pending.payload == _payload) await _plugin.cancel(id: pending.id);
    }

    final exact =
        defaultTargetPlatform != TargetPlatform.android ||
        (await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.canScheduleExactNotifications() ??
            false);

    for (final p in plans) {
      await _plugin.zonedSchedule(
        id: p.id,
        // The device-local DateTime IS the right instant; UTC is only the container.
        scheduledDate: tz.TZDateTime.from(p.at, tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Agenda reminders',
            channelDescription: 'Reminders for your tasks and medicine doses',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        title: p.title,
        body: p.body,
        payload: _payload,
      );
    }
  }
}
