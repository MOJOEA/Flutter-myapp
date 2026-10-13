// คลาสหลักสำหรับรับข้อมูล Climate
class Climate {
  final double latitude;
  final double longitude;
  final double generationTimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final CurrentUnits currentUnits;
  final CurrentData current;

  Climate({
    required this.latitude,
    required this.longitude,
    required this.generationTimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.currentUnits,
    required this.current,
  });

  // ฟังก์ชันสำหรับแปลง JSON Map ให้เป็น Object ของคลาส Climate
  factory Climate.fromJson(Map<String, dynamic> json) {
    return Climate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      generationTimeMs: (json['generationtime_ms'] as num).toDouble(),
      utcOffsetSeconds: json['utc_offset_seconds'] as int,
      timezone: json['timezone'] as String,
      timezoneAbbreviation: json['timezone_abbreviation'] as String,
      elevation: (json['elevation'] as num).toDouble(),
      currentUnits: CurrentUnits.fromJson(json['current_units']),
      current: CurrentData.fromJson(json['current']),
    );
  }
}

// คลาสย่อยสำหรับเก็บหน่วยวัด (current_units)
class CurrentUnits {
  final String time;
  final String interval;
  final String temperature2m;

  CurrentUnits({
    required this.time,
    required this.interval,
    required this.temperature2m,
  });

  factory CurrentUnits.fromJson(Map<String, dynamic> json) {
    return CurrentUnits(
      time: json['time'] as String,
      interval: json['interval'] as String,
      temperature2m: json['temperature_2m'] as String,
    );
  }
}

// คลาสย่อยสำหรับเก็บค่าสภาพอากาศปัจจุบัน (current)
class CurrentData {
  final String time;
  final int interval;
  final double temperature2m;

  CurrentData({
    required this.time,
    required this.interval,
    required this.temperature2m,
  });

  factory CurrentData.fromJson(Map<String, dynamic> json) {
    return CurrentData(
      time: json['time'] as String,
      interval: json['interval'] as int,
      temperature2m: (json['temperature_2m'] as num).toDouble(),
    );
  }
}
