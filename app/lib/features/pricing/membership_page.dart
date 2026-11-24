import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../services/billing.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';
import 'pricing_table.dart';

/// Uygulama içi üyelik sayfası. Stripe Checkout dönüşü de buraya gelir
/// (`?durum=basarili`). Kayıt sırasında plan seçildiyse (`?plan=icon`)
/// ödeme akışı otomatik başlar.
class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key, this.plan, this.period, this.status});
  final String? plan;
  final String? period;
  final String? status;

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final s = context.sessionRead;
      if (widget.status == 'basarili') {
        setState(() => _refreshing = true);
        // Webhook birkaç saniye içinde profili günceller.
        for (var i = 0; i < 5 && s.tier == Tier.free; i++) {
          await s.backend.refreshMembership();
          if (s.tier != Tier.free) break;
          await Future<void>.delayed(const Duration(seconds: 2));
        }
        if (mounted) setState(() => _refreshing = false);
        return;
      }
      final plan = Tier.fromId(widget.plan);
      if (widget.plan != null && plan != Tier.free && !s.tier.includes(plan)) {
        final period = widget.period == 'monthly'
            ? BillingPeriod.monthly
            : BillingPeriod.yearly;
        await startCheckout(context, plan, period);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final success = widget.status == 'basarili';
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/app/bugun'),
        ),
        title: const Text('Üyelik'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          MaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (success)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    color: Brand.kobalt,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldin, ${s.tier.name}!',
                          style: BrandText.logo(size: 32, color: Brand.krem),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _refreshing
                              ? 'Üyeliğin etkinleştiriliyor…'
                              : 'Hayatımın yeni sezonu resmen başladı.',
                          style: BrandText.body(color: Brand.krem),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.go('/app/bugun'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Brand.limon,
                            foregroundColor: Brand.kobalt,
                          ),
                          child: const Text('Bugün’e git'),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Yeni bir sen, kendi hızında.',
                  style: BrandText.logo(size: 32),
                ),
                const SizedBox(height: 24),
                PricingTable(
                  highlight: Tier.fromId(widget.plan) == Tier.cool
                      ? Tier.cool
                      : Tier.icon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
