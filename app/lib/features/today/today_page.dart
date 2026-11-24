import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';
import '../shell/app_shell.dart';

/// Mobil ana sayfa — "Bugün".
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  static const _days = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  static const _months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Günün notu — markanın muzip, kendine şefkatli sesi.
  static const _notes = [
    'Medeni halim bekâr. Programım dolu.',
    'Kendimle randevum var. Ertelemiyorum.',
    'Bugün mükemmel olmak zorunda değil. Sadece benim olsun.',
    'Hayatımın yeni sezonu: başrolde ben.',
    'Yalnız değilim; kendimle birlikteyim.',
    'Küçük bir adım da adımdır. Özellikle topukluyla.',
    'Bu defa kendim için.',
  ];

  String _greeting(DateTime now) {
    final h = now.hour;
    if (h < 11) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final now = DateTime.now();
    final name = s.user?.greetingName ?? '';
    final breath = findContent('nefes-8')!;
    final picks = s.recommendations(
      kinds: {
        ContentKind.event,
        ContentKind.video,
        ContentKind.trip,
        ContentKind.recipe,
      },
      limit: 2,
    );
    final goals = s.life.weeklyGoals;
    final doneGoals = goals.where((g) => g.startsWith('✓')).length;
    final note =
        _notes[now.difference(DateTime(now.year)).inDays % _notes.length];

    return AppPage(
      eyebrow:
          '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}',
      title: '${_greeting(now)}${name.isEmpty ? '' : ',\n$name'}.',
      subtitle: 'Bugün kendin için ne var?',
      children: [
        const SizedBox(height: 24),
        _NoteCard(note),
        const SectionLabel('Bugün kendin için'),
        _BreathCard(item: breath, done: s.isDone(breath.id)),
        SectionLabel(
          'Bu hafta senin için',
          trailing: TextButton(
            onPressed: () => context.go('/app/kesfet'),
            child: Text('Tümünü gör', style: BrandText.label(size: 14)),
          ),
        ),
        for (final p in picks) ContentTile(p),
        const SectionLabel('Kendi hayatıma doğru'),
        if (goals.isEmpty)
          CoolCard(
            onTap: () => context.push('/app/hayatim'),
            child: Text(
              'Bu hafta için küçük bir hedef seç →',
              style: BrandText.body(),
            ),
          )
        else
          _GoalsCard(goals: goals, done: doneGoals, onToggle: s.toggleGoal),
        const SizedBox(height: 28),
        if (s.tier == Tier.free) const _UpgradeCard(),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(this.note);
  final String note;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
    decoration: BoxDecoration(
      color: Brand.beyaz,
      borderRadius: BorderRadius.circular(22),
      boxShadow: Brand.golge,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('GÜNÜN NOTU', style: BrandText.label(color: Brand.mercan)),
            const SizedBox(width: 10),
            Container(width: 24, height: 3, color: Brand.limon),
          ],
        ),
        const SizedBox(height: 12),
        Text(note, style: BrandText.logo(size: 26)),
      ],
    ),
  );
}

class _BreathCard extends StatelessWidget {
  const _BreathCard({required this.item, required this.done});
  final ContentItem item;
  final bool done;

  @override
  Widget build(BuildContext context) => Material(
    color: Brand.kobalt,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/app/icerik/${item.id}'),
      child: Stack(
        children: [
          const Positioned(
            right: -30,
            bottom: -40,
            child: Dot(130, Color(0x33F3DB65)),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Brand.limon,
                    shape: BoxShape.circle,
                  ),
                  child: Text('8', style: BrandText.logo(size: 36)),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: BrandText.heading(size: 20, color: Brand.krem),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        done ? 'Bugün yaptın. Harikasın.' : item.subtitle,
                        style: BrandText.body(size: 15, color: Brand.krem),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Brand.krem,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.play_arrow_rounded,
                    color: Brand.kobalt,
                    size: 30,
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

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({
    required this.goals,
    required this.done,
    required this.onToggle,
  });
  final List<String> goals;
  final int done;
  final Future<void> Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final progress = goals.isEmpty ? 0.0 : done / goals.length;
    return Container(
      decoration: BoxDecoration(
        color: Brand.beyaz,
        borderRadius: BorderRadius.circular(22),
        boxShadow: Brand.golge,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        color: Brand.mercan,
                        backgroundColor: Brand.mercanSoft,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$done/${goals.length}',
                      style: BrandText.heading(size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  done == goals.length
                      ? 'Bu haftanın hedefleri tamam. Kutlama zamanı!'
                      : done == 0
                      ? 'Haftanın küçük hedefleri seni bekliyor.'
                      : 'Yolun yarısı geride. Devam!',
                  style: BrandText.heading(size: 17, color: Brand.siyah),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final g in goals)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: g.startsWith('✓'),
              onChanged: (_) => onToggle(g.replaceFirst('✓', '')),
              title: Text(
                g.replaceFirst('✓', ''),
                style:
                    BrandText.body(
                      color: g.startsWith('✓') ? Brand.metin2 : Brand.siyah,
                    ).copyWith(
                      decoration: g.startsWith('✓')
                          ? TextDecoration.lineThrough
                          : null,
                    ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Brand.kobalt,
              shape: const CircleBorder(),
              checkboxShape: const CircleBorder(),
            ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) => Material(
    color: Brand.limon,
    borderRadius: BorderRadius.circular(24),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/app/uyelik'),
      child: Stack(
        children: [
          const Positioned(right: -24, top: -24, child: Dot(96, Brand.mercan)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YENİ BİR SEN', style: BrandText.label()),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: Text(
                    'Tam erişimle, kendi hızında.',
                    style: BrandText.logo(size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Eğitimler, buluşmalar, kariyer eşleşmeleri ve beraber tatiller.',
                  style: BrandText.body(size: 15),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Planları gör', style: BrandText.label(size: 15)),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      color: Brand.kobalt,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
