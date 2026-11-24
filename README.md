# NOT DUL, BUT COOL.

> Hayatımda koca bir değişiklik var.

35–55 yaş arası boşanmış kadınlar için modern bir yaşam platformu. Hedef, boşanmanın ardından hayata tutunmaktan çok daha fazlası: **yeni bir sen**.
Tek bir **Flutter** kod tabanından **web sitesi + iOS + Android** uygulaması çıkar. Giriş/kayıt ve **Stripe** ile üyelik satın alma web sitesinin içindedir.

```
app/        Flutter uygulaması (web, Android, iOS)
supabase/   Veritabanı şeması + Stripe Edge Functions
```

## Ürün haritası

| Web (vitrin + satış)   | Uygulama içi (web'de `/app`, mobilde ana ekran) |
|------------------------|----------------------------------------------|
| `/` Ana sayfa: hero, 7 COOL alanı, içerik tanıtımı, üyelik tablosu | **Bugün**: 8 dk nefes, bu hafta senin için, haftalık hedefler |
| `/uyelik` Planlar + SSS | **Keşfet**: kişiye uygun 3 öneri (bütçe / çocukla-yalnız / ilgi alanı), buluşmalar & networking, kariyer eşleşmeleri, beraber tatil |
| `/giris`, `/kayit`     | **Kendim**: nefes, mindfulness, eğitimler, COOL SPORT, beslenme |
|                        | **Planım**: kaydedilenler, hedefler, ilerleme |
|                        | **Profil**: üyelik, Stripe müşteri portalı, Benim Hayatım, gizlilik |

İlk girişte **“Benim Hayatım”** 5 adımlık onboarding'i açılır: *Neler istiyorum? → Neye ilgim var? → Neye zamanım var? → Bütçem ve koşullarım → Planımı oluştur.* Tam ad, eski eş bilgisi ya da boşanma hikâyesi istenmez.

### Üyelik tipleri

| Plan | Vitrin fiyatı | İçerik |
|------|---------------|--------|
| **KEŞİF** | Ücretsiz | Benim Hayatım, Bugün, haftalık 3 öneri, haftada 1 nefes, ücretsiz etkinlikler |
| **COOL** | ₺349/ay · ₺3.490/yıl | Tüm eğitimler ve PDF'ler, mindfulness & nefes kütüphanesi, spor ve beslenme programları, buluşmalar, networking, beraber tatillere erişim |
| **PREMIUM · THE ICON** | ₺899/ay · ₺8.990/yıl | COOL + kariyer eşleşmeleri (1:1 mentor), The Icon Salon kapalı buluşmaları, tatillerde öncelik/indirim, aylık birebir “Yeni Ben” seansı |

Fiyatlar `app/lib/data/models.dart` → `Tier` içinde vitrin amaçlıdır; gerçek tahsilat Stripe'taki Price nesneleriyle yapılır. Her içerik `requiredTier` alanıyla kilitlenir (`app/lib/data/catalog.dart`).

## Hızlı başlangıç (demo mod)

Backend kurmadan tüm akışları denemek için:

```bash
cd app
flutter pub get
flutter run -d chrome          # web
flutter run                    # bağlı telefon / emülatör
```

`SUPABASE_URL` verilmediğinde uygulama **demo modda** çalışır: herhangi bir e-posta + 8 karakterli şifre ile giriş yapılır, “COOL'a geç” butonu üyeliği anında yükseltir, veriler cihazda tutulur.

## Gerçek ortam: Supabase + Stripe

### 1. Supabase
```bash
supabase link --project-ref <ref>
supabase db push                                   # supabase/migrations
```
- `profiles` tablosu kullanıcı başına bir satır tutar; kayıt olunca trigger ile oluşur.
- RLS açık. İstemci yalnızca `display_name, life_profile, saved_ids, done_ids` sütunlarını güncelleyebilir; **`tier` ve Stripe alanlarını sadece webhook yazar.**
- Auth → URL Configuration: Site URL = `https://notdulbutcool.com`, Redirect URL'lere `https://notdulbutcool.com/**` ekleyin.

### 2. Stripe
1. Ürünler: *COOL* ve *Premium* — her biri için aylık + yıllık **recurring** Price (TRY).
2. Customer Portal'ı etkinleştirin (iptal, plan değişikliği, kart, faturalar).
3. Webhook endpoint: `https://<ref>.functions.supabase.co/stripe-webhook`
   Olaylar: `checkout.session.completed`, `customer.subscription.created|updated|deleted`.

### 3. Edge Functions
```bash
cp supabase/.env.example supabase/.env               # değerleri doldurun, commit etmeyin
supabase secrets set --env-file supabase/.env
supabase functions deploy create-checkout-session
supabase functions deploy create-portal-session
supabase functions deploy stripe-webhook --no-verify-jwt
```

### 4. Uygulamayı backend ile çalıştırma / derleme
```bash
cd app
DEFINES="--dart-define=SUPABASE_URL=https://<ref>.supabase.co \
         --dart-define=SUPABASE_ANON_KEY=<publishable-key> \
         --dart-define=SITE_URL=https://notdulbutcool.com"

flutter run -d chrome $DEFINES
flutter build web --release $DEFINES        # build/web → herhangi bir statik hosting
flutter build appbundle --release $DEFINES  # Google Play
flutter build ipa --release $DEFINES        # App Store
```
Web, `#` olmayan yollar kullanır (`/uyelik`). Hosting'de tüm yolları `index.html`'e yönlendirin (SPA rewrite).

### Ödeme akışı
```
[COOL'a geç] → giriş yoksa /kayit?plan=cool → kayıt → /app/uyelik?plan=cool
            → Edge Function create-checkout-session → Stripe Checkout (web: aynı sekme, mobil: uygulama içi tarayıcı)
            → ödeme → /app/uyelik?durum=basarili
            → stripe-webhook → profiles.tier = 'cool' → uygulama üyeliği tazeler
```

## Yayın: notdulbutcool.com (GitHub Pages + GoDaddy)

`main` dalına her push'ta `.github/workflows/deploy-web.yml` siteyi derleyip GitHub Pages'e yayınlar. `app/web/CNAME` alan adını tanımlar.

**1. GitHub (bir kez):** Repo → Settings → Pages → *Source: GitHub Actions*. Ardından *Custom domain* = `notdulbutcool.com`, DNS doğrulanınca **Enforce HTTPS** işaretlenir.
Supabase hazır olduğunda Settings → Secrets and variables → Actions → **Variables**: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.

**2. GoDaddy → Domain → DNS → DNS Records:**

| Tür | Ad | Değer | TTL |
|-----|----|-------|-----|
| A | @ | 185.199.108.153 | 1 saat |
| A | @ | 185.199.109.153 | 1 saat |
| A | @ | 185.199.110.153 | 1 saat |
| A | @ | 185.199.111.153 | 1 saat |
| CNAME | www | gizembayar.github.io | 1 saat |

GoDaddy'nin varsayılan `A @ → Parked` kaydını ve varsa *Forwarding* ayarını silin. DNS yayılımı birkaç dakika ile 48 saat sürebilir.

**3. Supabase / Stripe:** Supabase Auth Site URL ve Edge Functions `SITE_URL` = `https://notdulbutcool.com`.

## ⚠️ Mağaza kuralları (önemli)

**Apple App Store**, uygulama içinde tüketilen dijital içeriğin (video eğitim, meditasyon, PDF) **Stripe gibi harici ödemeyle satılmasına** genel olarak izin vermez; In-App Purchase ister. Bu yüzden `HIDE_PURCHASE_ON_IOS=true` (varsayılan) iken iOS uygulamasında satın alma butonları gizlenir ve kullanıcı web'de aldığı üyelikle giriş yapar (“reader app” yaklaşımı). Google Play'de de benzer kurallar vardır. Fiziksel hizmetler (buluşma, tatil) bu kuralın dışındadır. Mobil mağazalarda abonelik satışı istenirse RevenueCat/StoreKit entegrasyonu ayrı bir adım olarak eklenmelidir.

## Kod yapısı (`app/lib`)

```
core/      theme.dart (renk sistemi + Inter tipografi), router.dart, config.dart
data/      models.dart (Tier, CoolArea, ContentItem, LifeProfile), catalog.dart (başlangıç içerikleri)
services/  backend.dart (Supabase + Demo), session.dart (durum + öneri motoru), billing.dart (Stripe akışı)
widgets/   brand.dart (Wordmark, PosterCard, ContentTile…), public_scaffold.dart (web menü + footer)
features/  landing · pricing · auth · onboarding · today · discover · me · plan · profile · content · shell
```

Marka: Kobalt `#2944B5`, Krem `#F5EFDD`, Limon `#F3DB65`, Mercan `#EF604D`, Siyah `#202020`; Inter Display Black (logo), Inter Bold (başlık), Inter Regular (metin). Fontlar uygulamaya gömülüdür (`app/assets/fonts`, SIL OFL).

## Sonraki adımlar

- İçerik kataloğunu Supabase tablosuna / CMS'e taşımak, video için Mux veya Vimeo, PDF için Supabase Storage (imzalı URL).
- Buluşma/tatil için kontenjanlı kayıt ve tek seferlik Stripe ödemesi.
- Kariyer eşleşmesi için mentor profilleri ve eşleştirme formu.
- KVKK aydınlatma metni, mesafeli satış sözleşmesi ve iptal/iade koşulları sayfaları (hukukçu onaylı).
- Analitik (gizlilik dostu) ve push bildirimleri.

## Geliştirme

```bash
cd app
flutter analyze
flutter test
```
