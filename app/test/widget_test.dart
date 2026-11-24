import 'package:flutter_test/flutter_test.dart';
import 'package:notdulbutcool/core/theme.dart';
import 'package:notdulbutcool/data/models.dart';

void main() {
  test('tier hierarchy', () {
    expect(Tier.icon.includes(Tier.cool), isTrue);
    expect(Tier.cool.includes(Tier.icon), isFalse);
    expect(Tier.fromId('unknown'), Tier.free);
  });

  test('turkish uppercase', () {
    expect('Bugün kendin için'.trUpper, 'BUGÜN KENDİN İÇİN');
    expect('ılık'.trUpper, 'ILIK');
  });

  test('life profile json round trip', () {
    const life = LifeProfile(
      interests: {CoolArea.sport, CoolArea.mind},
      wishes: {'Sosyal hayat'},
      budget: Budget.free,
      company: Company.withChild,
      weeklyGoals: ['Haftada 2 kez yürüyüş'],
    );
    final back = LifeProfile.fromJson(life.toJson());
    expect(back.interests, life.interests);
    expect(back.budget, Budget.free);
    expect(back.company, Company.withChild);
    expect(back.weeklyGoals, life.weeklyGoals);
  });
}
