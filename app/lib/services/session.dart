import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/catalog.dart';
import '../data/models.dart';
import 'backend.dart';

/// Uygulama genelindeki oturum durumu. go_router'ın `refreshListenable`'ı
/// olarak da kullanılır.
class Session extends ChangeNotifier {
  Session(this.backend) {
    _sub = backend.changes.listen((d) {
      _data = d;
      notifyListeners();
    });
    _data = backend.current;
  }

  final Backend backend;
  late final StreamSubscription<MemberData?> _sub;
  MemberData? _data;

  bool get signedIn => _data != null;
  AppUser? get user => _data?.user;
  Tier get tier => _data?.user.tier ?? Tier.free;
  LifeProfile get life => _data?.life ?? const LifeProfile();
  List<String> get saved => _data?.saved ?? const [];
  List<String> get done => _data?.done ?? const [];
  bool get needsOnboarding => signedIn && life.isEmpty;

  bool canAccess(ContentItem item) => tier.includes(item.requiredTier);
  bool isSaved(String id) => saved.contains(id);
  bool isDone(String id) => done.contains(id);

  Future<void> toggleSaved(String id) => backend.saveLists(
    saved: isSaved(id) ? (saved.toList()..remove(id)) : [...saved, id],
  );

  Future<void> markDone(String id) async {
    if (isDone(id)) return;
    await backend.saveLists(done: [...done, id]);
  }

  Future<void> toggleGoal(String goal) {
    final goals = life.weeklyGoals.toList();
    final key = '✓$goal';
    if (goals.contains(key)) {
      goals[goals.indexOf(key)] = goal;
    } else if (goals.contains(goal)) {
      goals[goals.indexOf(goal)] = key;
    }
    return backend.saveLife(life.copyWith(weeklyGoals: goals));
  }

  /// Kişiye uygun, az ama uygulanabilir öneriler.
  /// "500 etkinlik arasında kaybolmak yerine 3 öneri."
  List<ContentItem> recommendations({
    int limit = 3,
    Set<ContentKind>? kinds,
    Budget? budget,
    Company? company,
    CoolArea? area,
  }) {
    final l = life;
    final b = budget ?? l.budget;
    final c = company ?? l.company;
    int score(ContentItem i) {
      var s = 0;
      if (l.interests.contains(i.area)) s += 3;
      if (i.budget.index <= b.index) s += 2;
      if (i.company == Company.any || c == Company.any || i.company == c) {
        s += 1;
      }
      if (canAccess(i)) s += 1;
      if (isDone(i.id)) s -= 4;
      return s;
    }

    final list = catalog.where((i) {
      if (kinds != null && !kinds.contains(i.kind)) return false;
      if (area != null && i.area != area) return false;
      if (budget != null && i.budget.index > budget.index) return false;
      if (company != null &&
          company != Company.any &&
          i.company != Company.any &&
          i.company != company) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => score(b).compareTo(score(a)));
    return list.take(limit).toList();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Widget ağacına [Session] sağlar.
class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required Session session,
    required super.child,
  }) : super(notifier: session);

  static Session of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()!.notifier!;

  static Session read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SessionScope>()!.notifier!;
}

extension SessionContext on BuildContext {
  Session get session => SessionScope.of(this);
  Session get sessionRead => SessionScope.read(this);
}
