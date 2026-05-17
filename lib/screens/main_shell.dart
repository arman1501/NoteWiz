import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/notes_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/login_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onSearchTap: () => setState(() => _currentIndex = 1)),
    SearchScreen(),
    AccountScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Load notes when shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().init();
    });

    // Listen for session expiry — redirect to login automatically
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session == null && mounted) {
        context.read<NotesProvider>().clearLocalData();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NotesProvider>(); // Rebuild on theme change

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
