import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';

/// Mobil alt menü: BUGÜN • KEŞFET • KENDİM • PLANIM • PROFİL.
/// Geniş ekranda (web) yan menüye dönüşür.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const destinations = [
    (Icons.wb_sunny_outlined, Icons.wb_sunny, 'Bugün'),
    (Icons.explore_outlined, Icons.explore, 'Keşfet'),
    (Icons.spa_outlined, Icons.spa, 'Kendim'),
    (Icons.event_note_outlined, Icons.event_note, 'Planım'),
    (Icons.person_outline, Icons.person, 'Profil'),
  ];

  void _go(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final (icon, sel, label) in destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(sel, color: Brand.kobalt),
                label: label,
              ),
          ],
        ),
      );
    }
    final tier = context.session.tier;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            extended: MediaQuery.sizeOf(context).width >= 1200,
            minExtendedWidth: 220,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: InkWell(
                onTap: () => context.go('/'),
                child: const Wordmark(size: 16, twoLines: true),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TierBadge(tier, small: true),
                ),
              ),
            ),
            labelType: MediaQuery.sizeOf(context).width >= 1200
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final (icon, sel, label) in destinations)
                NavigationRailDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(sel, color: Brand.kobalt),
                  label: Text(label, style: BrandText.label(size: 13)),
                ),
            ],
          ),
          const VerticalDivider(width: 1, color: Brand.cizgi),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

/// Uygulama içi sayfa iskeleti: kobalt başlık bandı + kaydırılabilir içerik.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.actions,
    this.eyebrow,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Brand.kobalt,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -40,
                  top: -50,
                  child: Dot(170, Brand.limon),
                ),
                const Positioned(
                  right: 70,
                  bottom: -46,
                  child: Dot(92, Brand.mercan),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    MediaQuery.paddingOf(context).top + 28,
                    0,
                    32,
                  ),
                  child: MaxWidth(
                    width: 860,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (eyebrow != null) ...[
                                Text(
                                  eyebrow!.trUpper,
                                  style: BrandText.label(
                                    color: Brand.limon,
                                    size: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                title,
                                style: BrandText.logo(
                                  size: 32,
                                  color: Brand.krem,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(right: 90),
                                  child: Text(
                                    subtitle!,
                                    style: BrandText.body(
                                      color: Brand.krem,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ...?actions,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: MaxWidth(
            width: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [...children, const SizedBox(height: 40)],
            ),
          ),
        ),
      ],
    ),
  );
}
