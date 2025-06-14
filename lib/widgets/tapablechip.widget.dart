import 'package:flutter/material.dart';

Widget tappableChip({
  required String label,
  Color? backgroundColor,
  Widget? deleteIcon,
  void Function()? onTap,
  void Function()? onDeleted,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
    child: Chip(
      onDeleted: onDeleted,
      backgroundColor: backgroundColor ?? Colors.white,
      deleteIcon: deleteIcon ?? const Icon(Icons.close),
      label: GestureDetector(
        onTap: onTap, // Handle tap action here
        child: Text(label),
      ),
    ),
  );
}
