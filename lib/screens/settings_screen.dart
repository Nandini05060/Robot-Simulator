import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';


class _MainSettingsScreenState extends State<SettingsScreen> {
  // Let's implement an interactive role switch so the user can test both states!
  bool get _isAdminMode => ApiService().isAdminMode;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Session Log Out'),
          content: const Text('Are you sure you want to terminate the active operator session? Commands will revert to automated routing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ApiService().logout();
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  void _showActionDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: ApiService(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xff090d16) : const Color(0xfff8fafc),
      appBar: AppBar(
        title: const Text('System Settings'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xff131926) : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role switcher toggle for testing
            Card(
              color: const Color(0xff2563eb).withOpacity(0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xff2563eb), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.admin_panel_settings, color: Color(0xff2563eb)),
                        SizedBox(width: 12),
                        Text(
                          'Simulate Administrator Mode',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff2563eb)),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isAdminMode,
                      activeColor: const Color(0xff2563eb),
                      onChanged: (val) {
                        ApiService().setAdminMode(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Theme switcher card
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xff1e293b) : const Color(0xffcbd5e1),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                          color: isDark ? const Color(0xffa78bfa) : const Color(0xfff59e0b),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Simulate Dark Theme',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xff0f172a),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isDark,
                      activeColor: const Color(0xffa78bfa),
                      onChanged: (val) {
                        BluCursorFleetApp.of(context).toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Section
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: _isAdminMode ? const Color(0xff8b5cf6) : const Color(0xff2563eb),
                          child: Text(
                            _isAdminMode ? 'AD' : 'JD',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isAdminMode ? 'System Administrator' : 'John Doe',
                                style: theme.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isAdminMode ? 'Role: Security Admin' : 'Role: Senior Operator',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (_isAdminMode ? const Color(0xff8b5cf6) : const Color(0xff2563eb)).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _isAdminMode ? 'Clearance Level 5 (Root)' : 'Clearance Level 3 (Operator)',
                                  style: TextStyle(
                                    color: _isAdminMode ? const Color(0xff8b5cf6) : const Color(0xff2563eb),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildProfileDetailRow('Employee ID', _isAdminMode ? 'EMP-0001' : 'EMP-9942'),
                    const SizedBox(height: 8),
                    _buildProfileDetailRow('Email', _isAdminMode ? 'admin@blucursor.com' : 'operator@blucursor.com'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account details & Info
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildProfileDetailRow('Operator Console ID', 'CON-8832'),
                    const SizedBox(height: 8),
                    _buildProfileDetailRow('Registered Station', 'West Wing Control Room'),
                    const SizedBox(height: 8),
                    _buildProfileDetailRow('System Token', 'JWT_SESSION_ACTIVE_44'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact details
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Contact Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    // Admin contact
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Admin Contact Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(height: 4),
                              Text('Phone: +1 (800) 555-0199\nEmail: admin@blucursor.com', style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Support contact
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.support_agent, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Support Contact Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(height: 4),
                              Text('Phone: +1 (800) 555-0100\nEmail: support@blucursor.com', style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Permissions section
            Card(
              color: isDark ? const Color(0xff131926) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Administrative Privileges', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isAdminMode ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isAdminMode ? 'ACTIVE' : 'LOCK',
                            style: TextStyle(
                              color: _isAdminMode ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isAdminMode)
                      // Informative banner for normal user
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Colors.amber, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Only administrators can activate/deactivate accounts or manage user listings.',
                                style: TextStyle(color: Colors.grey, fontSize: 11.5, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Admin controls
                      ElevatedButton.icon(
                        onPressed: () => _showActionDialog(
                          'Activate Operator Account',
                          'Search directory and activate operator profiles. Target account credentials will be initialized.',
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Activate Operator Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff10b981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _showActionDialog(
                          'Deactivate Operator Account',
                          'Select an operator to deactivate. Session links and tokens will be permanently revoked.',
                        ),
                        icon: const Icon(Icons.block),
                        label: const Text('Deactivate Operator Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffef4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _showActionDialog(
                          'Manage Platform Users',
                          'Opening operator database directory... displaying 24 active operators.',
                        ),
                        icon: const Icon(Icons.people_outline),
                        label: const Text('Manage Platform Users'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!_isAdminMode) ...[
              OutlinedButton.icon(
                onPressed: () => _showActionDialog(
                  'Edit Profile',
                  'Profile configurations are locked by Enterprise Single Sign-On (SSO).',
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff2563eb),
                  side: const BorderSide(color: Color(0xff2563eb)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Logout Button
            ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text('Terminate Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  },
);
}

  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _MainSettingsScreenState();
}
