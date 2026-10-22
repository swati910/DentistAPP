import 'package:flutter/material.dart';
import 'unified_subscription_screen.dart';

/// Legacy SubscriptionPlansScreen now delegates to the unified subscription page.
class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSubscriptionScreen();
  }
}
