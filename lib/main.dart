import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/notes_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aifxibcaxomzyruplxhv.supabase.co',
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpZnhpYmNheG9tenlydXBseGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczMDU2MzYsImV4cCI6MjA5Mjg4MTYzNn0.AlQNzxPBQaQfAvRb5znZ8_j08CvLqgpEDW9-D8EGC78',
  );

  // Portrait lock only on mobile — not web
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B1020),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(NoteWizApp());
}

class NoteWizApp extends StatelessWidget {
  const NoteWizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          AppColors.isLightMode = !provider.isDarkMode;
          return MaterialApp(
            title: 'NoteWiz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
