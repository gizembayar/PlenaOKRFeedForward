import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/brand.dart';
import '../../widgets/public_scaffold.dart';
import '../pricing/pricing_table.dart';

/// Web ana sayfası — markanın vitrini.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicScaffold(
      children: [
        _Hero(),
        _Promise(),
        _ThreeDoors(),
        _Pillars(),
        _CoolAreas(),
        _Posters(),
        _PricingSection(),
        _FinalCta(),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 900;
    final headline = wide ? 76.0 : (w < 420 ? 40.0 : 52.0);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HAYATIMDA\nKOCA BİR\nDEĞİŞİKLİK VAR.',
          style: BrandText.logo(size: headline),
        ),
        const SizedBox(height: 20),
        Text(
          'Boşandıysan, hayatından boşanmadın.',
          style: BrandText.heading(size: wide ? 24 : 19, color: Brand.siyah),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Hayata tutunmanın çok ötesi: yeni bir sen. Eğitimler, nefes ve mindfulness, '
            'kariyer eşleşmeleri, buluşmalar, beraber tatiller, spor ve beslenme — '
            'hepsi senin zamanına, bütçene ve enerjine göre.',
            style: BrandText.body(size: 17),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/kayit'),
              child: const Text('Ücretsiz başla'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/uyelik'),
              child: const Text('Üyelikleri incele'),
            ),
          ],
        ),
      ],
    );

    return Container(
      color: Brand.krem,
      padding: EdgeInsets.symmetric(vertical: wide ? 88 : 48),
      child: MaxWidth(
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 3, child: text),
                  const Expanded(flex: 2, child: _Circles(size: 380)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: _Circles(size: 200),
                  ),
                  const SizedBox(height: 8),
                  text,
                ],
              ),
      ),
    );
  }
}

/// Limon ve mercan daireler + "HAYAT SENİN!"
class _Circles extends StatelessWidget {
  const _Circles({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Positioned(left: 0, top: 0, child: _dot(size * 0.78, Brand.limon)),
        Positioned(
          right: 0,
          bottom: size * 0.06,
          child: _dot(size * 0.46, Brand.mercan),
        ),
        Positioned.fill(
          child: Center(
            child: Transform.rotate(
              angle: -0.18,
              child: Text(
                'HAYAT\nSENİN!',
                textAlign: TextAlign.center,
                style: BrandText.logo(size: size * 0.13),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _dot(double d, Color c) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

class _Promise extends StatelessWidget {
  const _Promise();

  @override
  Widget build(BuildContext context) => Container(
    color: Brand.kobalt,
    padding: const EdgeInsets.symmetric(vertical: 56),
    child: MaxWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MARKA FELSEFESİ', style: BrandText.label(color: Brand.limon)),
          const SizedBox(height: 16),
          Text(
            'Daha fazla eğitim değil.\nDaha fazla hayat.',
            style: BrandText.logo(size: 44, color: Brand.krem),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              'Boşanmayı kadının tek kimliği olarak değil; daha özgür ve kendine ait bir '
              'yaşamı keşfettiği bir hayat dönemi olarak ele alıyoruz. Amacımız ekranda '
              'kalman değil — kendi hayatında yeni şeyler yapman.',
              style: BrandText.body(color: Brand.krem, size: 17),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ThreeDoors extends StatelessWidget {
  const _ThreeDoors();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('KENDİM', 'Kendine ait bir hayat keşfet', Brand.kobaltSoft),
      ('DENEYİMLER', 'Yeni şeyler dene', Brand.limonSoft),
      ('COOL SPORT', 'Hareketle hayatına enerji kat', Brand.mercanSoft),
    ];
    return Padding(
      key: const ValueKey('kesfet'),
      padding: const EdgeInsets.only(top: 56),
      child: MaxWidth(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (t, d, c) in items)
              SizedBox(
                width: MediaQuery.sizeOf(context).width >= 900
                    ? 352
                    : double.infinity,
                child: CoolCard(
                  color: c,
                  border: false,
                  onTap: () => context.go('/kayit'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t, style: BrandText.heading(size: 22)),
                      const SizedBox(height: 10),
                      Text(d, style: BrandText.body()),
                      const SizedBox(height: 28),
                      const Divider(color: Brand.kobalt),
                      Text('KEŞFET', style: BrandText.label()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Platformun içinde neler var?
class _Pillars extends StatelessWidget {
  const _Pillars();

  @override
  Widget build(BuildContext context) {
    final pillars = [
      (
        Icons.play_circle_outline,
        'Eğitimler',
        'Mini video eğitimler, PDF kitapçıklar ve sesli seriler.',
      ),
      (
        Icons.spa_outlined,
        'Mindfulness',
        'Sınırlar, farkındalık ve sabah meditasyon rutinleri.',
      ),
      (
        Icons.air,
        'Nefes',
        '“Kendime ayırdığım 8 dakika” ile anında başlayan nefes çalışmaları.',
      ),
      (
        Icons.handshake_outlined,
        'Kariyer eşleşmeleri',
        '1:1 mentor eşleşmesi ve kadın dostu iş fırsatları.',
      ),
      (
        Icons.diversity_3_outlined,
        'Networking',
        'Cool Women Network akşamları; kartvizit değil hikâye.',
      ),
      (
        Icons.event_outlined,
        'Buluşmalar',
        'Küçük gruplar, moderatörlü, güvenli buluşma ilkeleriyle.',
      ),
      (
        Icons.luggage_outlined,
        'Beraber tatil',
        'Kadın kadına ya da anne-çocuk; lisanslı acentelerle.',
      ),
      (
        Icons.directions_run,
        'Spor',
        'Yürüyüş, pilates, yoga, dans — kendi ritminde.',
      ),
      (
        Icons.restaurant_outlined,
        'Beslenme',
        'Haftalık planlar, 20 dakikalık tarifler, alışveriş listeleri.',
      ),
    ];
    return Padding(
      key: const ValueKey('egitimler'),
      padding: const EdgeInsets.only(top: 72),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İÇERİDE NE VAR?',
              style: BrandText.label(color: Brand.mercan),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni bir sen için her şey, tek bir yerde.',
              style: BrandText.heading(size: 36),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 900
                    ? 3
                    : (c.maxWidth >= 560 ? 2 : 1);
                final w = (c.maxWidth - (cols - 1) * 16) / cols;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final (icon, t, d) in pillars)
                      SizedBox(
                        width: w,
                        child: CoolCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Brand.limon,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: Brand.kobalt),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t, style: BrandText.heading(size: 18)),
                                    const SizedBox(height: 4),
                                    Text(d, style: BrandText.body(size: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CoolAreas extends StatelessWidget {
  const _CoolAreas();

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('sport'),
    padding: const EdgeInsets.only(top: 72),
    child: MaxWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yedi COOL alanı — yaşamın bütün renkleri',
            style: BrandText.heading(size: 32),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 560 ? 2 : 1);
              final w = (c.maxWidth - (cols - 1) * 16) / cols;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final a in CoolArea.values)
                    SizedBox(width: w, child: AreaCard(a)),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const HighlightBar('Kendi hayatın. Kendi hızın. Kendi seçimin.'),
        ],
      ),
    ),
  );
}

class AreaCard extends StatelessWidget {
  const AreaCard(this.area, {super.key, this.onTap});
  final CoolArea area;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Brand.kartZemin,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Brand.cizgi),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: area.color,
            padding: const EdgeInsets.all(16),
            child: Text(
              area.title,
              style: BrandText.heading(size: 18, color: Brand.beyaz),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.subtitle, style: BrandText.heading(size: 16)),
                const SizedBox(height: 8),
                Text(area.keywords, style: BrandText.body(size: 13)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Posters extends StatelessWidget {
  const _Posters();

  @override
  Widget build(BuildContext context) {
    final posters = [
      (
        'Medeni halim\nbekâr.\nProgramım dolu.',
        Brand.beyaz,
        Brand.kobalt,
        Brand.limon,
      ),
      ('Kendimle\nrandevum\nvar.', Brand.limon, Brand.kobalt, Brand.beyaz),
      ('Hayatımın\nyeni\nsezonu.', Brand.kobalt, Brand.krem, Brand.limon),
      (
        'Bu hafta\nkendin için\nne yaptın?',
        Brand.mercan,
        Brand.siyah,
        Brand.beyaz,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: MaxWidth(
        child: LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 900 ? 4 : 2;
            final w = (c.maxWidth - (cols - 1) * 16) / cols;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final (t, bg, fg, ac) in posters)
                  SizedBox(
                    width: w,
                    child: PosterCard(
                      text: t,
                      background: bg,
                      foreground: fg,
                      accent: ac,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 80),
    child: MaxWidth(
      child: Column(
        children: [
          Text('ÜYELİK', style: BrandText.label(color: Brand.mercan)),
          const SizedBox(height: 8),
          Text(
            'Medeni halim bekâr. Programım dolu.',
            textAlign: TextAlign.center,
            style: BrandText.heading(size: 34),
          ),
          const SizedBox(height: 28),
          const PricingTable(),
        ],
      ),
    ),
  );
}

class _FinalCta extends StatelessWidget {
  const _FinalCta();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 72),
    child: MaxWidth(
      child: Container(
        padding: const EdgeInsets.all(40),
        color: Brand.beyaz,
        child: Column(
          children: [
            const Wordmark(size: 54, twoLines: true),
            const SizedBox(height: 20),
            const HighlightBar(Brand.slogan),
            const SizedBox(height: 28),
            Text(
              'Web’de keşfet, uygulamada her gün yaşa. Tek hesap, iki ekran.',
              textAlign: TextAlign.center,
              style: BrandText.body(size: 16),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/kayit'),
              child: const Text('Benim Hayatım’ı oluştur'),
            ),
          ],
        ),
      ),
    ),
  );
}
