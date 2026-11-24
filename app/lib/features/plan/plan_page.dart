import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';
import '../shell/app_shell.dart';

/// "Planım" — kaydedilenler, haftalık hedefler, küçük kutlamalar.
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final saved = s.saved.map(findContent).nonNulls.toList();
    final goals = s.life.weeklyGoals;
    final doneGoals = goals.where((g) => g.startsWith('✓')).length;

    return AppPage(
      title: 'PLANIM',
      subtitle: 'Sabit değil; enerjine, bütçene ve haftana göre değişir.',
      actions: [
        IconButton(
          tooltip: 'Benim Hayatım’ı düzenle',
          onPressed: () => context.push('/app/hayatim'),
          icon: const Icon(Icons.tune, color: Brand.krem),
        ),
      ],
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            _Stat(
              value: '${s.done.length}',
              label: 'tamamlanan',
              color: Brand.limon,
            ),
            const SizedBox(width: 12),
            _Stat(
              value: '$doneGoals/${goals.length}',
              label: 'haftalık hedef',
              color: Brand.kobaltSoft,
            ),
            const SizedBox(width: 12),
            _Stat(
              value: '${saved.length}',
              label: 'planımda',
              color: Brand.mercanSoft,
            ),
          ],
        ),
        const SectionLabel('Bu haftanın hedefleri'),
        if (goals.isEmpty)
          Text('Henüz hedef yok.', style: BrandText.body())
        else
          for (final g in goals)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: g.startsWith('✓'),
              onChanged: (_) => s.toggleGoal(g.replaceFirst('✓', '')),
              title: Text(g.replaceFirst('✓', ''), style: BrandText.body()),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Brand.kobalt,
            ),
        const SectionLabel('Kaydettiklerim'),
        if (saved.isEmpty)
          CoolCard(
            onTap: () => context.go('/app/kesfet'),
            child: Text(
              'Keşfet’te beğendiğin bir deneyimi “Planla” ile buraya ekle.',
              style: BrandText.body(),
            ),
          )
        else
          for (final i in saved) ContentTile(i, showArea: true),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: BrandText.logo(size: 30)),
          Text(label, style: BrandText.body(size: 12)),
        ],
      ),
    ),
  );
}
