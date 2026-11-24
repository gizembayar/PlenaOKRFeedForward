import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../widgets/brand.dart';
import '../../widgets/public_scaffold.dart';
import 'pricing_table.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key, this.cancelled = false});
  final bool cancelled;

  @override
  Widget build(BuildContext context) => PublicScaffold(
    children: [
      const SizedBox(height: 56),
      MaxWidth(
        child: Column(
          children: [
            if (cancelled)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: HighlightBar(
                  'Ödeme tamamlanmadı. Hazır olduğunda buradayız.',
                  color: Brand.mercanSoft,
                ),
              ),
            Text('Hangi sezon senin?', style: BrandText.logo(size: 48)),
            const SizedBox(height: 12),
            Text(
              'Ücretsiz başla, istediğin zaman yükselt ya da iptal et.',
              style: BrandText.body(size: 17),
            ),
            const SizedBox(height: 36),
            const PricingTable(),
            const SizedBox(height: 40),
            const _Faq(),
          ],
        ),
      ),
    ],
  );
}

class _Faq extends StatelessWidget {
  const _Faq();

  static const items = [
    (
      'Ödeme güvenli mi?',
      'Ödemeler Stripe altyapısıyla alınır; kart bilgilerin bizim sunucularımıza hiç ulaşmaz.',
    ),
    (
      'İptal edebilir miyim?',
      'Evet. Profil → Üyeliğimi yönet adımından tek tıkla iptal edebilir, kartını değiştirebilir ve faturalarını indirebilirsin.',
    ),
    (
      'Buluşmalar ve tatiller üyeliğe dahil mi?',
      'Üyelik katılım hakkı verir. Tatil ve bazı atölyeler lisanslı iş ortaklarıyla ayrıca ücretlendirilir; Premium üyeler öncelik ve indirim alır.',
    ),
    (
      'Kariyer eşleşmesi nasıl çalışır?',
      'Premium üyeler hedef ve sektör bilgilerine göre bir mentorla eşleşir ve ayda bir görüşme yapar.',
    ),
    (
      'Bu bir terapi hizmeti mi?',
      'Hayır. Platform terapi, hukuki ya da yatırım danışmanlığı sunmaz; gerektiğinde uzmana yönlendirir.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Sık sorulanlar', style: BrandText.heading(size: 28)),
      const SizedBox(height: 12),
      for (final (q, a) in items)
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            q,
            style: BrandText.heading(size: 17, color: Brand.siyah),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          expandedAlignment: Alignment.centerLeft,
          children: [Text(a, style: BrandText.body())],
        ),
    ],
  );
}
