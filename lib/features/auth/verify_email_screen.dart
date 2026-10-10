import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/error_feedback.dart';
import '../../data/fcm_provider.dart';
import '../../l10n/app_localizations.dart';

/// Blocks entry to the app until the signed-in user confirms their email —
/// closes the loophole where someone could register with an email they
/// don't own and intercept invites meant for the real owner.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with WidgetsBindingObserver {
  bool _isChecking = false;
  bool _isResending = false;
  String? _info;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Silent — reload() lets AuthGate's userChanges() stream notice
    // verification and swap screens on its own; don't show "henüz
    // doğrulanmadı" just because the app came back to foreground for some
    // unrelated reason (e.g. the user merely switched apps and back).
    FirebaseAuth.instance.currentUser?.reload();
  }

  Future<void> _checkVerified() async {
    setState(() {
      _isChecking = true;
      _info = null;
    });
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() => _isChecking = false);
    if (FirebaseAuth.instance.currentUser?.emailVerified != true) {
      setState(() => _info = AppLocalizations.of(context)!.notVerifiedYet);
    }
    // If verified, userChanges() picks it up and AuthGate swaps to the dashboard.
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _info = null;
    });
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) setState(() => _info = AppLocalizations.of(context)!.verificationResent);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _info = localizedErrorMessage(context, classifyAuthError(e)));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_unread_rounded, size: 56, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(l10n.verifyEmailTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  l10n.verifyEmailBody(email),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (_info != null) ...[
                  const SizedBox(height: 16),
                  Text(_info!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary)),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerified,
                    child: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.checkVerifiedButton),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: Text(l10n.resendEmailButton),
                ),
                TextButton(
                  onPressed: () async {
                    await detachDeviceFromAccount(uid: FirebaseAuth.instance.currentUser?.uid);
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Text(l10n.signOut, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
