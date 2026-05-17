import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = true;
  bool _loading = false;

  String get _passwordStrength {
    final p = _passCtrl.text;
    if (p.length < 4) return 'Weak';
    if (p.length < 8) return 'Medium';
    return 'Strong';
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 'Weak': return AppColors.error;
      case 'Medium': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  double get _strengthRatio {
    switch (_passwordStrength) {
      case 'Weak': return 0.25;
      case 'Medium': return 0.6;
      default: return 1.0;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate() && _agreeTerms) {
      setState(() => _loading = true);

      final auth = context.read<AuthProvider>();
      final success = await auth.signup(
          _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        if (auth.isConfirmationPending) {
          // Email confirmation required — show check-email screen
          _showEmailConfirmationDialog(_emailCtrl.text.trim());
          return;
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainShell()));
      } else {
        final msg = auth.errorMessage ?? 'Signup failed';
        final isRateLimit = msg.toLowerCase().contains('rate limit') ||
            msg.toLowerCase().contains('security purposes') ||
            msg.toLowerCase().contains('wait');

        if (isRateLimit) {
          _showRateLimitDialog(msg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } else if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to Terms of Service',
              style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showRateLimitDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timer_outlined,
                color: AppColors.warning, size: 20),
          ),
          SizedBox(width: 12),
          Text('Rate Limit Reached',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Too many sign-up emails were sent recently.',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(
                      icon: Icons.hourglass_bottom_rounded,
                      text: 'Wait 5–10 minutes, then try again.'),
                  SizedBox(height: 6),
                  _TipRow(
                      icon: Icons.alternate_email_rounded,
                      text: 'Or use a different email address.'),
                  SizedBox(height: 6),
                  _TipRow(
                      icon: Icons.info_outline_rounded,
                      text:
                          'Supabase free plan allows ~3 emails per hour.'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Got it',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailConfirmationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_read_outlined,
                color: AppColors.success, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('Confirm Your Email',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'We sent a confirmation link to:',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(email,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent)),
          ),
          SizedBox(height: 12),
          Text(
            'Click the link in your email, then come back and log in.',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ]),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Go to Login',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.accentDark.withValues(alpha: 0.6), Colors.transparent]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                    Row(
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Create', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text('Account', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.accent)),
                          Text('Start your journey with NoteWiz', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                        ]),
                        Spacer(),
                        _SmallLogo(),
                      ],
                    ),
                    SizedBox(height: 28),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.08), blurRadius: 30, offset: Offset(0, 8))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Full Name'),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _nameCtrl,
                            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(hintText: 'Enter your full name', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.accent, size: 20)),
                            validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                          ),
                          SizedBox(height: 16),
                          _FieldLabel('Email Address'),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(hintText: 'Enter your email address', prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.accent, size: 20)),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                          ),
                          SizedBox(height: 16),
                          _FieldLabel('Password'),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                          ),
                          if (_passCtrl.text.isNotEmpty) ...[
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _strengthRatio,
                                backgroundColor: AppColors.border,
                                color: _strengthColor,
                                minHeight: 4,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('Password strength: $_passwordStrength',
                                style: GoogleFonts.poppins(fontSize: 12, color: _strengthColor)),
                          ],
                          SizedBox(height: 16),
                          _FieldLabel('Confirm Password'),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                            child: Row(children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: _agreeTerms ? AppColors.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: _agreeTerms ? AppColors.accent : AppColors.border, width: 1.5),
                                ),
                                child: _agreeTerms ? Icon(Icons.check, size: 13, color: Colors.white) : null,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: RichText(text: TextSpan(children: [
                                  TextSpan(text: 'I agree to the ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                                  TextSpan(text: 'Terms of Service', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                                  TextSpan(text: ' and ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                                  TextSpan(text: 'Privacy Policy', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                                ])),
                              ),
                            ]),
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signup,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: _loading
                                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text('Sign Up', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(children: [
                            Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Or continue with', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                            ),
                            Expanded(child: Divider(color: AppColors.border)),
                          ]),
                          SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: _SocialBtn2(
                                label: 'Google',
                                icon: Icons.g_mobiledata_rounded,
                                onTap: () async {
                                  final auth = context.read<AuthProvider>();
                                  final ok = await auth.signInWithGoogle();
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(auth.errorMessage ?? 'Google sign-in failed', style: GoogleFonts.poppins()),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ));
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _SocialBtn2(
                                label: 'Apple',
                                icon: Icons.apple_rounded,
                                onTap: () async {
                                  final auth = context.read<AuthProvider>();
                                  final ok = await auth.signInWithApple();
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(auth.errorMessage ?? 'Apple sign-in failed', style: GoogleFonts.poppins()),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ));
                                  }
                                },
                              ),
                            ),
                          ]),
                          SizedBox(height: 8),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                              child: RichText(text: TextSpan(children: [
                                TextSpan(text: 'Already have an account? ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                                TextSpan(text: 'Login', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
                              ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.shield_outlined, size: 14, color: AppColors.textHint),
                        SizedBox(width: 6),
                        Text('Your data is secure with us', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                      ]),
                    ),
                    SizedBox(height: 24),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary));
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();
  @override
  Widget build(BuildContext context) {
    return NoteWizLogo(size: 72);
  }
}


class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: AppColors.accent),
      SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textSecondary)),
      ),
    ]);
  }
}

class _SocialBtn2 extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _SocialBtn2({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.inputColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.textPrimary, size: 22),
          SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}
