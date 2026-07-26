import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/auth_provider.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Şifre sıfırlama bağlantısı gönderebilmemiz için önce e-postanızı yazın.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$email adresine şifre sıfırlama bağlantısı gönderildi.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'E-posta ve şifre gerekli.');
      return;
    }
    if (_isSignUp && !_acceptedTerms) {
      setState(() => _errorText = 'Devam etmek için Gizlilik Politikası ve Kullanım Şartları\'nı kabul etmelisiniz.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_isSignUp) {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        await credential.user?.sendEmailVerification();
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }
      // On success, authStateProvider picks up the change and AuthGate swaps screens
      // (to VerifyEmailScreen first, if emailVerified is still false).
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text('CheckIt', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeTab(
                          label: 'Giriş Yap',
                          selected: !_isSignUp,
                          onTap: _isLoading ? null : () => setState(() { _isSignUp = false; _errorText = null; }),
                        ),
                      ),
                      Expanded(
                        child: _ModeTab(
                          label: 'Kayıt Ol',
                          selected: _isSignUp,
                          onTap: _isLoading ? null : () => setState(() { _isSignUp = true; _errorText = null; }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      color: AppColors.textSecondary,
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                if (!_isSignUp) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                      child: const Text('Şifremi unuttum', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
                if (_isSignUp) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: _isLoading ? null : (v) => setState(() => _acceptedTerms = v ?? false),
                      ),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('Okudum, kabul ediyorum:', style: TextStyle(fontSize: 12.5)),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                              ),
                              child: const Text(
                                'Gizlilik Politikası',
                                style: TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Text(' ve', style: TextStyle(fontSize: 12.5)),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                              ),
                              child: const Text(
                                'Kullanım Şartları',
                                style: TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isSignUp ? 'Kayıt Ol' : 'Giriş Yap'),
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

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
