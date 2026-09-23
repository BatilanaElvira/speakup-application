import 'package:flutter_test/flutter_test.dart';
import 'package:speakup/models/ai_evaluator.dart';
import 'package:speakup/models/category.dart';
import 'package:speakup/models/journey.dart';
import 'package:speakup/providers/app_provider.dart';

void main() {
  test('AppProvider state initialization test', () {
    final provider = AppProvider();
    expect(provider.userName, equals('Amina Bello'));
    expect(provider.streakDays, equals(7));
    expect(provider.userRole, equals('Trainee'));
    expect(provider.isSimulatedEnvironmentEnabled, isTrue);
    expect(AIEvaluator.evaluators.length, equals(8));
    expect(CategoryItem.categories.length, equals(10));
    expect(JourneyData.obstacles.length, greaterThanOrEqualTo(6));
  });

  test('AppProvider toggle user role test', () {
    final provider = AppProvider();
    expect(provider.userRole, equals('Trainee'));
    provider.toggleUserRole();
    expect(provider.userRole, equals('Admin'));
  });

  test('AppProvider simulated environment toggle test', () {
    final provider = AppProvider();
    expect(provider.isSimulatedEnvironmentEnabled, isTrue);
    provider.toggleSimulatedEnvironmentEnabled(false);
    expect(provider.isSimulatedEnvironmentEnabled, isFalse);
    provider.toggleSimulatedEnvironmentEnabled(true);
    expect(provider.isSimulatedEnvironmentEnabled, isTrue);
  });
}
