import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../services/session.dart';
import 'brand.dart';

/// Web sitesinin kamusal yüzü: üst menü + alt bilgi.
class PublicScaffold extends StatelessWidget {
  const PublicScaffold({super.key, required this.children});
  final List<Widget> children;

  static const links = [
    ('Keşfet', '/#kesfet'),
    ('COOL SPORT', '/#sport'),
    ('Eğitimler', '/#egitimler'),
    ('Üyelik', '/uyelik'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 860;
    final s = context.session;
    final cta = FilledButton(
      onPressed: () => context.go(s.signedIn ? '/app/bugun' : '/giris'),
      style: FilledButton.styleFrom(
        backgroundColor: Brand.limon,
        foregroundColor: Brand.kobalt,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
      child: Text(s.signedIn ? 'Benim Alanım' : 'Giriş'),
    );

    return Scaffold(
      endDrawer: wide
          ? null
          : Drawer(
              backgroundColor: Brand.krem,
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Wordmark(size: 22),
                    const SizedBox(height: 24),
                    for (final (label, path) in links)
                      ListTile(
                        title: Text(label, style: BrandText.heading(size: 20)),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(path.split('#').first);
                        },
                      ),
                    const SizedBox(height: 16),
                    cta,
                  ],
                ),
              ),
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 76,
            automaticallyImplyLeading: false,
            backgroundColor: Brand.kobalt,
            foregroundColor: Brand.krem,
            titleSpacing: 0,
            title: MaxWidth(
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.go('/'),
                    child: const Wordmark(size: 22, color: Brand.krem),
                  ),
                  const Spacer(),
                  if (wide) ...[
                    for (final (label, path) in links)
                      TextButton(
                        onPressed: () => context.go(path.split('#').first),
                        style: TextButton.styleFrom(
                          foregroundColor: Brand.krem,
                        ),
                        child: Text(
                          label,
                          style: BrandText.label(color: Brand.krem, size: 14),
                        ),
                      ),
                    const SizedBox(width: 16),
                    cta,
                  ],
                ],
              ),
            ),
            actions: wide
                ? null
                : [
                    Builder(
                      builder: (c) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(c).openEndDrawer(),
                      ),
                    ),
                  ],
          ),
          SliverList.list(children: [...children, const _Footer()]),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 64),
    color: Brand.kobalt,
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: MaxWidth(
      child: Wrap(
        spacing: 48,
        runSpacing: 24,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wordmark(size: 32, color: Brand.krem, twoLines: true),
              const SizedBox(height: 16),
              Text(Brand.slogan, style: BrandText.body(color: Brand.limon)),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              'Bu platform terapi, hukuki ya da yatırım danışmanlığı sunmaz. '
              'Spor ve beslenme içerikleri tıbbi öneri değildir; gerektiğinde uzman görüşü al. '
              'Etkinlik ve seyahatler doğrulanmış iş ortaklarıyla düzenlenir.',
              style: BrandText.body(color: Brand.krem, size: 13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final t in [
                'SSS',
                'İletişim',
                'Satış koşulları',
                'Gizlilik (KVKK)',
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    t,
                    style: BrandText.label(color: Brand.krem, size: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
