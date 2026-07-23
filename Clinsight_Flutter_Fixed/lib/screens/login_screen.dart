import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'dr.verma@hospital.com');
  final _passCtrl = TextEditingController(text: 'password123');
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required.')),
      );
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    setState(() => _loading = true);
    final appState = context.read<AppState>();
    await appState.login(
      email: email,
      password: password,
      role: 'doctor',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (appState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.errorMessage!)),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>['email', 'profile'],
      );
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (!mounted) return;
      if (account == null) {
        setState(() => _googleLoading = false);
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In failed. Check Web Client ID setup.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1080),
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140F172A),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(
                              flex: 11,
                              child: _AuthImagePanel(isCompact: false)),
                          Expanded(
                              flex: 10, child: _AuthFormPanel(child: _form())),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: _AuthImagePanel(isCompact: true),
                          ),
                          _AuthFormPanel(child: _form()),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.brandCyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ClinSight AI',
                  style: GoogleFonts.ibmPlexSerif(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Clinical Intelligence Platform',
                  style: GoogleFonts.ibmPlexSans(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 30),
        Text(
          'Welcome back',
          style: GoogleFonts.ibmPlexSerif(
            color: AppTheme.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue to your dashboard.',
          style: GoogleFonts.ibmPlexSans(
            color: AppTheme.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 26),
        const _InputLabel(label: 'Email Address'),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: _emailCtrl,
          hint: 'Enter your email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        const _InputLabel(label: 'Password'),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: _passCtrl,
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          obscure: _obscure,
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.textMuted,
              size: 18,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot password?',
            style: GoogleFonts.ibmPlexSans(
              color: AppTheme.brandCyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyan,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _googleLoading ? null : _loginWithGoogle,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.borderColor),
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _googleLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.white,
                    ),
                  )
                : const Icon(Icons.g_mobiledata_rounded, size: 22),
            label: Text(
              _googleLoading ? 'Signing in...' : 'Continue with Google',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: const [
            _FeaturePill(icon: Icons.psychology, label: 'AI Powered'),
            _FeaturePill(icon: Icons.security, label: 'HIPAA Safe'),
            _FeaturePill(icon: Icons.bolt, label: '60-sec Brief'),
          ],
        ),
      ],
    );
  }
}

class _AuthImagePanel extends StatelessWidget {
  final bool isCompact;
  const _AuthImagePanel({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isCompact
          ? const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
          : const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/doctor-image.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1E293B),
                alignment: Alignment.center,
                child: const Icon(Icons.local_hospital,
                    color: Colors.white, size: 54),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cyanDark.withValues(alpha: 0.64),
                    AppTheme.cyan.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 26,
            right: 26,
            bottom: 26,
            child: Text(
              'Better triage, safer decisions, faster care.',
              style: GoogleFonts.ibmPlexSerif(
                color: Colors.white,
                fontSize: 30,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  final Widget child;
  const _AuthFormPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 26),
      child: child,
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.ibmPlexSans(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500));
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.ibmPlexSans(color: AppTheme.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.ibmPlexSans(color: AppTheme.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.brandCyan, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.ibmPlexSans(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
