import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Shown while [AuthController] checks the stored token (see
/// AuthUnknown) — the router redirects away as soon as that resolves.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accentGold),
      ),
    );
  }
}
