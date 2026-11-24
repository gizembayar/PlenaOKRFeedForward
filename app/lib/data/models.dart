import 'package:material_ui/material_ui.dart';

import '../core/theme.dart';

/// Üyelik tipleri. Sıralama önemlidir: daha yüksek index = daha geniş erişim.
enum Tier {
  free(
    id: 'free',
    name: 'KEŞİF',
    tagline: 'Merak ettim, bakıyorum.',
    monthlyPrice: 0,
    yearlyPrice: 0,
    color: Brand.beyaz,
    onColor: Brand.kobalt,
  ),
  cool(
    id: 'cool',
    name: 'COOL',
    tagline: 'Yeni sezonum başladı.',
    monthlyPrice: 349,
    yearlyPrice: 3490,
    color: Brand.limon,
    onColor: Brand.kobalt,
  ),
  icon(
    id: 'icon',
    name: 'PREMIUM · THE ICON',
    tagline: 'Yeni bir ben yaratıyorum.',
    monthlyPrice: 899,
    yearlyPrice: 8990,
    color: Brand.kobalt,
    onColor: Brand.krem,
  );

  const Tier({
    required this.id,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.color,
    required this.onColor,
  });

  final String id;
  final String name;
  final String tagline;

  /// TL cinsinden vitrin fiyatı. Gerçek tahsilat Stripe Price nesnesinden yapılır.
  final int monthlyPrice;
  final int yearlyPrice;
  final Color color;
  final Color onColor;

  bool includes(Tier other) => index >= other.index;

  static Tier fromId(String? id) =>
      Tier.values.firstWhere((t) => t.id == id, orElse: () => Tier.free);
}

enum BillingPeriod { monthly, yearly }

/// Yedi COOL alanı — yaşamın bütün renkleri.
enum CoolArea {
  me(
    'COOL ME',
    'Kendim ve stilim',
    'Kimlik • öz bakım • özgüven',
    Icons.auto_awesome,
  ),
  mind(
    'COOL MIND',
    'Zihnim ve iyi oluş',
    'Nefes • meditasyon • farkındalık • sınırlar',
    Icons.spa_outlined,
  ),
  social(
    'COOL SOCIAL',
    'Sosyal çevrem',
    'Arkadaşlık • networking • buluşmalar',
    Icons.diversity_3_outlined,
  ),
  experience(
    'COOL EXPERIENCE',
    'Yeni deneyimler',
    'Hobi • kültür-sanat • şehir keşfi • seyahat',
    Icons.explore_outlined,
  ),
  mom(
    'COOL MOM',
    'Anne ve çocuk',
    'Birlikte aktiviteler • ergen deneyimleri',
    Icons.family_restroom_outlined,
  ),
  sport(
    'COOL SPORT',
    'Hareket, enerji ve beslenme',
    'Yürüyüş • pilates • yoga • dans • beslenme',
    Icons.directions_run,
  ),
  future(
    'COOL FUTURE',
    'Geleceğim',
    'Kariyer • finans • yaşam becerileri • hedefler',
    Icons.trending_up,
  );

  const CoolArea(this.title, this.subtitle, this.keywords, this.icon);
  final String title;
  final String subtitle;
  final String keywords;
  final IconData icon;

  Color get color => index.isEven ? Brand.kobalt : Brand.mercan;
}

enum ContentKind {
  video('Video eğitim', Icons.play_circle_outline),
  audio('Sesli içerik', Icons.headphones_outlined),
  breath('Nefes', Icons.air),
  pdf('PDF kitapçık', Icons.menu_book_outlined),
  program('Program', Icons.calendar_view_week_outlined),
  event('Buluşma', Icons.event_outlined),
  trip('Beraber tatil', Icons.luggage_outlined),
  match('Eşleşme', Icons.handshake_outlined),
  recipe('Beslenme', Icons.restaurant_outlined);

  const ContentKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum Budget { free, economic, flexible }

enum Company { alone, withChild, any }

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.area,
    required this.kind,
    required this.description,
    this.minutes,
    this.requiredTier = Tier.free,
    this.when,
    this.where,
    this.budget = Budget.free,
    this.company = Company.any,
    this.lessons = const [],
    this.priceNote,
  });

  final String id;
  final String title;
  final String subtitle;
  final CoolArea area;
  final ContentKind kind;
  final String description;
  final int? minutes;
  final Tier requiredTier;
  final String? when;
  final String? where;
  final Budget budget;
  final Company company;
  final List<String> lessons;

  /// Buluşma / tatil gibi ayrıca ücretlendirilen deneyimler için not.
  final String? priceNote;

  String get meta {
    final parts = <String>[
      kind.label,
      if (minutes != null) '$minutes dk',
      ?when,
    ];
    return parts.join(' • ');
  }
}

/// "Benim Hayatım" — ilk açılışta oluşan kişisel yaşam haritası.
class LifeProfile {
  const LifeProfile({
    this.wishes = const {},
    this.interests = const {},
    this.time = const {},
    this.budget = Budget.economic,
    this.company = Company.any,
    this.city = 'İstanbul',
    this.weeklyGoals = const [],
  });

  final Set<String> wishes;
  final Set<CoolArea> interests;
  final Set<String> time;
  final Budget budget;
  final Company company;
  final String city;
  final List<String> weeklyGoals;

  bool get isEmpty => interests.isEmpty;

  LifeProfile copyWith({
    Set<String>? wishes,
    Set<CoolArea>? interests,
    Set<String>? time,
    Budget? budget,
    Company? company,
    String? city,
    List<String>? weeklyGoals,
  }) => LifeProfile(
    wishes: wishes ?? this.wishes,
    interests: interests ?? this.interests,
    time: time ?? this.time,
    budget: budget ?? this.budget,
    company: company ?? this.company,
    city: city ?? this.city,
    weeklyGoals: weeklyGoals ?? this.weeklyGoals,
  );

  Map<String, dynamic> toJson() => {
    'wishes': wishes.toList(),
    'interests': interests.map((e) => e.name).toList(),
    'time': time.toList(),
    'budget': budget.name,
    'company': company.name,
    'city': city,
    'weekly_goals': weeklyGoals,
  };

  factory LifeProfile.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const LifeProfile();
    List<String> strs(String k) => (j[k] as List?)?.cast<String>() ?? const [];
    return LifeProfile(
      wishes: strs('wishes').toSet(),
      interests: strs('interests')
          .map((n) => CoolArea.values.where((a) => a.name == n))
          .expand((e) => e)
          .toSet(),
      time: strs('time').toSet(),
      budget: Budget.values.firstWhere(
        (b) => b.name == j['budget'],
        orElse: () => Budget.economic,
      ),
      company: Company.values.firstWhere(
        (c) => c.name == j['company'],
        orElse: () => Company.any,
      ),
      city: (j['city'] as String?) ?? 'İstanbul',
      weeklyGoals: strs('weekly_goals'),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.tier = Tier.free,
  });

  final String id;
  final String email;
  final String? displayName;
  final Tier tier;

  String get greetingName => (displayName?.trim().isNotEmpty ?? false)
      ? displayName!.split(' ').first
      : '';

  AppUser copyWith({Tier? tier, String? displayName}) => AppUser(
    id: id,
    email: email,
    displayName: displayName ?? this.displayName,
    tier: tier ?? this.tier,
  );
}
