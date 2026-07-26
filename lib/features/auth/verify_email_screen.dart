import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/auth_provider.dart';

/// Blocks entry to the app until the signed-in user confirms their email —
/// closes the loophole where someone could register with an email they
/// don't own and intercept invites meant for the real owner.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  String? _info;

  Future<void> _checkVerified() async {
    setState(() {
      _isChecking = true;
      _info = null;
    });
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() => _isChecking = false);
    if (FirebaseAuth.instance.currentUser?.emailVerified != true) {
      setState(() => _info = 'Henüz doğrulanmamış görünüyor — e-postanızdaki bağlantıya tıklayıp tekrar deneyin.');
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
      if (mounted) setState(() => _info = 'Doğrulama e-postası tekrar gönderildi.');
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _info = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('E-postanızı doğrulayın', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  '$email adresine bir doğrulama bağlantısı gönderdik. '
                  'Devam edebilmeniz için o bağlantıya tıklamanız gerekiyor — bu, listelerinizi başkalarıyla '
                  'güvenle paylaşabilmeniz için önemli.',
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
                        : const Text('Doğruladım, kontrol et'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: const Text('E-postayı tekrar gönder'),
                ),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Çıkış yap', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
