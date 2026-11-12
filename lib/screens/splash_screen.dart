import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_auth_provider.dart';
import '../providers/progress_provider.dart';
import '../services/learning_progress_sync.dart';
import '../theme/app_theme.dart';
import 'main_scaffold.dart';
import 'profile/profile_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final provider = context.read<ProgressProvider>();
    final auth = context.read<ParentAuthProvider>();
    await Future.wait([
      provider.load(),
      auth.whenReady,
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ]);
    if (!mounted) return;
    if (auth.isSignedIn) {
      await auth.refreshMe();
    }
    if (!mounted) return;
    final token = auth.token;
    if (auth.isSignedIn && auth.isEmailVerified && token != null) {
      final pull = LearningProgressSync.pull(token: token, progress: provider);
      if (!provider.hasAnyProfile) {
        await pull;
      } else {
        unawaited(pull);
      }
    }
    if (!mounted) return;
    // 沒有任何帳號 → 去建立帳號畫面；有則進入主畫面
    if (!provider.hasAnyProfile) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProfileSelectScreen(goToMainAfterSelect: true),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppTheme.primaryColor,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '小學堂',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kid Learn · 一起快樂學習',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
