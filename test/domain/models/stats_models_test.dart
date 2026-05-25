import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/domain/models/social_stats_model.dart';
import 'package:Constancy/domain/models/stats_model.dart';

void main() {
  group('Stats Models Test', () {
    test('SocialStats assigna valors correctament', () {
      final stats = SocialStats(followersCount: 10, followingCount: 5, hasPendingRequests: true);
      expect(stats.followersCount, 10);
      expect(stats.hasPendingRequests, isTrue);
    });

    test('HabitStats utilitza valors per defecte', () {
      final stats = HabitStats();
      expect(stats.totalExpected, 0);
      expect(stats.completionPercentage, 0.0);
    });
  });
}