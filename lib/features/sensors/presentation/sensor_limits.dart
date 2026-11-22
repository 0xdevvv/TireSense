import 'package:flutter/material.dart';
import 'package:tiresense/shared/theme/app_colors.dart';

abstract final class SensorLimits {
  static const weakRssi = -85;
  static const minPressure = 1.8;
  static const maxPressure = 3.0;

  static Color rssiColor(int rssi, ThemeData theme, {required bool stale}) {
    if (stale) {
      return theme.colorScheme.outline;
    }

    if (rssi < weakRssi) {
      return theme.extension<AppColors>()!.lowRssi;
    }

    return theme.colorScheme.primary;
  }

  static double pressureValue(double pressure) {
    return ((pressure - minPressure) / (maxPressure - minPressure)).clamp(0.0, 1.0);
  }
}

enum BatteryLevel {
  low(20),
  mid(50),
  high(100);

  final int value;

  const BatteryLevel(this.value);

  static BatteryLevel of(int level) {
    if (level < low.value) {
      return low;
    }

    if (level < mid.value) {
      return mid;
    }

    return high;
  }

  Color color(ThemeData theme, {required bool stale}) {
    if (stale) {
      return theme.colorScheme.outline;
    }

    final colors = theme.extension<AppColors>()!;

    return switch (this) {
      low => colors.batteryRed,
      mid => colors.batteryYellow,
      high => colors.batteryGreen,
    };
  }

  IconData get icon {
    return switch (this) {
      low => Icons.battery_alert,
      mid || high => Icons.battery_std,
    };
  }
}
