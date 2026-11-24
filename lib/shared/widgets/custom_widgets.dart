import 'package:flutter/material.dart';

abstract final class CustomWidgets {
  static const circularLoading = SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
