import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'report_screen.dart';
import 'splash_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // ─── Header ────────────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Account', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Manage your profile and preferences', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardColor,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    ),
                    child: Icon(Icons.settings_outlined, color: AppColors.accent, size: 20),
                  ),
                ),
              ]),
              SizedBox(height: 20),

              // ─── Profile Card ───────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.cardColor, AppColors.surfaceColor],
                  ),
                ),
                child: Column(children: [
                  Row(children: [
                    Stack(children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 2),
                        ),
                        child: Icon(Icons.person_rounded, color: AppColors.accent, size: 40),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => _editProfile(context, provider),
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                            child: Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ]),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(provider.userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
                        ]),
                        Text(provider.userEmail, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text('Premium User', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ]),
                    ),
                  ]),
                  SizedBox(height: 16),
                  // Stats row
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(icon: Icons.description_outlined, value: '${provider.totalNotes}', label: 'Notes', color: AppColors.accent),
                        _VertDivider(),
                        _StatItem(icon: Icons.star_outline_rounded, value: '${provider.totalFavorites}', label: 'Favorites', color: Colors.amber),
                        _VertDivider(),
                        _StatItem(icon: Icons.delete_outline_rounded, value: '${provider.totalTrash}', label: 'Trash', color: AppColors.error),
                        _VertDivider(),
                        _StatItem(icon: Icons.bar_chart_rounded, value: '${provider.allNotes.length}', label: 'Total', color: AppColors.info),
                      ],
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 16),

              // ─── Account Actions ─────────────────────────────────────────────
              _SectionLabel('ACCOUNT'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  iconBg: AppColors.accent,
                  title: 'Edit Profile',
                  subtitle: 'Update your name and display picture',
                  onTap: () => _editProfile(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconBg: Color(0xFF2E7D32),
                  title: 'Change Password',
                  subtitle: 'Send a password reset link to your email',
                  onTap: () => _changePassword(context),
                ),
                _SettingsTile(
                  icon: Icons.bar_chart_rounded,
                  iconBg: Color(0xFF1565C0),
                  title: 'Project Report',
                  subtitle: 'View notes stats and analytics',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen())),
                  showDivider: false,
                ),
              ]),
              SizedBox(height: 12),

              // ─── App Preferences ─────────────────────────────────────────────
              _SectionLabel('PREFERENCES'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  iconBg: Color(0xFF4A148C),
                  title: 'Dark Mode',
                  subtitle: 'Toggle between light and dark theme',
                  trailing: Switch(
                    value: provider.isDarkMode,
                    onChanged: (_) => provider.toggleDarkMode(),
                    activeThumbColor: AppColors.accent,
                    trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : null),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  iconBg: Color(0xFF37474F),
                  title: 'App Settings',
                  subtitle: 'Notifications, backup, and more',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
                  showDivider: false,
                ),
              ]),
              SizedBox(height: 12),

              // ─── Info ─────────────────────────────────────────────────────────
              _SectionLabel('INFO'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(icon: Icons.privacy_tip_outlined, iconBg: Color(0xFFE65100), title: 'Privacy Policy', subtitle: 'Read our privacy policy', onTap: () {}),
                _SettingsTile(icon: Icons.info_outline_rounded, iconBg: Color(0xFF00695C), title: 'About NoteWiz', subtitle: 'Version 1.0.0 — Built with Flutter & Supabase', onTap: () => _showAbout(context), showDivider: false),
              ]),
              SizedBox(height: 12),

              // ─── Danger Zone ─────────────────────────────────────────────────
              _SectionLabel('SESSION'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconBg: AppColors.error.withValues(alpha: 0.8),
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  titleColor: AppColors.error,
                  showDivider: false,
                  onTap: () => _confirmLogout(context),
                ),
              ]),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _editProfile(BuildContext context, NotesProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    final emailCtrl = TextEditingController(text: provider.userEmail);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
              SizedBox(width: 10),
              Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ]),
            SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.accent)),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              enabled: false, // Email changes require re-authentication
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
              decoration: InputDecoration(
                labelText: 'Email (read-only)',
                prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.textHint),
                helperText: 'Use "Change Password" to update your email',
                helperStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : () async {
                  setS(() => saving = true);
                  await provider.updateProfile(nameCtrl.text.trim(), emailCtrl.text.trim());
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Profile updated!', style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: saving
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final email = context.read<NotesProvider>().userEmail;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.lock_reset_rounded, color: AppColors.accent),
          SizedBox(width: 10),
          Text('Reset Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16)),
        ]),
        content: Text(
          'A password reset link will be sent to:\n\n$email',
          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final sent = await auth.sendPasswordResetEmail(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(sent ? 'Reset link sent to $email' : auth.errorMessage ?? 'Failed to send', style: GoogleFonts.poppins()),
                  backgroundColor: sent ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Send Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear notes cache BEFORE logout
              context.read<NotesProvider>().clearLocalData();
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (r) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          NoteWizLogo(size: 40),
          SizedBox(width: 12),
          Text('NoteWiz', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AboutRow('Version', '1.0.0'),
          _AboutRow('Platform', 'Flutter + Dart'),
          _AboutRow('Backend', 'Supabase (PostgreSQL)'),
          _AboutRow('Auth', 'Supabase Auth'),
          _AboutRow('Storage', 'Cloud (Supabase)'),
          _AboutRow('Developer', 'NoteWiz Team'),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Close', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  final String label, value;
  const _AboutRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 1.2));
}

class _StatItem extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _StatItem({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: color, size: 18),
    SizedBox(height: 4),
    Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textHint)),
  ]);
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: AppColors.border);
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
    child: Column(children: children),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final Color iconBg; final String title, subtitle;
  final VoidCallback? onTap; final Widget? trailing; final Color? titleColor;
  final bool showDivider;
  const _SettingsTile({required this.icon, required this.iconBg, required this.title, required this.subtitle, this.onTap, this.trailing, this.titleColor, this.showDivider = true});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor ?? AppColors.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
        onTap: onTap,
      ),
      if (showDivider) Divider(indent: 70, endIndent: 16, height: 1, color: AppColors.divider),
    ]);
  }
}
