import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/billing_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/nj_button.dart';
import '../../core/widgets/nj_card.dart';

/// Notify Jobs Pro & Support Developer Screen
class ProScreen extends ConsumerWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(billingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show feedback snackbars
    ref.listen<BillingState>(billingProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(billingProvider.notifier).clearStatusMessages();
      } else if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.primary,
          ),
        );
        ref.read(billingProvider.notifier).clearStatusMessages();
      }
    });

    final proProduct = billing.proProduct;
    final proPrice = proProduct?.price ?? '₹159';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify Jobs Pro'),
        actions: [
          TextButton(
            onPressed: billing.isLoading
                ? null
                : () => ref.read(billingProvider.notifier).restorePurchases(),
            child: const Text('Restore'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Hero Pro Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B2C5F), Color(0xFF159B76)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B2C5F).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Brand Emblem
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/icons/app_logo.png',
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'NOTIFY JOBS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Color(0xFF0B2C5F),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    billing.isPro
                        ? 'You are an active Pro Member! All ads disabled.'
                        : 'Supercharge your preparation with zero distractions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Feature Comparison Matrix
            NjCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFeatureRow(
                    icon: Icons.block_flipped,
                    title: '100% Ad-Free Experience',
                    subtitle: 'No banners, interstitials, or video ads ever.',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildFeatureRow(
                    icon: Icons.download_done_rounded,
                    title: 'Instant PDF Downloads',
                    subtitle:
                        'Direct notification downloads with zero waiting.',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildFeatureRow(
                    icon: Icons.bolt_rounded,
                    title: 'Instant Island & National Alerts',
                    subtitle: 'Priority routing for A&N and central alerts.',
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildFeatureRow(
                    icon: Icons.all_inclusive_rounded,
                    title: 'Lifetime Validity',
                    subtitle: 'One-time payment. No recurring subscriptions.',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Lifetime Pro Purchase Card
            if (!billing.isPro) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Lifetime Pro Access',
                      style: AppTypography.cardTitle.copyWith(
                        color: isDark ? Colors.white : AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          proPrice,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'one-time',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    NjButton(
                      label: billing.isLoading
                          ? 'Connecting...'
                          : 'Upgrade to Pro',
                      icon: Icons.workspace_premium_rounded,
                      isLoading: billing.isLoading,
                      onPressed: billing.isLoading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              ref.read(billingProvider.notifier).buyPro();
                            },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Official Google Play Store Billing • Secure Transaction',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 4. Support Developer Tip Jar (Consumable)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Support Independent Development',
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notify Jobs is built with love for job aspirants. Send a friendly tip to support server costs.',
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tip Tier Cards
            Column(
              children: [
                _buildTipTile(
                  context,
                  ref,
                  tierId: BillingProductIds.support29,
                  icon: '☕',
                  label: 'Buy a Chai',
                  amount: '₹29',
                  isDark: isDark,
                  products: billing.products,
                ),
                const SizedBox(height: 8),
                _buildTipTile(
                  context,
                  ref,
                  tierId: BillingProductIds.support59,
                  icon: '🍵',
                  label: 'Buy a Coffee',
                  amount: '₹59',
                  isDark: isDark,
                  products: billing.products,
                ),
                const SizedBox(height: 8),
                _buildTipTile(
                  context,
                  ref,
                  tierId: BillingProductIds.support99,
                  icon: '🍰',
                  label: 'Buy Snacks',
                  amount: '₹99',
                  isDark: isDark,
                  products: billing.products,
                ),
                const SizedBox(height: 8),
                _buildTipTile(
                  context,
                  ref,
                  tierId: BillingProductIds.support199,
                  icon: '📚',
                  label: 'Study Material Booster',
                  amount: '₹199',
                  isDark: isDark,
                  products: billing.products,
                ),
                const SizedBox(height: 8),
                _buildTipTile(
                  context,
                  ref,
                  tierId: BillingProductIds.support499,
                  icon: '🌟',
                  label: 'Super Supporter',
                  amount: '₹499',
                  isDark: isDark,
                  products: billing.products,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.softGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipTile(
    BuildContext context,
    WidgetRef ref, {
    required String tierId,
    required String icon,
    required String label,
    required String amount,
    required bool isDark,
    required List<dynamic> products,
  }) {
    final product = products.cast().firstWhere(
          (p) => p.id == tierId,
          orElse: () => null,
        );

    final displayPrice = product?.price ?? amount;

    return NjCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.navy,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (product != null) {
                ref.read(billingProvider.notifier).buyTip(product);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('$label ($displayPrice) contribution queued.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softGreen,
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(color: AppColors.primary, width: 0.8),
              ),
            ),
            child: Text(
              displayPrice,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
