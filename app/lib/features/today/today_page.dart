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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.session;
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

    return AppPage(
      title: Brand.name,
      subtitle:
          '${_greeting()}${name.isEmpty ? '' : ', $name'}. Bugün kendin için ne var?',
      children: [
        const SectionLabel('Bugün kendin için'),
        CoolCard(
          color: Brand.kobaltSoft,
          border: false,
          onTap: () => context.push('/app/icerik/${breath.id}'),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Brand.limon,
                  shape: BoxShape.circle,
                ),
                child: Text('8', style: BrandText.logo(size: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(breath.title, style: BrandText.heading(size: 17)),
                    Text(breath.subtitle, style: BrandText.body(size: 13)),
                  ],
                ),
              ),
              Icon(
                s.isDone(breath.id)
                    ? Icons.check_circle
                    : Icons.play_circle_fill,
                color: Brand.kobalt,
                size: 36,
              ),
            ],
          ),
        ),
        SectionLabel(
          'Bu hafta senin için',
          trailing: TextButton(
            onPressed: () => context.go('/app/kesfet'),
            child: const Text('Tümü'),
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
          CoolCard(
            color: Brand.beyaz,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final g in goals)
                  CheckboxListTile(
                    value: g.startsWith('✓'),
                    onChanged: (_) => s.toggleGoal(g.replaceFirst('✓', '')),
                    title: Text(
                      g.replaceFirst('✓', ''),
                      style: BrandText.body().copyWith(
                        decoration: g.startsWith('✓')
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Brand.kobalt,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        if (s.tier == Tier.free)
          CoolCard(
            color: Brand.limon,
            border: false,
            onTap: () => context.push('/app/uyelik'),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yeni bir sen, tam erişimle.',
                        style: BrandText.heading(size: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Eğitimler, buluşmalar, kariyer eşleşmeleri ve beraber tatiller.',
                        style: BrandText.body(size: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Brand.kobalt),
              ],
            ),
          ),
      ],
    );
  }
}
