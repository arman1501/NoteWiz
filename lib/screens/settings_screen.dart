import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                    RichText(text: TextSpan(children: [
                      TextSpan(text: 'Sett', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      TextSpan(text: 'ings', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    ])),
                    Text('Customize your experience', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardColor, border: Border.all(color: AppColors.border)),
                  child: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                ),
              ]),
              SizedBox(height: 20),

              // ─── App Info Card ──────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(16),
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
                child: Row(children: [
                  NoteWizLogo(size: 60),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      RichText(text: TextSpan(children: [
                        TextSpan(text: 'Note', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        TextSpan(text: 'Wiz', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ])),
                      Text('Your smart note-taking companion', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
                        child: Text('Version 1.0.0', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                ]),
              ),
              SizedBox(height: 20),



              // ─── Preferences ────────────────────────────────────────────────
              _SectionLabel('PREFERENCES'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  iconBg: Color(0xFF1B5E20),
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  trailing: Switch(value: provider.notificationsEnabled, onChanged: provider.setNotifications, activeThumbColor: AppColors.accent, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : null)),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconBg: Color(0xFF0D47A1),
                  title: 'App Lock',
                  subtitle: 'Protect your notes with passcode / biometrics',
                  trailing: Switch(value: provider.appLockEnabled, onChanged: provider.setAppLock, activeThumbColor: AppColors.accent, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : null)),
                ),
                _SettingsTile(
                  icon: Icons.cloud_upload_outlined,
                  iconBg: Color(0xFFE65100),
                  title: 'Auto Backup',
                  subtitle: 'Automatically backup your notes',
                  trailing: Switch(value: provider.autoBackupEnabled, onChanged: provider.setAutoBackup, activeThumbColor: AppColors.accent, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : null)),
                ),
                _SettingsTile(
                  icon: Icons.wifi_off_rounded,
                  iconBg: Color(0xFF00838F),
                  title: 'Offline Mode',
                  subtitle: 'Work without internet connection',
                  trailing: Switch(value: provider.offlineModeEnabled, onChanged: provider.setOfflineMode, activeThumbColor: AppColors.accent, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : null)),
                ),
                _SettingsTile(
                  icon: Icons.delete_sweep_outlined,
                  iconBg: Color(0xFF6A1B9A),
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  showDivider: false,
                  onTap: () => _clearCache(context),
                ),
              ]),
              SizedBox(height: 16),

              // ─── Support ─────────────────────────────────────────────────────
              _SectionLabel('SUPPORT'),
              SizedBox(height: 8),
              _SettingsGroup(children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconBg: Color(0xFF1565C0),
                  title: 'Help & FAQ',
                  subtitle: 'Get help and learn more',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.feedback_outlined,
                  iconBg: Color(0xFF00695C),
                  title: 'Send Feedback',
                  subtitle: 'We\'d love to hear from you',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.star_outline_rounded,
                  iconBg: AppColors.error,
                  title: 'Rate Us',
                  subtitle: 'If you like NoteWiz, please rate us',
                  showDivider: false,
                  onTap: () {},
                ),
              ]),
              SizedBox(height: 32),
              Center(
                child: Text(
                  '© 2026 NoteWiz • Developed by Arman',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _clearCache(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache cleared successfully', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 1.2));
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
  final VoidCallback? onTap; final Widget? trailing; final bool showDivider;
  const _SettingsTile({required this.icon, required this.iconBg, required this.title, required this.subtitle, this.onTap, this.trailing, this.showDivider = true});
  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
      onTap: onTap,
    ),
    if (showDivider) Divider(indent: 70, endIndent: 16, height: 1, color: AppColors.divider),
  ]);
}

