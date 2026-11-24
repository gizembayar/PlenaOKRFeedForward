import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../widgets/brand.dart';
import '../shell/app_shell.dart';

/// "Kendim" — nefes, mindfulness, eğitimler, spor ve beslenme.
class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    Iterable<ContentItem> where(bool Function(ContentItem) f) =>
        catalog.where(f);

    final sections = <(String, Iterable<ContentItem>)>[
      ('Nefes', where((c) => c.kind == ContentKind.breath)),
      (
        'Mindfulness',
        where((c) => c.area == CoolArea.mind && c.kind != ContentKind.breath),
      ),
      (
        'Eğitimler',
        where(
          (c) =>
              (c.kind == ContentKind.video ||
                  c.kind == ContentKind.pdf ||
                  c.kind == ContentKind.audio) &&
              c.area != CoolArea.sport &&
              c.area != CoolArea.mind,
        ),
      ),
      (
        'COOL SPORT · Hareket',
        where(
          (c) =>
              c.area == CoolArea.sport &&
              c.kind != ContentKind.recipe &&
              c.kind != ContentKind.event,
        ),
      ),
      ('Beslenme', where((c) => c.kind == ContentKind.recipe)),
    ];

    return DefaultTabController(
      length: sections.length,
      child: AppPage(
        title: 'KENDİM',
        subtitle: 'Nefes, öğrenme ve kişisel gelişim. Kendi hızında.',
        children: [
          const SizedBox(height: 12),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: Brand.kobalt,
            indicatorColor: Brand.mercan,
            labelStyle: BrandText.label(size: 13),
            dividerColor: Brand.cizgi,
            tabs: [for (final (t, _) in sections) Tab(text: t.trUpper)],
          ),
          Builder(
            builder: (context) {
              final controller = DefaultTabController.of(context);
              return AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final (title, items) = sections[controller.index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      for (final i in items) ContentTile(i),
                      if (title.startsWith('COOL SPORT') || title == 'Beslenme')
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(14),
                          color: Brand.limon,
                          child: Text(
                            'Sağlık durumunu değerlendiren ya da tıbbi egzersiz/diyet reçetesi veren bir '
                            'sistem değildir; gerektiğinde uzman görüşü al.',
                            style: BrandText.body(size: 12),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
