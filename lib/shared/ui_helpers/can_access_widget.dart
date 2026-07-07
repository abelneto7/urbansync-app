import 'package:flutter/material.dart';
import '../config/auth_session.dart';

class CanAccessWidget extends StatelessWidget {
  final String permission;
  final Widget child;

  const CanAccessWidget({
    super.key,
    required this.permission,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (AuthSession.instance.hasPermission(permission)) {
      return child;
    }

    return const SizedBox.shrink();
  }
}
