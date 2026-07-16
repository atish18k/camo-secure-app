enum CamoMessageValidity {
  fiveMinutes,
  tenMinutes,
  oneHour,
  fourHours,
  oneDay,
  unlimited,
}

extension CamoMessageValidityContract on CamoMessageValidity {
  String get wireName => switch (this) {
    CamoMessageValidity.fiveMinutes => 'five_minutes',
    CamoMessageValidity.tenMinutes => 'ten_minutes',
    CamoMessageValidity.oneHour => 'one_hour',
    CamoMessageValidity.fourHours => 'four_hours',
    CamoMessageValidity.oneDay => 'one_day',
    CamoMessageValidity.unlimited => 'unlimited',
  };

  Duration? get duration => switch (this) {
    CamoMessageValidity.fiveMinutes => const Duration(minutes: 5),
    CamoMessageValidity.tenMinutes => const Duration(minutes: 10),
    CamoMessageValidity.oneHour => const Duration(hours: 1),
    CamoMessageValidity.fourHours => const Duration(hours: 4),
    CamoMessageValidity.oneDay => const Duration(days: 1),
    CamoMessageValidity.unlimited => null,
  };
}
