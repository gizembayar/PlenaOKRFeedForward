import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';
import '../shell/app_shell.dart';

/// "Keşfet" — 500 etkinlik arasında kaybolmak yerine kişiye uygun 3 seçenek.
/// Ayrıca buluşmalar & networking, kariyer eşleşmeleri ve beraber tatiller.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

enum _Tab {
  forYou('Senin için'),
  social('Buluşmalar & Network'),
  career('Kariyer eşleşmeleri'),
  trips('Beraber tatil');

  const _Tab(this.label);
  final String label;
}

class _DiscoverPageState extends State<DiscoverPage> {
  _Tab tab = _Tab.forYou;
  Budget? budget;
  Company? company;
  CoolArea? area;

  @override
  Widget build(BuildContext context) {
    final s = context.session;

    return AppPage(
      title: 'KEŞFET',
      subtitle: 'Bu hafta senin için seçtiklerimiz',
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in _Tab.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.label),
                    selected: tab == t,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => tab = t),
                  ),
                ),
            ],
          ),
        ),
        ...switch (tab) {
          _Tab.forYou => _forYou(s),
          _Tab.social => _list(
            'Küçük gruplar, moderatörlü buluşmalar',
            catalog.where((c) => c.area == CoolArea.social),
            note: 'Güvenli buluşma ilkeleri: halka açık mekân, moderatör, ilk buluşmada kişisel adres paylaşımı yok.',
          ),
          _Tab.career => _list(
            'Hedeflerine göre eşleşen mentorlar ve fırsatlar',
            catalog.where((c) => c.area == CoolArea.future),
          ),
          _Tab.trips => _list(
            'Kadın kadına ve anne-çocuk seyahatleri',
            catalog.where((c) => c.kind == ContentKind.trip),
            note: 'Seyahatler lisanslı acentelerle düzenlenir; fiyatlar ayrıca bildirilir.',
          ),
        },
      ],
    );
  }

  List<Widget> _forYou(Session s) {
    final picks = s.recommendations(
      limit: 3,
      budget: budget,
      company: company,
      area: area,
      kinds: {
        ContentKind.event,
        ContentKind.trip,
        ContentKind.video,
        ContentKind.program,
      },
    );
    return [
      const SectionLabel('Filtreler'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _menu<Budget>(
            label: budget == null ? 'Bütçe' : _budgetLabel(budget!),
            values: Budget.values,
            text: _budgetLabel,
            onSelected: (v) => setState(() => budget = v),
          ),
          _menu<Company>(
            label: company == null
                ? 'Çocukla / yalnız'
                : _companyLabel(company!),
            values: Company.values,
            text: _companyLabel,
            onSelected: (v) => setState(() => company = v),
          ),
          _menu<CoolArea>(
            label: area?.title ?? 'İlgi alanı',
            values: CoolArea.values,
            text: (a) => a.title,
            onSelected: (v) => setState(() => area = v),
          ),
          if (budget != null || company != null || area != null)
            ActionChip(
              label: const Text('Temizle'),
              onPressed: () => setState(() {
                budget = null;
                company = null;
                area = null;
              }),
            ),
        ],
      ),
      const SectionLabel('3 öneri'),
      if (picks.isEmpty)
        Text(
          'Bu filtrelerle öneri yok. Biraz esnetelim mi?',
          style: BrandText.body(),
        )
      else
        for (final p in picks) _RecommendationCard(p),
    ];
  }

  Widget _menu<T>({
    required String label,
    required List<T> values,
    required String Function(T) text,
    required ValueChanged<T?> onSelected,
  }) => PopupMenuButton<T>(
    onSelected: onSelected,
    itemBuilder: (_) => [
      for (final v in values) PopupMenuItem(value: v, child: Text(text(v))),
    ],
    child: Chip(
      label: Text(label),
      avatar: const Icon(Icons.expand_more, size: 18, color: Brand.kobalt),
    ),
  );

  static String _budgetLabel(Budget b) => switch (b) {
    Budget.free => 'Ücretsiz',
    Budget.economic => 'Ekonomik',
    Budget.flexible => 'Esnek',
  };

  static String _companyLabel(Company c) => switch (c) {
    Company.alone => 'Yalnız',
    Company.withChild => 'Çocukla',
    Company.any => 'Fark etmez',
  };

  List<Widget> _list(
    String label,
    Iterable<ContentItem> items, {
    String? note,
  }) => [
    SectionLabel(label),
    for (final i in items) ContentTile(i, showArea: true),
    if (note != null)
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        color: Brand.limonSoft,
        child: Text(note, style: BrandText.body(size: 13)),
      ),
  ];
}

/// Öneri kartı: Ne? Nerede? Ne zaman? Maliyet? Neden sana uygun?
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard(this.item);
  final ContentItem item;

  String _why(Session s) {
    final reasons = <String>[
      if (s.life.interests.contains(item.area))
        '${item.area.title} ilgi alanında',
      if (item.budget.index <= s.life.budget.index) 'bütçene uygun',
      if (item.company == Company.withChild) 'çocuğunla yapılabilir',
      if (item.minutes != null && item.minutes! <= 30) 'kısa sürüyor',
    ];
    return reasons.isEmpty ? 'Yeni bir şey denemek için' : reasons.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final saved = s.isSaved(item.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentTile(item, showArea: true),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 6),
              decoration: const BoxDecoration(
                color: Brand.kobaltSoft,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (item.where != null) '📍 ${item.where}',
                        'Neden sen: ${_why(s)}',
                      ].join('  ·  '),
                      style: BrandText.body(size: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => s.toggleSaved(item.id),
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_add_outlined,
                      size: 18,
                    ),
                    label: Text(saved ? 'Planımda' : 'Planla'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
