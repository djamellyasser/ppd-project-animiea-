import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tfpxbjeypwxosowjujmk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmcHhiamV5cHd4b3Nvd2p1am1rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MjI0NTYsImV4cCI6MjA5MjA5ODQ1Nn0.w80kTvFl42tghwJhFL-zGqmGshqxsRWXxTcrEc6Mztk',
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const AnemiaLensApp());
}

class AnemiaLensApp extends StatelessWidget {
  const AnemiaLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnemiaLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.bg,
              body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            );
          }
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}