/// A patient's usual meal times (H:i), off which food-tied medication doses
/// are scheduled — see Api\V2\MealTimeController.
class MealTimes {
  final String breakfastAt;
  final String lunchAt;
  final String dinnerAt;

  const MealTimes({required this.breakfastAt, required this.lunchAt, required this.dinnerAt});

  factory MealTimes.fromJson(Map<String, dynamic> json) => MealTimes(
    breakfastAt: json['breakfast_at'] as String,
    lunchAt: json['lunch_at'] as String,
    dinnerAt: json['dinner_at'] as String,
  );
}

/// How long before an appointment (two lead times, the second optional) and
/// before an agenda item the user wants to be reminded — see
/// Api\V2\ReminderPreferenceController.
class ReminderPreferences {
  final int appointmentFirstLeadMinutes;
  final int? appointmentSecondLeadMinutes;
  final int agendaLeadMinutes;

  const ReminderPreferences({
    required this.appointmentFirstLeadMinutes,
    required this.appointmentSecondLeadMinutes,
    required this.agendaLeadMinutes,
  });

  factory ReminderPreferences.fromJson(Map<String, dynamic> json) => ReminderPreferences(
    appointmentFirstLeadMinutes: json['appointment_first_lead_minutes'] as int,
    appointmentSecondLeadMinutes: json['appointment_second_lead_minutes'] as int?,
    agendaLeadMinutes: json['agenda_lead_minutes'] as int,
  );
}
