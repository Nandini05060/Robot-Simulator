import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/control_panel_screen.dart';
import 'screens/real_time_viz_screen.dart';

void main() {
  runApp(const RobotControlCenterApp());
}

class RobotControlCenterApp extends StatefulWidget {
  const RobotControlCenterApp({Key? key}) : super(key: key);

  static _RobotControlCenterAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_RobotControlCenterAppState>()!;

  @override
  State<RobotControlCenterApp> createState() => _RobotControlCenterAppState();
}

class _RobotControlCenterAppState extends State<RobotControlCenterApp> {
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
      title: 'Robot Control Center',
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
