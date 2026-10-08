import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/auth_service.dart';
import '../../services/google_auth_service.dart';
import '../main/main_shell.dart';
import 'google_button.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final _authService = AuthService();
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _subscription = GoogleAuthService.instance.events.listen(
        _onGoogleEvent,
        onError: (Object error) => _showMessage('Google sign-in failed. Please try again.'),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onGoogleEvent(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      _finish(event.user.authentication.idToken);
    }
  }

  Future<void> _signInOnPhone() async {
    try {
      final idToken = await GoogleAuthService.instance.signInWithPicker();
      if (idToken == null) return;
      await _finish(idToken);
    } catch (_) {
      _showMessage('Google sign-in failed. Please try again.');
    }
  }

  Future<void> _finish(String? idToken) async {
    if (idToken == null || idToken.isEmpty) {
      _showMessage('Google did not return a sign-in token.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.googleLogin(idToken: idToken);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      _showMessage(result['error'] ?? 'Google sign-in failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: double.infinity,
        height: 54,
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (kIsWeb) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Google allows a button between 200 and 400 pixels wide.
            final width = constraints.maxWidth.clamp(200.0, 400.0).toDouble();
            return Center(child: renderGoogleButton(width: width));
          },
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _signInOnPhone,
        icon: Icon(
          Icons.g_mobiledata_rounded,
          size: 28,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}