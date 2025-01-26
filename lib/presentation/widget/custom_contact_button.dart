import 'package:flutter/material.dart';

class ContactButton {
  final Color? color;
  final Widget? icon;
  final String subtitle;
  final VoidCallback? onTap;

  ContactButton({
    this.color,
    this.icon,
    required this.subtitle,
    this.onTap,
  });
}
