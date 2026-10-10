import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/onboarding_provider.dart';
import '../../l10n/app_localizations.dart';
import '../create_list/create_list_screen.dart';

/// First-run intro, shown once per account (see DashboardScreen): what the app
/// is for, what the first list should be, then straight into creating it —
/// either by hand or drafted by AI. Everything is skippable.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  int _kindIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_ListKind> _kinds(AppLocalizations l10n) => [
        _ListKind(Icons.shopping_cart_outlined, l10n.onboardKindShopping, l10n.onboardTitleShopping, l10n.onboardPromptShopping, 'Market Alışverişi'),
        _ListKind(Icons.flight_takeoff_rounded, l10n.onboardKindTravel, l10n.onboardTitleTravel, l10n.onboardPromptTravel, 'Seyahat'),
        _ListKind(Icons.home_outlined, l10n.onboardKindHome, l10n.onboardTitleHome, l10n.onboardPromptHome, 'Ev İşleri'),
        _ListKind(Icons.restaurant_menu_rounded, l10n.onboardKindRecipe, l10n.onboardTitleRecipe, l10n.onboardPromptRecipe, null),
        _ListKind(Icons.celebration_outlined, l10n.onboardKindEvent, l10n.onboardTitleEvent, l10n.onboardPromptEvent, 'Özel Günler'),
        _ListKind(Icons.work_outline_rounded, l10n.onboardKindWork, l10n.onboardTitleWork, l10n.onboardPromptWork, 'İş'),
        _ListKind(Icons.more_horiz_rounded, l10n.onboardKindOther, l10n.onboardTitleOther, l10n.onboardPromptOther, null),
      ];

  void _next() {
    _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  /// Marks the intro as done and leaves it — optionally straight into the
  /// create-list screen.
  Future<void> _finish({_ListKind? createManually, _ListKind? createWithAi}) async {
    await ref.read(onboardingDoneProvider.notifier).markDone();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (createManually != null) {
      navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => CreateListScreen(initialTitle: createManually.title, initialCategory: createManually.category),
      ));
    } else if (createWithAi != null) {
      navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => CreateListScreen(aiPromptSeed: createWithAi.prompt),
      ));
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kinds = _kinds(l10n);
    final kind = kinds[_kindIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(l10n.onboardSkip, style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(l10n: l10n),
                    _ChoicePage(
                      l10n: l10n,
                      kinds: kinds,
                      selected: _kindIndex,
                      onSelect: (i) => setState(() => _kindIndex = i),
                    ),
                    _StartPage(
                      l10n: l10n,
                      kind: kind,
                      onManual: () => _finish(createManually: kind),
                      onAi: () => _finish(createWithAi: kind),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: _page < 2
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: Text(l10n.onboardNext),
                        ),
                      )
                    : TextButton(
                        onPressed: _finish,
                        child: Text(l10n.onboardLater, style: const TextStyle(color: AppColors.textSecondary)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListKind {
  final IconData icon;
  final String label;
  final String title;
  final String prompt;
  final String? category;

  const _ListKind(this.icon, this.label, this.title, this.prompt, this.category);
}

class _WelcomePage extends StatelessWidget {
  final AppLocalizations l10n;

  const _WelcomePage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.onboardWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.onboardWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 28),
          _Point(icon: Icons.checklist_rounded, text: l10n.onboardPointCreate),
          _Point(icon: Icons.people_alt_rounded, text: l10n.onboardPointShare),
          _Point(icon: Icons.assignment_ind_rounded, text: l10n.onboardPointAssign),
          _Point(icon: Icons.auto_awesome_rounded, text: l10n.onboardPointAi),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Point({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _ChoicePage extends StatelessWidget {
  final AppLocalizations l10n;
  final List<_ListKind> kinds;
  final int selected;
  final ValueChanged<int> onSelect;

  const _ChoicePage({required this.l10n, required this.kinds, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardChoiceTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 8),
          Text(l10n.onboardChoiceSubtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          for (var i = 0; i < kinds.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: i == selected ? AppColors.primary : AppColors.cardBorder, width: i == selected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(kinds[i].icon, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(kinds[i].label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                      if (i == selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
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

class _StartPage extends StatelessWidget {
  final AppLocalizations l10n;
  final _ListKind kind;
  final VoidCallback onManual;
  final VoidCallback onAi;

  const _StartPage({required this.l10n, required this.kind, required this.onManual, required this.onAi});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardStartTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 8),
          Text(l10n.onboardStartSubtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _StartOption(
            icon: Icons.edit_outlined,
            title: l10n.onboardManualTitle,
            subtitle: l10n.onboardManualSubtitle,
            onTap: onManual,
          ),
          const SizedBox(height: 12),
          _StartOption(
            icon: Icons.auto_awesome_rounded,
            title: l10n.onboardAiTitle,
            subtitle: l10n.onboardAiSubtitle,
            onTap: onAi,
          ),
        ],
      ),
    );
  }
}

class _StartOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StartOption({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
