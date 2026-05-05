import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/parent_auth_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/splash_screen.dart';
import 'services/remote_question_repository.dart';
import 'theme/app_theme.dart';

class KidLearnApp extends StatelessWidget {
  const KidLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => ParentAuthProvider()),
        Provider<RemoteQuestionRepository>(
          create: (_) => RemoteQuestionRepository()..warmUp(),
          dispose: (_, __) {},
        ),
      ],
      child: MaterialApp(
        title: '小學堂 Kid Learn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
