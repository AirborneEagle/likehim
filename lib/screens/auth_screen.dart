import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Default landing: sign in or create an account. A subtle text link below
/// lets the user try without an account (anonymous auth).
class AuthScreen extends StatefulWidget {
  final AuthService auth;
  final VoidCallback onSignedIn;

  const AuthScreen({super.key, required this.auth, required this.onSignedIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum _Mode { signIn, createAccount }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  _Mode _mode = _Mode.signIn;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_mode == _Mode.signIn) {
        await widget.auth.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await widget.auth.signUpWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          displayName:
              _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        );
      }
      widget.onSignedIn();
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAnon() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.signInAnon();
      widget.onSignedIn();
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.signInWithGoogle();
      widget.onSignedIn();
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _humanize(Object error) {
    final raw = error.toString();
    // Strip Firebase's '[firebase_auth/...]' prefix for friendlier copy.
    final match = RegExp(r'\] (.+)$').firstMatch(raw);
    return match?.group(1) ?? raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isCreate = _mode == _Mode.createAccount;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 56, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand mark — uses the real app icon
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.25),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icon/icon_master.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Liken',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'A quiet companion for becoming\nmore like the Savior.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Sign-in / Create account segmented control
                Center(
                  child: SegmentedButton<_Mode>(
                    segments: const [
                      ButtonSegment(
                        value: _Mode.signIn,
                        label: Text('Sign in'),
                      ),
                      ButtonSegment(
                        value: _Mode.createAccount,
                        label: Text('Create account'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: _busy
                        ? null
                        : (s) => setState(() {
                              _mode = s.first;
                              _error = null;
                            }),
                  ),
                ),
                const SizedBox(height: 24),

                // Continue with Google
                _GoogleButton(
                  onPressed: _busy ? null : _continueWithGoogle,
                  label: isCreate
                      ? 'Sign up with Google'
                      : 'Sign in with Google',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: scheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: scheme.outlineVariant,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (isCreate) ...[
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'First name (optional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  autofillHints: [
                    isCreate
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if ((v ?? '').length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submitAccount,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(isCreate ? 'Create account' : 'Sign in'),
                ),
                const SizedBox(height: 36),

                // Subtle anon option
                Center(
                  child: TextButton(
                    onPressed: _busy ? null : _continueAnon,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      'Try Liken without an account',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Without an account your reflections stay only on this device.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Google sign-in button. Visually consistent with Material 3 OutlinedButton
/// but with the multi-color "G" mark that Google's brand guidelines require
/// for any "Sign in with Google" affordance.
class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const _GoogleButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const _GoogleGlyph(size: 18),
        label: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// The Google "G" mark — drawn as a CustomPaint so we don't ship an asset.
/// Approximation of Google's official mark; close enough for a sign-in
/// affordance without bundling an external image. Colors match Google's
/// brand sheet (blue 4285F4, green 34A853, yellow FBBC05, red EA4335).
class _GoogleGlyph extends StatelessWidget {
  final double size;
  const _GoogleGlyph({this.size = 18});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;
    final innerR = r * 0.42;
    final p = Paint()..style = PaintingStyle.fill;

    void wedge(double startDeg, double sweepDeg, Color c) {
      p.color = c;
      final start = startDeg * math.pi / 180;
      final sweep = sweepDeg * math.pi / 180;
      final path = Path()
        ..moveTo(cx + innerR * math.cos(start), cy + innerR * math.sin(start))
        ..lineTo(cx + r * math.cos(start), cy + r * math.sin(start))
        ..arcToPoint(
          Offset(
            cx + r * math.cos(start + sweep),
            cy + r * math.sin(start + sweep),
          ),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(
          cx + innerR * math.cos(start + sweep),
          cy + innerR * math.sin(start + sweep),
        )
        ..arcToPoint(
          Offset(
            cx + innerR * math.cos(start),
            cy + innerR * math.sin(start),
          ),
          radius: Radius.circular(innerR),
          clockwise: false,
        )
        ..close();
      canvas.drawPath(path, p);
    }

    // 4 arcs forming the ring. (Approximates the Google G; not pixel-exact.)
    wedge(-130, 70, _red);
    wedge(-60, 60, _yellow);
    wedge(0, 70, _green);
    wedge(70, 145, _blue);

    // Horizontal slot of the "G".
    final barRect = Rect.fromLTWH(cx - 0.5, cy - h * 0.08, r * 1.05, h * 0.16);
    p.color = _blue;
    canvas.drawRect(barRect, p);
    p.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(cx + r * 0.45, cy - h * 0.4, r * 0.6, h * 0.32),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
