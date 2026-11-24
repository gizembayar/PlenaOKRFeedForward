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
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: Brand.golge,
        ),
        child: CoolCard(
          color: Brand.beyaz,
          border: false,
          padding: const EdgeInsets.all(14),
          onTap: () => context.push('/app/icerik/${item.id}'),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: swatch(item),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Brand.beyaz.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        item.kind.icon,
                        color: Brand.kobalt,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: BrandText.heading(
                        size: 17,
                        color: Brand.siyah,
                      ).copyWith(letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showArea
                          ? '${item.area.title} • ${item.meta}'
                          : item.subtitle,
                      style: BrandText.body(size: 14, color: Brand.metin2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (locked)
                TierBadge(
                  item.requiredTier == Tier.icon ? Tier.icon : Tier.cool,
                  small: true,
                )
              else if (s.isDone(item.id))
                const Icon(Icons.check_circle, color: Brand.kobalt, size: 28)
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Brand.krem,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Brand.kobalt,
                    size: 20,
                  ),
                ),
            ],
          ),
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

/// Kayan slogan şeridi — markanın muzip sesi.
class SloganMarquee extends StatefulWidget {
  const SloganMarquee({
    super.key,
    required this.items,
    this.background = Brand.limon,
    this.foreground = Brand.kobalt,
  });
  final List<String> items;
  final Color background;
  final Color foreground;

  @override
  State<SloganMarquee> createState() => _SloganMarqueeState();
}

class _SloganMarqueeState extends State<SloganMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in widget.items) ...[
          Text(t, style: BrandText.logo(size: 26, color: widget.foreground)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Icon(Icons.circle, size: 10, color: widget.foreground),
          ),
        ],
      ],
    );
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Container(
      color: widget.background,
      height: 68,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, c) => OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: reduceMotion
                ? row
                : AnimatedBuilder(
                    animation: _c,
                    builder: (context, child) => FractionalTranslation(
                      translation: Offset(-_c.value / 2, 0),
                      child: child,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [row, row],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Dekoratif daire (kapak sayfasındaki limon ve mercan daireler).
class Dot extends StatelessWidget {
  const Dot(this.size, this.color, {super.key});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Eğik "etiket" — muzip vurgu.
class Sticker extends StatelessWidget {
  const Sticker(
    this.text, {
    super.key,
    this.color = Brand.mercan,
    this.textColor = Brand.beyaz,
    this.angle = -0.06,
  });
  final String text;
  final Color color;
  final Color textColor;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: Brand.golge,
      ),
      child: Text(text, style: BrandText.label(color: textColor, size: 13)),
    ),
  );
}
