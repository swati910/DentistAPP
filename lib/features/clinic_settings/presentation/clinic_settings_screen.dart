import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// Legacy ClinicSettingsScreen now delegates to the Profile section with the Clinic Settings tab selected.
class ClinicSettingsScreen extends StatelessWidget {
  const ClinicSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(initialTabIndex: 1);
  }
}
