import 'models.dart';

/// Başlangıç içerik kataloğu. Canlıya geçerken Supabase `content` tablosundan
/// ya da bir CMS'ten okunacak şekilde [ContentRepository] arkasında durur.
///
/// Not: Etkinlik, fiyat ve tarih örnekleri temsilidir; yayına almadan önce
/// doğrulanmalıdır (Marka prensibi: Dürüstlük).
const catalog = <ContentItem>[
  // ── COOL MIND · Mindfulness & nefes ─────────────────────────────────────
  ContentItem(
    id: 'nefes-8',
    title: 'Kendime ayırdığım 8 dakika',
    subtitle: 'Rehberli nefes çalışması',
    area: CoolArea.mind,
    kind: ContentKind.breath,
    minutes: 8,
    description: 'Güne başlamadan önce 4-4-6 ritminde sakin bir nefes. Telefonu bırak, omuzlarını indir, sadece takip et.',
  ),
  ContentItem(
    id: 'nefes-gece',
    title: 'Uyumadan önce: 4-7-8',
    subtitle: 'Zihni yavaşlatan akşam nefesi',
    area: CoolArea.mind,
    kind: ContentKind.breath,
    minutes: 6,
    requiredTier: Tier.cool,
    description: 'Günün yükünü yatağa taşımamak için kısa bir kapanış ritüeli.',
  ),
  ContentItem(
    id: 'mindful-sinirlar',
    title: 'Sınır çizmek bir beceridir',
    subtitle: '5 bölümlük mindfulness serisi',
    area: CoolArea.mind,
    kind: ContentKind.audio,
    minutes: 35,
    requiredTier: Tier.cool,
    description: 'Hayır demek, alan açmak ve kendini suçlamadan öncelik vermek üzerine sesli bir seri.',
    lessons: [
      'Farkındalık: Neye evet diyorum?',
      'Bedenim ne söylüyor?',
      'Net ve nazik cümleler',
      'Eski ilişki kalıplarını fark etmek',
      'Yeni benim sınırları',
    ],
  ),
  ContentItem(
    id: 'mindful-sabah',
    title: 'Sabah 10 dakika meditasyon',
    subtitle: '21 günlük rutin',
    area: CoolArea.mind,
    kind: ContentKind.program,
    minutes: 10,
    requiredTier: Tier.cool,
    description: 'Her sabah tek bir niyet, tek bir nefes, tek bir küçük adım.',
  ),

  // ── COOL ME · Eğitimler ────────────────────────────────────────────────
  ContentItem(
    id: 'egitim-yeni-sezon',
    title: 'Hayatımın yeni sezonu',
    subtitle: 'Yeni bir ben yaratmak · video eğitim',
    area: CoolArea.me,
    kind: ContentKind.video,
    minutes: 48,
    requiredTier: Tier.cool,
    description: 'Boşanma bir son değil, bir sezon finali. Bu eğitim; kimlik, değerler ve istekler üzerinden kendi senaryonu yeniden yazmana eşlik eder.',
    lessons: [
      'Sezon finali: Neyi geride bırakıyorum?',
      'Değerlerim ve isteklerim',
      'Kendime ait bir gün tasarlamak',
      'Yeni benim ilk 90 günü',
    ],
  ),
  ContentItem(
    id: 'pdf-kendimle-randevu',
    title: 'Kendimle randevum var',
    subtitle: 'PDF çalışma kitapçığı',
    area: CoolArea.me,
    kind: ContentKind.pdf,
    description: '30 günlük kendinle buluşma planı: yazma egzersizleri, mini görevler, kutlamalar.',
  ),
  ContentItem(
    id: 'egitim-stil',
    title: 'Stilim, imzam',
    subtitle: 'Gardırop ve özgüven atölyesi',
    area: CoolArea.me,
    kind: ContentKind.video,
    minutes: 32,
    requiredTier: Tier.cool,
    description: 'Kendini aynada değil hayatta görmek için pratik stil ve öz bakım rehberi.',
  ),

  // ── COOL SPORT · Spor & beslenme ───────────────────────────────────────
  ContentItem(
    id: 'spor-sahil',
    title: 'Sahil yürüyüşü',
    subtitle: 'COOL SPORT • 30 dakika',
    area: CoolArea.sport,
    kind: ContentKind.event,
    minutes: 30,
    when: 'Cumartesi 09:00',
    where: 'Caddebostan sahil',
    description: 'Kadın yürüyüş grubu. Tempo sohbet edebileceğin kadar; sonrası kahve isteğe bağlı.',
  ),
  ContentItem(
    id: 'spor-pilates',
    title: 'Başlangıç pilatesi',
    subtitle: 'Evde 20 dakikalık seri',
    area: CoolArea.sport,
    kind: ContentKind.video,
    minutes: 20,
    requiredTier: Tier.cool,
    description: 'Düşük eşikli ilk adım. Mat ve 20 dakika yeterli.',
  ),
  ContentItem(
    id: 'spor-dans',
    title: 'Mutfakta dans',
    subtitle: '15 dakikalık enerji molası',
    area: CoolArea.sport,
    kind: ContentKind.video,
    minutes: 15,
    description: 'Koreografi yok, kural yok. Sadece müzik ve sen.',
  ),
  ContentItem(
    id: 'spor-4hafta',
    title: '4 haftada kendi ritmim',
    subtitle: 'Kişisel hareket programı',
    area: CoolArea.sport,
    kind: ContentKind.program,
    minutes: 25,
    requiredTier: Tier.cool,
    description: 'Haftada 3 gün; yürüyüş, mobilite ve hafif kuvvet. Sonuç değil, sürdürülebilirlik odaklı.',
  ),
  ContentItem(
    id: 'beslenme-hafta',
    title: 'Kendime iyi bakan bir hafta',
    subtitle: 'Beslenme planı + alışveriş listesi',
    area: CoolArea.sport,
    kind: ContentKind.recipe,
    requiredTier: Tier.cool,
    description: 'Tek kişilik ya da çocukla porsiyonlanabilen, 20 dakikada hazırlanan dengeli tarifler.',
  ),
  ContentItem(
    id: 'beslenme-kahvalti',
    title: '5 enerjik kahvaltı',
    subtitle: 'Hızlı tarifler',
    area: CoolArea.sport,
    kind: ContentKind.recipe,
    description: 'Sabah koşturmacasında bile kendine ayırabileceğin 5 tabak.',
  ),

  // ── COOL SOCIAL · Networking & buluşmalar ──────────────────────────────
  ContentItem(
    id: 'bulusma-kahve',
    title: 'Pazar kahvesi',
    subtitle: '8 kişilik tanışma buluşması',
    area: CoolArea.social,
    kind: ContentKind.event,
    when: 'Pazar 11:00',
    where: 'Moda',
    requiredTier: Tier.cool,
    budget: Budget.economic,
    description:
        'Küçük grup, sıcak sohbet, yeni bir arkadaş. Moderatör eşliğinde.',
  ),
  ContentItem(
    id: 'networking-aksam',
    title: 'Cool Women Network',
    subtitle: 'Aylık networking akşamı',
    area: CoolArea.social,
    kind: ContentKind.event,
    when: 'Ayın son perşembesi 19:30',
    where: 'Karaköy',
    requiredTier: Tier.cool,
    budget: Budget.economic,
    description: 'Farklı sektörlerden kadınlarla kartvizit değil hikâye paylaşılan bir akşam.',
  ),
  ContentItem(
    id: 'icon-salon',
    title: 'The Icon Salon',
    subtitle: 'Premium üyelere özel kapalı akşam yemeği',
    area: CoolArea.social,
    kind: ContentKind.event,
    when: 'Her ay',
    where: 'İstanbul',
    requiredTier: Tier.icon,
    budget: Budget.flexible,
    description:
        '12 kişilik masa, bir konuk ilham verici kadın, uzun bir sohbet.',
  ),

  // ── COOL FUTURE · Kariyer eşleşmeleri ──────────────────────────────────
  ContentItem(
    id: 'kariyer-mentor',
    title: 'Mentor eşleşmesi',
    subtitle: 'Alanında deneyimli bir kadınla 1:1',
    area: CoolArea.future,
    kind: ContentKind.match,
    requiredTier: Tier.icon,
    description: 'Hedeflerine ve sektörüne göre eşleştiğin mentorla ayda bir görüşme. Kariyere dönüş, terfi veya yeni bir alan.',
  ),
  ContentItem(
    id: 'kariyer-is',
    title: 'Kariyer fırsatları',
    subtitle: 'Kadın dostu şirketlerden ilanlar',
    area: CoolArea.future,
    kind: ContentKind.match,
    requiredTier: Tier.icon,
    description: 'Esnek çalışma, yarı zamanlı ve kariyere dönüş programları. Profiline göre eşleşen ilanlar.',
  ),
  ContentItem(
    id: 'kariyer-cv',
    title: 'Kariyere dönüş: CV ve hikâyem',
    subtitle: 'Video eğitim',
    area: CoolArea.future,
    kind: ContentKind.video,
    minutes: 40,
    requiredTier: Tier.cool,
    description:
        'Aradaki yılları bir boşluk değil, bir deneyim olarak anlatmak.',
  ),
  ContentItem(
    id: 'finans-butce',
    title: 'Ekonomik özgürlüğüm',
    subtitle: 'Bütçe ve finansal okuryazarlık',
    area: CoolArea.future,
    kind: ContentKind.pdf,
    requiredTier: Tier.cool,
    description: 'Kendi bütçeni kurmak için temel araçlar. (Yatırım danışmanlığı değildir.)',
  ),

  // ── COOL EXPERIENCE · Deneyimler & beraber tatil ───────────────────────
  ContentItem(
    id: 'deneyim-seramik',
    title: 'Seramik atölyesi',
    subtitle: 'Yeni bir deneyim',
    area: CoolArea.experience,
    kind: ContentKind.event,
    when: 'Cumartesi 14:00',
    where: 'Kadıköy',
    budget: Budget.economic,
    company: Company.alone,
    description: 'Ellerin çamura değsin, kafan boşalsın. Başlangıç seviyesi.',
  ),
  ContentItem(
    id: 'tatil-ege',
    title: 'Ege\'de 4 gün: Yavaş Hafta',
    subtitle: 'Kadın kadına beraber tatil',
    area: CoolArea.experience,
    kind: ContentKind.trip,
    when: 'Mayıs',
    where: 'Bozcaada',
    requiredTier: Tier.cool,
    budget: Budget.flexible,
    priceNote:
        'Lisanslı acente ile; premium üyelere öncelikli kayıt ve indirim.',
    description: 'Yoga sabahları, bağ evinde akşam yemekleri ve hiç acele etmeyen bir program.',
  ),
  ContentItem(
    id: 'tatil-kapadokya',
    title: 'Kapadokya: Anne-çocuk macerası',
    subtitle: 'Beraber tatil',
    area: CoolArea.experience,
    kind: ContentKind.trip,
    when: 'Yarıyıl tatili',
    where: 'Kapadokya',
    requiredTier: Tier.cool,
    budget: Budget.flexible,
    company: Company.withChild,
    priceNote: 'Lisanslı acente ile.',
    description: 'Balon izlemek, at turu ve diğer annelerle yeni dostluklar.',
  ),

  // ── COOL MOM ───────────────────────────────────────────────────────────
  ContentItem(
    id: 'mom-sergi',
    title: 'Anne-çocuk sergisi',
    subtitle: 'Aile • Pazar',
    area: CoolArea.mom,
    kind: ContentKind.event,
    when: 'Pazar 12:00',
    where: 'Beyoğlu',
    company: Company.withChild,
    description:
        'Birlikte değerlendirilen, ergenlerin de sıkılmadığı bir sanat rotası.',
  ),
  ContentItem(
    id: 'mom-ergen',
    title: 'Ergenimle yeni ritmimiz',
    subtitle: 'Sesli seri',
    area: CoolArea.mom,
    kind: ContentKind.audio,
    minutes: 25,
    requiredTier: Tier.cool,
    company: Company.withChild,
    description: 'İki evli hayat, yeni rutinler ve birlikte keyifli zaman.',
  ),
];

ContentItem? findContent(String id) {
  for (final c in catalog) {
    if (c.id == id) return c;
  }
  return null;
}

/// Üyelik karşılaştırma tablosu (fiyatlandırma sayfası).
const tierFeatures = <Tier, List<String>>{
  Tier.free: [
    '“Benim Hayatım” kişisel yaşam haritası',
    'Bugün ekranı ve haftalık 3 öneri',
    'Haftada 1 rehberli nefes',
    'Ücretsiz yürüyüş ve şehir etkinlikleri',
    'Yaşam rehberi yazıları',
  ],
  Tier.cool: [
    'Keşif’teki her şey',
    'Tüm video eğitimler ve PDF kitapçıklar',
    'Mindfulness & nefes kütüphanesi',
    'Spor programları ve haftalık beslenme planları',
    'Buluşmalar ve Cool Women Network akşamları',
    'Beraber tatillere erişim',
  ],
  Tier.icon: [
    'COOL’daki her şey',
    'Kariyer eşleşmeleri: 1:1 mentor + fırsatlar',
    'The Icon Salon kapalı buluşmaları',
    'Beraber tatillerde öncelik ve indirim',
    'Ayda 1 birebir “Yeni Ben” yol haritası seansı',
    'Yeni içeriklere erken erişim',
  ],
};
