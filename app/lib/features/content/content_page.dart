import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';

/// İçerik detayı + üyelik kapısı (paywall).
class ContentPage extends StatelessWidget {
  const ContentPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final item = findContent(id);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('İçerik bulunamadı.', style: BrandText.body()),
        ),
      );
    }
    final s = context.session;
    final locked = !s.canAccess(item);
    final saved = s.isSaved(item.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: item.area.color,
        foregroundColor: Brand.beyaz,
        title: Text(
          item.area.title,
          style: BrandText.label(color: Brand.beyaz, size: 14),
        ),
        actions: [
          IconButton(
            tooltip: saved ? 'Planımdan çıkar' : 'Planıma ekle',
            onPressed: () => s.toggleSaved(item.id),
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 28),
        children: [
          MaxWidth(
            width: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(item.kind.icon, color: Brand.mercan, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      item.meta.trUpper,
                      style: BrandText.label(color: Brand.mercan),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.title, style: BrandText.logo(size: 36)),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: BrandText.heading(size: 18, color: Brand.siyah),
                ),
                const SizedBox(height: 20),
                Text(item.description, style: BrandText.body(size: 16)),
                if (item.where != null) ...[
                  const SizedBox(height: 16),
                  _Info(Icons.place_outlined, item.where!),
                ],
                if (item.when != null) _Info(Icons.schedule, item.when!),
                if (item.priceNote != null)
                  _Info(Icons.info_outline, item.priceNote!),
                const SizedBox(height: 28),
                if (locked) _Paywall(item) else _Body(item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Brand.kobalt),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: BrandText.body(size: 14))),
      ],
    ),
  );
}

class _Paywall extends StatelessWidget {
  const _Paywall(this.item);
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final t = item.requiredTier;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t == Tier.icon ? Brand.kobalt : Brand.limon,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, color: t.onColor),
          const SizedBox(height: 10),
          Text(
            t == Tier.icon ? 'The Icon’lara özel.' : 'COOL üyelere açık.',
            style: BrandText.heading(size: 22, color: t.onColor),
          ),
          const SizedBox(height: 6),
          Text(
            t == Tier.icon
                ? 'Kariyer eşleşmeleri, kapalı buluşmalar ve birebir yol haritası seansları Premium üyelikte.'
                : 'Tüm eğitimler, nefes kütüphanesi, spor ve beslenme programları, buluşmalar COOL üyelikte.',
            style: BrandText.body(color: t.onColor),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => context.push('/app/uyelik?plan=${t.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: t == Tier.icon ? Brand.limon : Brand.kobalt,
              foregroundColor: t == Tier.icon ? Brand.kobalt : Brand.krem,
            ),
            child: Text('${t.name} planını gör'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.item);
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final s = context.session;
    final done = s.isDone(item.id);
    final action = switch (item.kind) {
      ContentKind.event => 'Katılacağım',
      ContentKind.trip => 'Ön kayıt bırak',
      ContentKind.match => 'Eşleşme talebi gönder',
      ContentKind.pdf => 'Kitapçığı indir',
      _ => 'Tamamladım',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (item.kind == ContentKind.breath)
          BreathPlayer(
            minutes: item.minutes ?? 8,
            onFinish: () => s.markDone(item.id),
          ),
        if (item.kind == ContentKind.video || item.kind == ContentKind.audio)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Brand.siyah,
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_circle_fill,
                size: 72,
                color: Brand.limon,
              ),
            ),
          ),
        if (item.lessons.isNotEmpty) ...[
          const SectionLabel('Bölümler'),
          for (final (i, l) in item.lessons.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Brand.limon,
                foregroundColor: Brand.kobalt,
                child: Text('${i + 1}'),
              ),
              title: Text(l, style: BrandText.body()),
            ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: done
              ? null
              : () async {
                  await s.markDone(item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harika. Kendin için bir şey yaptın. ✨'),
                      ),
                    );
                  }
                },
          icon: Icon(done ? Icons.check : Icons.arrow_forward),
          label: Text(done ? 'Yapıldı' : action),
        ),
      ],
    );
  }
}

/// Rehberli nefes: 4 sn al • 4 sn tut • 6 sn ver.
class BreathPlayer extends StatefulWidget {
  const BreathPlayer({super.key, required this.minutes, this.onFinish});
  final int minutes;
  final VoidCallback? onFinish;

  @override
  State<BreathPlayer> createState() => _BreathPlayerState();
}

class _BreathPlayerState extends State<BreathPlayer>
    with SingleTickerProviderStateMixin {
  static const phases = [('Nefes al', 4), ('Tut', 4), ('Yavaşça ver', 6)];
  late final AnimationController _anim = AnimationController(vsync: this);
  Timer? _timer;
  int _phase = 0;
  int _left = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _left = widget.minutes * 60;
  }

  void _start() {
    setState(() => _running = true);
    _runPhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 1) {
        _stop();
        widget.onFinish?.call();
        return;
      }
      setState(() => _left--);
    });
  }

  void _runPhase() {
    if (!_running) return;
    final (_, secs) = phases[_phase];
    _anim.duration = Duration(seconds: secs);
    final future = switch (_phase) {
      0 => _anim.forward(from: 0),
      1 => Future<void>.delayed(Duration(seconds: secs)),
      _ => _anim.reverse(from: 1),
    };
    future.then((_) {
      if (!mounted || !_running) return;
      setState(() => _phase = (_phase + 1) % phases.length);
      _runPhase();
    });
  }

  void _stop() {
    _timer?.cancel();
    _anim.stop();
    setState(() => _running = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_left ~/ 60).toString().padLeft(2, '0');
    final ss = (_left % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Brand.kobaltSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Center(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, _) {
                  final d = 110 + 100 * Curves.easeInOut.transform(_anim.value);
                  return Container(
                    width: d,
                    height: d,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Brand.limon,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _running ? phases[_phase].$1 : 'Hazır mısın?',
                      textAlign: TextAlign.center,
                      style: BrandText.heading(size: 16),
                    ),
                  );
                },
              ),
            ),
          ),
          Text('$mm:$ss', style: BrandText.logo(size: 32)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _running ? _stop : _start,
            icon: Icon(_running ? Icons.pause : Icons.play_arrow),
            label: Text(_running ? 'Duraklat' : 'Başla'),
          ),
        ],
      ),
    );
  }
}
