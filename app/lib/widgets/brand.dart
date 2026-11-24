import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';
import '../data/models.dart';
import '../services/session.dart';

/// Logo: Inter Display Black, sıkı harf aralığı.
class Wordmark extends StatelessWidget {
  const Wordmark({
    super.key,
    this.size = 20,
    this.color = Brand.kobalt,
    this.twoLines = false,
  });

  final double size;
  final Color color;
  final bool twoLines;

  @override
  Widget build(BuildContext context) => Text(
    twoLines ? 'NOT DUL,\nBUT COOL.' : Brand.name,
    style: BrandText.logo(size: size, color: color),
    semanticsLabel: 'Not dul, but cool.',
  );
}

/// Sarı vurgu bandı: "Hayatımda koca bir değişiklik var."
class HighlightBar extends StatelessWidget {
  const HighlightBar(
    this.text, {
    super.key,
    this.size = 16,
    this.color = Brand.limon,
  });
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    padding: EdgeInsets.symmetric(horizontal: size, vertical: size * 0.6),
    child: Text(
      text,
      style: BrandText.heading(
        size: size,
        color: Brand.siyah,
      ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
    ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(text.trUpper, style: BrandText.label())),
        ?trailing,
      ],
    ),
  );
}

class CoolCard extends StatelessWidget {
  const CoolCard({
    super.key,
    required this.child,
    this.color = Brand.kartZemin,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.border = true,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool border;

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: border ? const BorderSide(color: Brand.cizgi) : BorderSide.none,
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// Instagram görsel dili: üstte küçük logo + çizgi, ortada büyük başlık,
/// altta "THE GOOD LIFE."
class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
    required this.accent,
    this.footer = 'THE GOOD LIFE.',
    this.onTap,
  });

  final String text;
  final Color background;
  final Color foreground;
  final Color accent;
  final String footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 0.75,
    child: Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Brand.name,
                style: BrandText.label(color: foreground, size: 9),
              ),
              const SizedBox(height: 6),
              Container(width: 28, height: 3, color: accent),
              const Spacer(),
              Text(text, style: BrandText.logo(size: 22, color: foreground)),
              const Spacer(flex: 2),
              Text(footer, style: BrandText.label(color: foreground, size: 9)),
            ],
          ),
        ),
      ),
    ),
  );
}

class TierBadge extends StatelessWidget {
  const TierBadge(this.tier, {super.key, this.small = false});
  final Tier tier;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: small ? 8 : 12,
      vertical: small ? 3 : 6,
    ),
    decoration: BoxDecoration(
      color: tier.color,
      borderRadius: BorderRadius.circular(99),
      border: tier == Tier.free ? Border.all(color: Brand.kobalt) : null,
    ),
    child: Text(
      tier.name,
      style: BrandText.label(color: tier.onColor, size: small ? 10 : 12),
    ),
  );
}

/// İçerik satırı: renkli kare + başlık + meta.
class ContentTile extends StatelessWidget {
  const ContentTile(this.item, {super.key, this.showArea = false});
  final ContentItem item;
  final bool showArea;

  static Color swatch(ContentItem i) => switch (i.area.index % 3) {
    0 => Brand.limon,
    1 => Brand.mercanSoft,
    _ => Brand.kobaltSoft,
  };

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final locked = !s.canAccess(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CoolCard(
        color: Brand.beyaz,
        padding: const EdgeInsets.all(12),
        onTap: () => context.push('/app/icerik/${item.id}'),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: swatch(item),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.kind.icon, color: Brand.kobalt),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: BrandText.body(size: 15)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showArea
                        ? '${item.area.title} • ${item.meta}'
                        : item.subtitle,
                    style: BrandText.body(size: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (locked)
              TierBadge(
                item.requiredTier == Tier.icon ? Tier.icon : Tier.cool,
                small: true,
              )
            else if (s.isDone(item.id))
              const Icon(Icons.check_circle, color: Brand.kobalt)
            else
              const Icon(Icons.chevron_right, color: Brand.kobalt),
          ],
        ),
      ),
    );
  }
}

/// Geniş ekranlarda içeriği ortalar.
class MaxWidth extends StatelessWidget {
  const MaxWidth({
    super.key,
    required this.child,
    this.width = 1120,
    this.padding,
  });
  final Widget child;
  final double width;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}

class Bullet extends StatelessWidget {
  const Bullet(
    this.text, {
    super.key,
    this.color = Brand.mercan,
    this.textColor = Brand.siyah,
  });
  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 9, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: BrandText.body(size: 14, color: textColor)),
        ),
      ],
    ),
  );
}
