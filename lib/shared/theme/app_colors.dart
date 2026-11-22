import 'package:flutter/material.dart';

final class AppColors extends ThemeExtension<AppColors> {
  static const standard = AppColors(
    primary: Color.fromARGB(255, 254, 165, 0),
    batteryGreen: Color(0xFF16A34A),
    batteryYellow: Color(0xFFCA8A04),
    batteryRed: Color(0xFFDC2626),
    lowRssi: Color(0xFFD97706),
  );

  final Color primary;
  final Color batteryGreen;
  final Color batteryYellow;
  final Color batteryRed;
  final Color lowRssi;

  const AppColors({
    required this.primary,
    required this.batteryGreen,
    required this.batteryYellow,
    required this.batteryRed,
    required this.lowRssi,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? batteryGreen,
    Color? batteryYellow,
    Color? batteryRed,
    Color? lowRssi,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      batteryGreen: batteryGreen ?? this.batteryGreen,
      batteryYellow: batteryYellow ?? this.batteryYellow,
      batteryRed: batteryRed ?? this.batteryRed,
      lowRssi: lowRssi ?? this.lowRssi,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      batteryGreen: Color.lerp(batteryGreen, other.batteryGreen, t)!,
      batteryYellow: Color.lerp(batteryYellow, other.batteryYellow, t)!,
      batteryRed: Color.lerp(batteryRed, other.batteryRed, t)!,
      lowRssi: Color.lerp(lowRssi, other.lowRssi, t)!,
    );
  }
}
