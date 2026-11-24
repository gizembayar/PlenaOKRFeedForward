import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../widgets/brand.dart';
import '../../widgets/public_scaffold.dart';
import '../pricing/pricing_table.dart';

/// Web ana sayfası — markanın vitrini.
///
/// Hedef kitle: 35–55 yaş, boşanmış, çoğu çalışan ve/veya anne kadınlar.
/// Ton: özgür, zarif, zeki, muzip — mağduriyet dili yok.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PublicScaffold(
      children: [
        _Hero(),
        SloganMarquee(
          items: [
            'Medeni halim bekâr.',
            'Programım dolu.',
            'Kendimle randevum var.',
            'Hayatımın yeni sezonu.',
            'Bu defa kendim için.',
          ],
        ),
        _Promise(),
        _HowItWorks(),
        _Pillars(),
        _SampleWeek(),
        _CoolAreas(),
        _Manifesto(),
        _Posters(),
        _PricingSection(),
        _FinalCta(),
      ],
    );
  }
}

// ── Ortak bölüm başlığı ────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.eyebrow,
    required this.title,
    this.lead,
    this.center = false,
    this.onDark = false,
  });

  final String eyebrow;
  final String title;
  final String? lead;
  final bool center;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final ta = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 3,
              color: onDark ? Brand.limon : Brand.mercan,
            ),
            const SizedBox(width: 10),
            Text(
              eyebrow.trUpper,
              style: BrandText.label(
                color: onDark ? Brand.limon : Brand.mercan,
                size: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: ta,
          style: BrandText.logo(
            size: wide ? 46 : 34,
            color: onDark ? Brand.krem : Brand.kobalt,
          ),
        ),
        if (lead != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              lead!,
              textAlign: ta,
              style: BrandText.body(
                size: 18,
                color: onDark ? Brand.krem : Brand.metin2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

int _cols(double w, {int max = 3}) => w >= 900 ? max : (w >= 600 ? 2 : 1);

Widget _grid(
  BuildContext context,
  List<Widget> children, {
  int max = 3,
  double gap = 20,
}) => LayoutBuilder(
  builder: (context, c) {
    final cols = _cols(c.maxWidth, max: max);
    final w = (c.maxWidth - (cols - 1) * gap) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final ch in children) SizedBox(width: w, child: ch)],
    );
  },
);

// ── Hero ───────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 980;
    final headline = wide ? 78.0 : (w < 420 ? 42.0 : 56.0);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Brand.kobalt,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '35–55 YAŞ · YENİ SEZON',
            style: BrandText.label(color: Brand.krem, size: 12),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'HAYATIMDA\nKOCA BİR\nDEĞİŞİKLİK VAR.',
          style: BrandText.logo(size: headline),
        ),
        const SizedBox(height: 22),
        Text(
          'Boşandıysan, hayatından boşanmadın.',
          style: BrandText.heading(size: wide ? 26 : 21, color: Brand.siyah),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(
            'Hayata tutunmanın çok ötesi: yeni bir sen. Nefes, eğitimler, kariyer, '
            'yeni arkadaşlar, beraber tatiller, spor ve beslenme — hepsi senin '
            'zamanına, bütçene ve enerjine göre.',
            style: BrandText.body(size: 18, color: Brand.metin2),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            FilledButton(
              onPressed: () => context.go('/kayit'),
              child: const Text('Benim Hayatım’ı oluştur'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/uyelik'),
              child: const Text('Üyelikleri incele'),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 22,
          runSpacing: 10,
          children: [
            for (final t in [
              'Ücretsiz başla',
              'İstediğin zaman iptal',
              '2 dakikada kişisel plan',
            ])
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Brand.mercan),
                  const SizedBox(width: 8),
                  Text(t, style: BrandText.body(size: 15, color: Brand.siyah)),
                ],
              ),
          ],
        ),
      ],
    );

    return Container(
      color: Brand.krem,
      padding: EdgeInsets.symmetric(vertical: wide ? 80 : 40),
      child: MaxWidth(
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 11, child: text),
                  const SizedBox(width: 40),
                  const Expanded(flex: 9, child: _HeroArt(size: 460)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text,
                  const SizedBox(height: 40),
                  const Center(child: _HeroArt(size: 320)),
                ],
              ),
      ),
    );
  }
}

/// Marka panosundaki kompozisyon: daireler + "The Icon" kartı + etiketler.
class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size;
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: s * 0.04, top: 0, child: Dot(s * 0.72, Brand.limon)),
          Positioned(
            right: 0,
            bottom: s * 0.02,
            child: Dot(s * 0.42, Brand.mercan),
          ),
          // The Icon kartı
          Positioned(
            left: s * 0.18,
            top: s * 0.2,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: s * 0.56,
                height: s * 0.56,
                padding: EdgeInsets.all(s * 0.045),
                decoration: BoxDecoration(
                  color: Brand.kobalt,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33202020),
                      blurRadius: 40,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Brand.name,
                      style: BrandText.label(
                        color: Brand.krem,
                        size: s * 0.022,
                      ),
                    ),
                    SizedBox(height: s * 0.012),
                    Container(width: s * 0.06, height: 3, color: Brand.limon),
                    const Spacer(),
                    Text(
                      'Hayatımın\nyeni\nsezonu.',
                      style: BrandText.logo(size: s * 0.075, color: Brand.krem),
                    ),
                    const Spacer(),
                    Text(
                      'THE GOOD LIFE.',
                      style: BrandText.label(color: Brand.krem, size: s * 0.02),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: s * 0.02,
            top: s * 0.12,
            child: Sticker(
              'PROGRAMIM DOLU.',
              color: Brand.beyaz,
              textColor: Brand.kobalt,
              angle: 0.08,
            ),
          ),
          Positioned(
            left: 0,
            bottom: s * 0.14,
            child: const Sticker('HAYAT SENİN!', angle: -0.08),
          ),
        ],
      ),
    );
  }
}

// ── Marka vaadi ────────────────────────────────────────────────────────────

class _Promise extends StatelessWidget {
  const _Promise();

  @override
  Widget build(BuildContext context) {
    const promises = [
      ('KİŞİSEL', 'İlgi alanlarına, zamanına ve bütçene uygun seçimler.'),
      ('GERÇEK HAYAT', 'Etkinlikler, yeni arkadaşlar, deneyimler ve hareket.'),
      ('ÖZGÜR', 'Bir başkasını beklemeden, kendine ait bir yaşam.'),
      ('ESNEK', 'Çocuklu ya da çocuksuz; farklı enerji seviyelerine uygun.'),
    ];
    return Container(
      color: Brand.kobalt,
      padding: const EdgeInsets.symmetric(vertical: 88),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHead(
              eyebrow: 'Marka felsefesi',
              title: 'Daha fazla eğitim değil.\nDaha fazla hayat.',
              lead:
                  'Boşanmayı kadının tek kimliği olarak görmüyoruz. Daha özgür ve kendine ait '
                  'bir yaşamı keşfettiği bir hayat dönemi olarak görüyoruz. Amacımız ekranda '
                  'kalman değil — kendi hayatında yeni şeyler yapman.',
              onDark: true,
            ),
            const SizedBox(height: 48),
            _grid(context, max: 4, [
              for (final (t, d) in promises)
                Container(
                  padding: const EdgeInsets.only(top: 18),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Brand.limon, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t,
                        style: BrandText.label(color: Brand.limon, size: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        d,
                        style: BrandText.body(color: Brand.krem, size: 17),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Nasıl çalışır ──────────────────────────────────────────────────────────

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'Beni tanı',
        'İki dakikada “Benim Hayatım”: ilgi alanların, zamanın, bütçen. Eski eşin adı değil, senin isteklerin.',
        Brand.limon,
      ),
      (
        '02',
        'Bana az ama uygun seçenek ver',
        'Yüzlerce etkinlik yerine bu hafta sana gerçekten uyan 3 öneri.',
        Brand.mercanSoft,
      ),
      (
        '03',
        'Ekranın dışına çıkar',
        'Atölye, kahve, yürüyüş, yeni bir hobi. Planın enerjine ve haftana göre değişir.',
        Brand.kobaltSoft,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHead(
              eyebrow: 'Nasıl çalışır?',
              title: 'Bir içerik arşivi değil.\nO gün yapabileceğin bir şey.',
            ),
            const SizedBox(height: 40),
            _grid(context, [
              for (final (n, t, d, c) in steps)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n,
                        style: BrandText.logo(size: 56, color: Brand.mercan),
                      ),
                      const SizedBox(height: 18),
                      Text(t, style: BrandText.heading(size: 22)),
                      const SizedBox(height: 10),
                      Text(
                        d,
                        style: BrandText.body(size: 16, color: Brand.siyah),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── İçeride ne var? ────────────────────────────────────────────────────────

class _Pillars extends StatelessWidget {
  const _Pillars();

  @override
  Widget build(BuildContext context) {
    const pillars = [
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
        '“Kendime ayırdığım 8 dakika” — anında başlayan rehberli nefes.',
      ),
      (
        Icons.handshake_outlined,
        'Kariyer eşleşmeleri',
        '1:1 mentor eşleşmesi ve kadın dostu iş fırsatları.',
      ),
      (
        Icons.diversity_3_outlined,
        'Networking',
        'Cool Women Network akşamları: kartvizit değil, hikâye.',
      ),
      (
        Icons.local_cafe_outlined,
        'Buluşmalar',
        'Küçük, moderatörlü gruplar; güvenli buluşma ilkeleriyle.',
      ),
      (
        Icons.luggage_outlined,
        'Beraber tatil',
        'Kadın kadına ya da anne-çocuk; lisanslı acentelerle.',
      ),
      (
        Icons.directions_walk,
        'Spor',
        'Yürüyüş, pilates, yoga, dans — performans değil, keyif.',
      ),
      (
        Icons.restaurant_outlined,
        'Beslenme',
        'Haftalık planlar ve 20 dakikalık tarifler.',
      ),
    ];
    return Padding(
      key: const ValueKey('egitimler'),
      padding: const EdgeInsets.only(top: 104),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHead(
              eyebrow: 'İçeride ne var?',
              title: 'Yeni bir sen için\nher şey, tek bir yerde.',
            ),
            const SizedBox(height: 40),
            _grid(context, [
              for (final (icon, t, d) in pillars)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Brand.beyaz,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: Brand.golge,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Brand.limon,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Brand.kobalt, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t, style: BrandText.heading(size: 19)),
                            const SizedBox(height: 6),
                            Text(
                              d,
                              style: BrandText.body(
                                size: 15,
                                color: Brand.metin2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Bir hafta, bir kadın ───────────────────────────────────────────────────

class _SampleWeek extends StatelessWidget {
  const _SampleWeek();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    const days = [
      (
        'PAZARTESİ',
        '8 dakika nefes çalışması',
        'Evde, güne başlamadan önce.',
        Brand.limon,
      ),
      (
        'CUMA',
        'Yürüyüş grubu + arkadaşa mesaj',
        'İşten sonra hafif hareket ve sosyal bir adım.',
        Brand.kobaltSoft,
      ),
      (
        'PAZAR',
        'Anne-çocuk sanat rotası',
        'İkisinin de sıkılmadığı bir öğleden sonra.',
        Brand.mercanSoft,
      ),
    ];

    final persona = Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Brand.kobalt,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Brand.mercan,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '44',
                  style: BrandText.logo(size: 28, color: Brand.beyaz),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'İstanbul · çalışıyor · 13 yaşında bir çocuğu var',
                  style: BrandText.body(color: Brand.krem, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '“Sosyal çevremi genişletmek, kendime zaman ayırmak ve çocuğumla yeni şeyler yaşamak istiyorum.”',
            style: BrandText.italic(
              color: Brand.krem,
              size: 21,
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in [
                'Sosyal çevre',
                'COOL SPORT',
                'Anne-çocuk zamanı',
              ])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Brand.limon,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(t, style: BrandText.label(size: 12)),
                ),
            ],
          ),
        ],
      ),
    );

    final week = Column(
      children: [
        for (final (day, t, d, c) in days)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Brand.beyaz,
                borderRadius: BorderRadius.circular(22),
                boxShadow: Brand.golge,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 116,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(22),
                        ),
                      ),
                      child: Text(day, style: BrandText.label(size: 13)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t, style: BrandText.heading(size: 19)),
                            const SizedBox(height: 6),
                            Text(
                              d,
                              style: BrandText.body(
                                size: 15,
                                color: Brand.metin2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Örnek kullanıcı temsilidir.',
            style: BrandText.body(size: 13, color: Brand.metin2),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 104),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHead(
              eyebrow: 'Bir hafta, bir kadın',
              title: 'Büyük değişiklikler,\nküçük adımlarla başlar.',
            ),
            const SizedBox(height: 40),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: persona),
                  const SizedBox(width: 24),
                  Expanded(flex: 7, child: week),
                ],
              )
            else ...[
              persona,
              const SizedBox(height: 20),
              week,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Yedi COOL alanı ────────────────────────────────────────────────────────

class _CoolAreas extends StatelessWidget {
  const _CoolAreas();

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('sport'),
    padding: const EdgeInsets.only(top: 104),
    child: MaxWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHead(
            eyebrow: 'Yedi COOL alanı',
            title: 'Yaşamın bütün renkleri.',
            lead: 'Kendi ihtiyacına göre seç; alanlar birbiriyle bağlantılı çalışır.',
          ),
          const SizedBox(height: 40),
          _grid(context, max: 4, gap: 16, [
            for (final a in CoolArea.values) AreaCard(a),
          ]),
          const SizedBox(height: 24),
          const HighlightBar(
            'Kendi hayatın. Kendi hızın. Kendi seçimin.',
            size: 18,
          ),
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      boxShadow: Brand.golge,
    ),
    child: Material(
      color: Brand.beyaz,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: area.color,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      area.title,
                      style: BrandText.logo(size: 21, color: Brand.beyaz),
                    ),
                  ),
                  Icon(area.icon, color: Brand.beyaz),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(area.subtitle, style: BrandText.heading(size: 17)),
                  const SizedBox(height: 8),
                  Text(
                    area.keywords,
                    style: BrandText.body(size: 15, color: Brand.metin2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Manifesto ──────────────────────────────────────────────────────────────

class _Manifesto extends StatelessWidget {
  const _Manifesto();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    const lines = [
      'Dul kelimesi bir etiket. Biz etiket değil, sezon seviyoruz.',
      'Kendine zaman ayırmak bencillik değil, bakım.',
      'Yalnız başına kahve içmek, cesaretin en zarif hâli.',
      'Yeni arkadaşlar 45 yaşında da edinilir. 55’te de.',
      'Hayatın planı yoksa, birlikte bir tane yaparız.',
    ];
    return Container(
      margin: const EdgeInsets.only(top: 104),
      color: Brand.mercan,
      padding: const EdgeInsets.symmetric(vertical: 88),
      child: MaxWidth(
        child: Flex(
          direction: wide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: wide ? 5 : 0,
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MANİFESTO',
                    style: BrandText.label(color: Brand.siyah, size: 13),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Not dul,\nbut cool.',
                    style: BrandText.logo(
                      size: wide ? 84 : 56,
                      color: Brand.siyah,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: wide ? 48 : 0, height: wide ? 0 : 32),
            Flexible(
              flex: wide ? 7 : 0,
              fit: FlexFit.loose,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final l in lines)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0x40202020)),
                        ),
                      ),
                      child: Text(
                        l,
                        style: BrandText.heading(
                          size: wide ? 24 : 20,
                          color: Brand.siyah,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Instagram dili ─────────────────────────────────────────────────────────

class _Posters extends StatelessWidget {
  const _Posters();

  @override
  Widget build(BuildContext context) {
    const posters = [
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
      padding: const EdgeInsets.only(top: 104),
      child: MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHead(
              eyebrow: '@notdulbutcool',
              title: 'Kendine her gün\nküçük bir not.',
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 900 ? 4 : 2;
                final w = (c.maxWidth - (cols - 1) * 16) / cols;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final (t, bg, fg, ac) in posters)
                      Container(
                        width: w,
                        decoration: const BoxDecoration(boxShadow: Brand.golge),
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
          ],
        ),
      ),
    );
  }
}

// ── Üyelik ─────────────────────────────────────────────────────────────────

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 112),
    child: MaxWidth(
      child: Column(
        children: [
          const _SectionHead(
            eyebrow: 'Üyelik',
            title: 'Hangi sezon senin?',
            lead: 'Ücretsiz başla. Hazır olduğunda yükselt, istediğin zaman iptal et.',
            center: true,
          ),
          const SizedBox(height: 40),
          const PricingTable(),
        ],
      ),
    ),
  );
}

// ── Kapanış ────────────────────────────────────────────────────────────────

class _FinalCta extends StatelessWidget {
  const _FinalCta();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Padding(
      padding: const EdgeInsets.only(top: 104),
      child: MaxWidth(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Brand.beyaz,
            borderRadius: BorderRadius.circular(32),
            boxShadow: Brand.golge,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -60,
                top: -60,
                child: Dot(wide ? 240 : 160, Brand.limon),
              ),
              Positioned(
                right: wide ? 120 : 40,
                bottom: -50,
                child: Dot(wide ? 140 : 90, Brand.mercan),
              ),
              Padding(
                padding: EdgeInsets.all(wide ? 64 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wordmark(size: wide ? 72 : 46, twoLines: true),
                    const SizedBox(height: 24),
                    const HighlightBar(Brand.slogan, size: 18),
                    const SizedBox(height: 24),
                    Text(
                      'Bu defa kendim için.',
                      style: BrandText.italic(size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Web’de keşfet, uygulamada her gün yaşa. Tek hesap, iki ekran.',
                      style: BrandText.body(size: 17, color: Brand.metin2),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () => context.go('/kayit'),
                      child: const Text('Ücretsiz başla'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
