import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../services/billing.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';
import '../shell/app_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final u = s.user;
    return AppPage(
      title: 'PROFİL',
      subtitle: u?.email,
      children: [
        const SizedBox(height: 20),
        CoolCard(
          color: s.tier.color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ÜYELİĞİN', style: BrandText.label(color: s.tier.onColor)),
              const SizedBox(height: 8),
              Text(
                s.tier.name,
                style: BrandText.logo(size: 30, color: s.tier.onColor),
              ),
              const SizedBox(height: 4),
              Text(
                s.tier.tagline,
                style: BrandText.italic(color: s.tier.onColor, size: 16),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (s.tier != Tier.icon)
                    FilledButton(
                      onPressed: () => context.push('/app/uyelik'),
                      style: FilledButton.styleFrom(
                        backgroundColor: s.tier == Tier.free
                            ? Brand.kobalt
                            : Brand.mercan,
                      ),
                      child: Text(
                        s.tier == Tier.free
                            ? 'Üyeliğini yükselt'
                            : 'Premium’a geç',
                      ),
                    ),
                  if (s.tier != Tier.free && !purchaseHiddenOnThisPlatform)
                    OutlinedButton(
                      onPressed: () => openBillingPortal(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: s.tier.onColor,
                        side: BorderSide(color: s.tier.onColor),
                      ),
                      child: const Text('Üyeliğimi yönet'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SectionLabel('Benim Hayatım'),
        CoolCard(
          color: Brand.beyaz,
          onTap: () => context.push('/app/hayatim'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in s.life.interests)
                    Chip(
                      label: Text(a.title),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${s.life.city} • ${s.life.time.join(', ')}',
                style: BrandText.body(size: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'İlgi alanlarını ve tercihlerini düzenle →',
                style: BrandText.label(),
              ),
            ],
          ),
        ),
        const SectionLabel('Kontrol sende'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.shield_outlined, color: Brand.kobalt),
          title: const Text('Gizlilik ve verilerim'),
          subtitle: const Text(
            'Çocuk bilgisi, bütçe ve takvim tercihe bağlıdır.',
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Verilerim'),
              content: const Text(
                'Yalnızca ilgi alanların, zaman ve bütçe tercihlerin saklanır. '
                'Hesabını ve tüm verilerini silmek için destek@notdulbutcool.com adresine yazabilirsin.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Brand.mercan),
          title: const Text('Çıkış yap'),
          onTap: () async {
            await s.backend.signOut();
            if (context.mounted) context.go('/');
          },
        ),
        if (s.backend.isDemo)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Demo mod aktif — ödemeler simüle ediliyor.',
              style: BrandText.body(size: 12, color: Colors.black45),
            ),
          ),
      ],
    );
  }
}
