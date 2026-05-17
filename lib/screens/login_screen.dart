import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final auth = context.read<AuthProvider>();
      final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainShell()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Login failed', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter your email address above first', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final auth = context.read<AuthProvider>();
    final sent = await auth.sendPasswordResetEmail(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        sent ? 'Password reset link sent to $email' : auth.errorMessage ?? 'Failed',
        style: GoogleFonts.poppins(),
      ),
      backgroundColor: sent ? AppColors.success : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accentDark.withValues(alpha: 0.6),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    NoteWizLogo(size: 72),
                    SizedBox(height: 12),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: 'Note',
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      TextSpan(
                          text: 'Wiz',
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent)),
                    ])),
                    SizedBox(height: 4),
                    Text('Write Smart, Stay Organised',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textSecondary)),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              blurRadius: 30,
                              offset: Offset(0, 8))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome Back..',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          SizedBox(height: 4),
                          Text('Login to continue to your notes',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          SizedBox(height: 24),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                                color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.mail_outline_rounded,
                                  color: AppColors.accent, size: 20),
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Enter a valid email'
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            style: GoogleFonts.poppins(
                                color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: AppColors.accent, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Enter valid password'
                                : null,
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _rememberMe = !_rememberMe),
                                child: Row(children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _rememberMe
                                          ? AppColors.accent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: _rememberMe
                                              ? AppColors.accent
                                              : AppColors.border,
                                          width: 1.5),
                                    ),
                                    child: _rememberMe
                                        ? Icon(Icons.check,
                                            size: 13, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Remember me',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.textSecondary)),
                                ]),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: _forgotPassword,
                                child: Text('Forgot Password?',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  padding:
                                      EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14))),
                              child: _loading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text('Login',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                            ),
                          ),
                          SizedBox(height: 20),
                          // ── Or continue with ─────────────────────────────
                          Row(children: [
                            Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('Or continue with',
                                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                            ),
                            Expanded(child: Divider(color: AppColors.border)),
                          ]),
                          SizedBox(height: 16),
                          Row(children: [
                            Expanded(
                              child: _SocialBtn(
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
                              child: _SocialBtn(
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
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SignupScreen())),
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                    text: "Don't have an account? ",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                                TextSpan(
                                    text: 'Sign Up',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600)),
                              ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.shield_outlined,
                          size: 14, color: AppColors.textHint),
                      SizedBox(width: 6),
                      Text('Your data is secure with us',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textHint)),
                    ]),
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

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _SocialBtn({required this.label, required this.icon, this.onTap});

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
