import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'operator@blucursor.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _rememberMe = true;
  bool _showPassword = false;
  bool _isLoading = false;
  bool _isBiometricScanning = false;
  String _biometricStatus = 'INITIALIZING BIO-LINK...';
  double _biometricProgress = 0.0;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final success = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (success) {
        setState(() {
          _isBiometricScanning = true;
          _biometricStatus = "ESTABLISHING SECURE CONNECTION...";
          _biometricProgress = 0.05;
        });

        // Sequence of biometric log details
        const logs = [
          "INITIALIZING BIO-LINK MONITOR...",
          "SCANNING RETINAL PROFILE...",
          "BIOMETRICS MATCHED: OPERATOR CERTIFIED",
          "SYNCING NEURAL ROUTER...",
          "SYSTEM ONLINE. FLEET BEACON NOMINAL"
        ];

        for (int i = 0; i < logs.length; i++) {
          Future.delayed(Duration(milliseconds: 500 + i * 500), () {
            if (mounted && _isBiometricScanning) {
              setState(() {
                _biometricStatus = logs[i];
                _biometricProgress = (i + 1) / logs.length;
              });
            }
          });
        }

        Future.delayed(const Duration(milliseconds: 3000), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/greeting');
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Check credentials/server.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xff55E8FF); // Electric Blue
    const accentColor = Color(0xff00D2FF);  // Neon Blue Accent
    const darkSurface = Color(0xff141822); // Obsidian Card
    const darkBg = Color(0xff090A0F);      // Dark Space Bg

    if (_isBiometricScanning) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Stack(
          children: [
            // Grid Background Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: 1.2,
                    colors: [
                      primaryColor.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  
                  // Scanning Rings
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                      ),
                      // Stylized Botriq Logo Icon Scan Target
                      Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.32,
                            child: Image.asset(
                              'assets/botriq_logo.png',
                              color: primaryColor,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 175,
                        height: 175,
                        child: CircularProgressIndicator(
                          value: _biometricProgress,
                          color: primaryColor,
                          backgroundColor: Colors.transparent,
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  
                  // Progress details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        Text(
                          _biometricStatus,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            letterSpacing: 0.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 3.5,
                          width: 170,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 170 * _biometricProgress,
                              height: 3.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff00a3ff), primaryColor],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Cyberpunk Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/login_bg_new.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay to ensure readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xff090A0F).withOpacity(0.75),
                    const Color(0xff090A0F).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          // Cyberpunk Grid Background Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    primaryColor.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main Body
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Brand
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: darkSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.05),
                                blurRadius: 15,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo_light.png',
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Secure Operator Login',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'bluCursor Fleet Portal Access',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Glassmorphic Card Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            color: darkSurface.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.18),
                              width: 1.2,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email field
                                Text(
                                  'OPERATOR EMAIL',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined, color: primaryColor, size: 20),
                                    hintText: 'operator@blucursor.com',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter email address';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                // Password field
                                Text(
                                  'AI CORE CREDENTIAL',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outline, color: primaryColor, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                    hintText: '••••••••',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                
                                // Features (Remember Me)
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: accentColor,
                                        checkColor: darkBg,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        side: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember active session',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                
                                // Login Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: darkBg,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                color: darkBg,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'CONNECTING TO SERVER...',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'AUTHENTICATE OPERATOR',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Authorized Personnel Only • IP Logger Active',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onBackground.withOpacity(0.35),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin? Use admin@blucursor.com / admin2024',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
