import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../core/config.dart';
import '../data/models.dart';

/// Kullanıcıya ait kalıcı veri.
class MemberData {
  const MemberData({
    required this.user,
    this.life = const LifeProfile(),
    this.saved = const [],
    this.done = const [],
  });

  final AppUser user;
  final LifeProfile life;
  final List<String> saved;
  final List<String> done;
}

/// Giriş, profil ve ödeme işlemleri için tek arayüz.
/// [SupabaseBackend] gerçek ortam, [DemoBackend] backend'siz deneme içindir.
abstract class Backend {
  static late final Backend instance;

  static Future<void> init() async {
    if (AppConfig.isDemo) {
      instance = DemoBackend();
    } else {
      await sb.Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      instance = SupabaseBackend();
    }
  }

  bool get isDemo;

  /// Oturum değişikliklerini yayınlar (null = çıkış yapıldı).
  Stream<MemberData?> get changes;
  MemberData? get current;

  Future<void> restore();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();

  Future<void> saveLife(LifeProfile life);
  Future<void> saveLists({List<String>? saved, List<String>? done});

  /// Stripe Checkout oturumu açar ve ödeme sayfası URL'sini döner.
  /// Demo modda null döner ve üyelik anında yükseltilir.
  Future<Uri?> createCheckout(Tier tier, BillingPeriod period);

  /// Stripe Müşteri Portalı (iptal, kart değişikliği, fatura).
  Future<Uri?> createPortal();

  /// Ödeme sonrası üyeliği sunucudan tazeler (webhook işlendikten sonra).
  Future<void> refreshMembership();
}

/// Hata değil, kullanıcıya gösterilecek olumlu bilgi (ör. "e-postanı kontrol et").
class AuthNotice implements Exception {
  AuthNotice(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

// ───────────────────────────────────────────────────────────────────────────
// Supabase + Stripe (Edge Functions)
// ───────────────────────────────────────────────────────────────────────────

class SupabaseBackend implements Backend {
  SupabaseBackend() {
    _client.auth.onAuthStateChange.listen((event) async {
      if (event.session == null) {
        _set(null);
      } else if (event.event == sb.AuthChangeEvent.signedIn ||
          event.event == sb.AuthChangeEvent.initialSession) {
        await _load();
      }
    });
  }

  final _client = sb.Supabase.instance.client;
  final _controller = StreamController<MemberData?>.broadcast();
  MemberData? _current;

  @override
  bool get isDemo => false;
  @override
  Stream<MemberData?> get changes => _controller.stream;
  @override
  MemberData? get current => _current;

  void _set(MemberData? d) {
    _current = d;
    _controller.add(d);
  }

  Future<void> _load() async {
    final u = _client.auth.currentUser;
    if (u == null) return _set(null);
    final row = await _client
        .from('profiles')
        .select('display_name, tier, life_profile, saved_ids, done_ids')
        .eq('id', u.id)
        .maybeSingle();
    _set(
      MemberData(
        user: AppUser(
          id: u.id,
          email: u.email ?? '',
          displayName:
              row?['display_name'] as String? ??
              u.userMetadata?['display_name'] as String?,
          tier: Tier.fromId(row?['tier'] as String?),
        ),
        life: LifeProfile.fromJson(
          row?['life_profile'] as Map<String, dynamic>?,
        ),
        saved: (row?['saved_ids'] as List?)?.cast<String>() ?? const [],
        done: (row?['done_ids'] as List?)?.cast<String>() ?? const [],
      ),
    );
  }

  @override
  Future<void> restore() => _load();

  Future<T> _guard<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on sb.AuthException catch (e) {
      throw AuthFailure(_tr(e.message));
    } on sb.FunctionException catch (e) {
      throw AuthFailure('Ödeme servisine ulaşılamadı (${e.status}).');
    }
  }

  String _tr(String m) {
    final l = m.toLowerCase();
    if (l.contains('invalid login')) return 'E-posta ya da şifre hatalı.';
    if (l.contains('already registered')) {
      return 'Bu e-posta ile zaten bir hesap var.';
    }
    if (l.contains('password')) return 'Şifre en az 8 karakter olmalı.';
    if (l.contains('email not confirmed')) {
      return 'Lütfen e-postandaki onay bağlantısına tıkla.';
    }
    return m;
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() async {
        await _client.auth.signInWithPassword(email: email, password: password);
        await _load();
      });

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) => _guard(() async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': name},
      emailRedirectTo: '${AppConfig.siteUrl}/app/bugun',
    );
    if (res.session == null) {
      throw AuthNotice(
        'Hesabın oluşturuldu! Onay bağlantısı için e-postanı kontrol et; '
        'bağlantıya tıkladıktan sonra giriş yapabilirsin.',
      );
    }
    await _load();
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(
    () => _client.auth.resetPasswordForEmail(
      email,
      redirectTo: '${AppConfig.siteUrl}/giris',
    ),
  );

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<void> _update(Map<String, dynamic> values) async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return;
    await _client.from('profiles').update(values).eq('id', id);
  }

  @override
  Future<void> saveLife(LifeProfile life) async {
    await _update({'life_profile': life.toJson()});
    final c = _current;
    if (c != null) {
      _set(MemberData(user: c.user, life: life, saved: c.saved, done: c.done));
    }
  }

  @override
  Future<void> saveLists({List<String>? saved, List<String>? done}) async {
    await _update({'saved_ids': ?saved, 'done_ids': ?done});
    final c = _current;
    if (c != null) {
      _set(
        MemberData(
          user: c.user,
          life: c.life,
          saved: saved ?? c.saved,
          done: done ?? c.done,
        ),
      );
    }
  }

  @override
  Future<Uri?> createCheckout(Tier tier, BillingPeriod period) =>
      _guard(() async {
        final res = await _client.functions.invoke(
          'create-checkout-session',
          body: {
            'tier': tier.id,
            'period': period.name,
            'success_url': '${AppConfig.siteUrl}/app/uyelik?durum=basarili',
            'cancel_url': '${AppConfig.siteUrl}/uyelik?durum=iptal',
          },
        );
        return Uri.parse((res.data as Map)['url'] as String);
      });

  @override
  Future<Uri?> createPortal() => _guard(() async {
    final res = await _client.functions.invoke(
      'create-portal-session',
      body: {'return_url': '${AppConfig.siteUrl}/app/profil'},
    );
    return Uri.parse((res.data as Map)['url'] as String);
  });

  @override
  Future<void> refreshMembership() => _load();
}

// ───────────────────────────────────────────────────────────────────────────
// Demo (yerel, backend'siz)
// ───────────────────────────────────────────────────────────────────────────

class DemoBackend implements Backend {
  static const _key = 'ndbc_demo_member';
  final _controller = StreamController<MemberData?>.broadcast();
  MemberData? _current;

  @override
  bool get isDemo => true;
  @override
  Stream<MemberData?> get changes => _controller.stream;
  @override
  MemberData? get current => _current;

  Future<void> _set(MemberData? d) async {
    _current = d;
    _controller.add(d);
    final prefs = await SharedPreferences.getInstance();
    if (d == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(
        _key,
        jsonEncode({
          'id': d.user.id,
          'email': d.user.email,
          'name': d.user.displayName,
          'tier': d.user.tier.id,
          'life': d.life.toJson(),
          'saved': d.saved,
          'done': d.done,
        }),
      );
    }
  }

  @override
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> j;
    try {
      final raw = prefs.getString(_key);
      if (raw == null) return;
      j = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      await prefs.remove(_key); // bozuk kayıt: temiz başla
      return;
    }
    _current = MemberData(
      user: AppUser(
        id: j['id'] as String,
        email: j['email'] as String,
        displayName: j['name'] as String?,
        tier: Tier.fromId(j['tier'] as String?),
      ),
      life: LifeProfile.fromJson(j['life'] as Map<String, dynamic>?),
      saved: (j['saved'] as List?)?.cast<String>() ?? const [],
      done: (j['done'] as List?)?.cast<String>() ?? const [],
    );
    _controller.add(_current);
  }

  void _validate(String email, String password) {
    if (!email.contains('@')) throw AuthFailure('Geçerli bir e-posta gir.');
    if (password.length < 8) {
      throw AuthFailure('Şifre en az 8 karakter olmalı.');
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _validate(email, password);
    await _set(
      MemberData(
        user: AppUser(id: 'demo-${email.hashCode}', email: email),
      ),
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _validate(email, password);
    await _set(
      MemberData(
        user: AppUser(
          id: 'demo-${email.hashCode}',
          email: email,
          displayName: name,
        ),
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() => _set(null);

  @override
  Future<void> saveLife(LifeProfile life) async {
    final c = _current;
    if (c == null) return;
    await _set(
      MemberData(user: c.user, life: life, saved: c.saved, done: c.done),
    );
  }

  @override
  Future<void> saveLists({List<String>? saved, List<String>? done}) async {
    final c = _current;
    if (c == null) return;
    await _set(
      MemberData(
        user: c.user,
        life: c.life,
        saved: saved ?? c.saved,
        done: done ?? c.done,
      ),
    );
  }

  @override
  Future<Uri?> createCheckout(Tier tier, BillingPeriod period) async {
    final c = _current;
    if (c == null) throw AuthFailure('Önce giriş yapmalısın.');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _set(
      MemberData(
        user: c.user.copyWith(tier: tier),
        life: c.life,
        saved: c.saved,
        done: c.done,
      ),
    );
    return null;
  }

  @override
  Future<Uri?> createPortal() async {
    final c = _current;
    if (c == null) return null;
    await _set(
      MemberData(
        user: c.user.copyWith(tier: Tier.free),
        life: c.life,
        saved: c.saved,
        done: c.done,
      ),
    );
    return null;
  }

  @override
  Future<void> refreshMembership() async {}
}
