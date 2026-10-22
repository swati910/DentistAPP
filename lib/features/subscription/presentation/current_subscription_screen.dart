import 'package:flutter/material.dart';
import 'unified_subscription_screen.dart';

/// Legacy CurrentSubscriptionScreen now delegates to the unified subscription page.
class CurrentSubscriptionScreen extends StatelessWidget {
  const CurrentSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSubscriptionScreen();
  }
}
