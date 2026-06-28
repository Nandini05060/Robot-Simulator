import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/fleet_state_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/control_panel_screen.dart';
import 'screens/real_time_viz_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FleetStateProvider(),
      child: const BluCursorFleetApp(),
    ),
  );
}

class BluCursorFleetApp extends StatefulWidget {
  const BluCursorFleetApp({Key? key}) : super(key: key);

  static _BluCursorFleetAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_BluCursorFleetAppState>()!;

  @override
  State<BluCursorFleetApp> createState() => _BluCursorFleetAppState();
}

class _BluCursorFleetAppState extends State<BluCursorFleetApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bluCursor Fleet Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainNavigationShell(),
        '/control_panel': (context) => const ControlPanelScreen(),
        '/real_time_viz': (context) => const RealTimeVizScreen(),
      },
    );
  }
}
