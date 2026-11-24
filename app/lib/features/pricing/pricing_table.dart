import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../services/billing.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';

/// Üyelik planları. Hem web vitrininde hem uygulama içinde kullanılır.
class PricingTable extends StatefulWidget {
  const PricingTable({super.key, this.highlight = Tier.icon});
  final Tier highlight;

  @override
  State<PricingTable> createState() => _PricingTableState();
}

class _PricingTableState extends State<PricingTable> {
  BillingPeriod period = BillingPeriod.yearly;
  Tier? busy;

  Future<void> _buy(Tier t) async {
    setState(() => busy = t);
    try {
      await startCheckout(context, t, period);
    } finally {
      if (mounted) setState(() => busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = context.session.tier;
    final signedIn = context.session.signedIn;
    return Column(
      children: [
        SegmentedButton<BillingPeriod>(
          segments: const [
            ButtonSegment(value: BillingPeriod.monthly, label: Text('Aylık')),
            ButtonSegment(
              value: BillingPeriod.yearly,
              label: Text('Yıllık · 2 ay hediye'),
            ),
          ],
          selected: {period},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => period = s.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: Brand.limon,
            selectedForegroundColor: Brand.kobalt,
            backgroundColor: Brand.beyaz,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 900 ? 3 : 1;
            final cards = [
              for (final t in Tier.values)
                _PlanCard(
                  tier: t,
                  period: period,
                  highlighted: t == widget.highlight,
                  isCurrent: signedIn && t == current,
                  busy: busy == t,
                  included: signedIn && current.includes(t),
                  onBuy: t == Tier.free
                      ? () => context.go(signedIn ? '/app/bugun' : '/kayit')
                      : () => _buy(t),
                ),
            ];
            if (cols == 1) {
              return Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: card,
                    ),
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
            );
          },
        ),
        if (purchaseHiddenOnThisPlatform)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Üyeliğini notdulbutcool.com üzerinden başlatıp yönetebilirsin.',
              style: BrandText.body(size: 13, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.tier,
    required this.period,
    required this.highlighted,
    required this.isCurrent,
    required this.busy,
    required this.included,
    required this.onBuy,
  });

  final Tier tier;
  final BillingPeriod period;
  final bool highlighted;
  final bool isCurrent;
  final bool busy;
  final bool included;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final dark = tier == Tier.icon;
    final fg = dark ? Brand.krem : Brand.kobalt;
    final body = dark ? Brand.krem : Brand.siyah;
    final price = period == BillingPeriod.monthly
        ? tier.monthlyPrice
        : tier.yearlyPrice;
    final suffix = period == BillingPeriod.monthly ? '/ay' : '/yıl';

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? Brand.kobalt
            : (tier == Tier.cool ? Brand.limon : Brand.beyaz),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted ? Brand.mercan : Brand.cizgi,
          width: highlighted ? 3 : 1,
        ),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tier.name,
                  style: BrandText.label(color: fg, size: 13),
                ),
              ),
              if (highlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  color: Brand.mercan,
                  child: Text(
                    'YENİ BİR SEN',
                    style: BrandText.label(color: Brand.beyaz, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(tier.tagline, style: BrandText.heading(size: 24, color: fg)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price == 0 ? 'Ücretsiz' : '₺$price',
                style: BrandText.logo(size: 40, color: fg),
              ),
              if (price > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 6),
                  child: Text(suffix, style: BrandText.body(color: body)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          for (final f in tierFeatures[tier]!)
            Bullet(
              f,
              color: dark ? Brand.limon : Brand.mercan,
              textColor: body,
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: isCurrent || included
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: fg),
                      disabledForegroundColor: fg,
                    ),
                    child: Text(isCurrent ? 'Mevcut planın' : 'Planına dahil'),
                  )
                : FilledButton(
                    onPressed: busy ? null : onBuy,
                    style: FilledButton.styleFrom(
                      backgroundColor: dark ? Brand.limon : Brand.kobalt,
                      foregroundColor: dark ? Brand.kobalt : Brand.krem,
                    ),
                    child: busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            tier == Tier.free
                                ? 'Ücretsiz başla'
                                : '${tier == Tier.icon ? "Premium" : "COOL"}\'a geç',
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
