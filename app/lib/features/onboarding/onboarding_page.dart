import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';

/// İlk açılışta "Benim Hayatım" nasıl oluşur? — 5 adım.
/// Tam ad, eski eşin bilgileri, boşanma gerekçesi ya da sağlık hikâyesi
/// istenmez. Yalnızca ilgi alanları ve zaman tercihleri yeterli.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;
  late LifeProfile life;
  bool saving = false;

  static const wishOptions = [
    'Kendime zaman',
    'Sosyal hayat',
    'Yeni deneyimler',
    'Günlük düzen',
    'Kariyer',
    'Ekonomik özgürlük',
    'Hareket ve enerji',
    'Çocuğumla kaliteli zaman',
  ];
  static const timeOptions = [
    'Bugün 10 dk',
    'Hafta içi akşam',
    'Hafta sonu',
    'Çocuksuz günlerim',
  ];
  static const goalOptions = [
    'Kendime zaman ayırmak',
    'Haftada 2 kez yürüyüş',
    'Yeni biriyle tanışmak',
    'Bir atölyeye katılmak',
    'CV’mi güncellemek',
    'Her sabah 8 dk nefes',
    'Çocuğumla yeni bir yer keşfetmek',
    'Aylık bütçemi kurmak',
  ];

  @override
  void initState() {
    super.initState();
    life = context.sessionRead.life;
  }

  bool get canContinue => switch (step) {
    0 => life.wishes.isNotEmpty,
    1 => life.interests.isNotEmpty,
    2 => life.time.isNotEmpty,
    3 => true,
    _ => life.weeklyGoals.isNotEmpty,
  };

  Future<void> _next() async {
    if (step < 4) return setState(() => step++);
    setState(() => saving = true);
    await context.sessionRead.backend.saveLife(life);
    if (mounted) context.go('/app/bugun');
  }

  Set<T> _toggle<T>(Set<T> s, T v) =>
      s.contains(v) ? ({...s}..remove(v)) : {...s, v};

  @override
  Widget build(BuildContext context) {
    final titles = [
      (
        'Neler istiyorum?',
        'Bu dönemde hayatına daha çok neyi davet etmek istersin?',
      ),
      ('Neye ilgim var?', 'Yedi COOL alanından seni çekenleri seç.'),
      (
        'Neye zamanım var?',
        'Gerçekçi olalım; az ama düzenli her zaman kazanır.',
      ),
      ('Bütçem ve koşullarım', 'Önerileri buna göre süzeceğiz.'),
      (
        'Planımı oluştur',
        'Bu hafta için 1–3 küçük hedef seç. İstediğin zaman değiştirebilirsin.',
      ),
    ];
    final (title, subtitle) = titles[step];

    return Scaffold(
      body: SafeArea(
        child: MaxWidth(
          width: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  if (step > 0)
                    IconButton(
                      onPressed: () => setState(() => step--),
                      icon: const Icon(Icons.arrow_back, color: Brand.kobalt),
                    ),
                  const Wordmark(size: 18),
                  const Spacer(),
                  Text('${step + 1} / 5', style: BrandText.label()),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (step + 1) / 5,
                  minHeight: 6,
                  color: Brand.mercan,
                  backgroundColor: Brand.cizgi,
                ),
              ),
              const SizedBox(height: 32),
              Text(title, style: BrandText.logo(size: 34)),
              const SizedBox(height: 8),
              Text(subtitle, style: BrandText.body(size: 16)),
              const SizedBox(height: 24),
              Expanded(child: SingleChildScrollView(child: _stepBody())),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (step == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Senden tam ad, eski eş bilgisi ya da boşanma hikâyesi istemiyoruz. '
                          'Bilgiler yalnızca sana öneri sunmak için kullanılır.',
                          style: BrandText.body(size: 12, color: Brand.metin2),
                        ),
                      ),
                    FilledButton(
                      onPressed: canContinue && !saving ? _next : null,
                      child: Text(
                        step < 4 ? 'Devam' : 'Benim Hayatım’ı oluştur',
                      ),
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

  Widget _chips<T>(
    Iterable<T> options,
    Set<T> selected,
    String Function(T) label,
    void Function(T) onTap,
  ) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final o in options)
        FilterChip(
          label: Text(label(o)),
          selected: selected.contains(o),
          onSelected: (_) => onTap(o),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
    ],
  );

  Widget _stepBody() {
    switch (step) {
      case 0:
        return _chips<String>(
          wishOptions,
          life.wishes,
          (s) => s,
          (v) => setState(
            () => life = life.copyWith(wishes: _toggle(life.wishes, v)),
          ),
        );
      case 1:
        return Column(
          children: [
            for (final a in CoolArea.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CoolCard(
                  padding: const EdgeInsets.all(14),
                  color: life.interests.contains(a) ? Brand.limon : Brand.beyaz,
                  onTap: () => setState(
                    () => life = life.copyWith(
                      interests: _toggle(life.interests, a),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(a.icon, color: a.color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: BrandText.label(color: a.color, size: 13),
                            ),
                            Text(a.keywords, style: BrandText.body(size: 13)),
                          ],
                        ),
                      ),
                      if (life.interests.contains(a))
                        const Icon(Icons.check, color: Brand.kobalt),
                    ],
                  ),
                ),
              ),
          ],
        );
      case 2:
        return _chips<String>(
          timeOptions,
          life.time,
          (s) => s,
          (v) =>
              setState(() => life = life.copyWith(time: _toggle(life.time, v))),
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BÜTÇE', style: BrandText.label()),
            const SizedBox(height: 10),
            SegmentedButton<Budget>(
              segments: const [
                ButtonSegment(value: Budget.free, label: Text('Ücretsiz')),
                ButtonSegment(value: Budget.economic, label: Text('Ekonomik')),
                ButtonSegment(value: Budget.flexible, label: Text('Esnek')),
              ],
              selected: {life.budget},
              onSelectionChanged: (s) =>
                  setState(() => life = life.copyWith(budget: s.first)),
            ),
            const SizedBox(height: 24),
            Text('GENELLİKLE', style: BrandText.label()),
            const SizedBox(height: 10),
            SegmentedButton<Company>(
              segments: const [
                ButtonSegment(value: Company.alone, label: Text('Yalnız')),
                ButtonSegment(value: Company.withChild, label: Text('Çocukla')),
                ButtonSegment(value: Company.any, label: Text('İkisi de')),
              ],
              selected: {life.company},
              onSelectionChanged: (s) =>
                  setState(() => life = life.copyWith(company: s.first)),
            ),
            const SizedBox(height: 24),
            Text('ŞEHİR', style: BrandText.label()),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: life.city,
              items: const [
                'İstanbul',
                'Ankara',
                'İzmir',
                'Bursa',
                'Antalya',
                'Diğer',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => life = life.copyWith(city: v)),
            ),
          ],
        );
      default:
        return _chips<String>(goalOptions, life.weeklyGoals.toSet(), (s) => s, (
          v,
        ) {
          final goals = life.weeklyGoals.toList();
          if (goals.contains(v)) {
            goals.remove(v);
          } else if (goals.length < 3) {
            goals.add(v);
          }
          setState(() => life = life.copyWith(weeklyGoals: goals));
        });
    }
  }
}
