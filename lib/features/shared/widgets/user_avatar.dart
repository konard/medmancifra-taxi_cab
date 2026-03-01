import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: backgroundColor ?? AppTheme.surfaceOverlay,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppTheme.accent,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
