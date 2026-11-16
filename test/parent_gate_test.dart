import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/widgets/parent_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('problem uses a two-step product an adult can check', () {
    final problem = ParentGateProblem.random(Random(7));
    expect(problem.a, inInclusiveRange(12, 19));
    expect(problem.b, inInclusiveRange(6, 9));
    expect(problem.c, inInclusiveRange(13, 49));
    expect(problem.answer, problem.a * problem.b + problem.c);
    expect(problem.prompt, '${problem.a} × ${problem.b} + ${problem.c} = ?');
  });

  test('lockout is restored from local storage', () async {
    final until = DateTime.now().add(const Duration(minutes: 2));
    SharedPreferences.setMockInitialValues({
      ParentGateLock.untilKey: until.toIso8601String(),
      ParentGateLock.failuresKey: 2,
    });
    ParentGateLock.debugReset();

    await ParentGateLock.hydrate();

    expect(ParentGateLock.isLocked, isTrue);
    expect(ParentGateLock.failures, 2);
  });

  test('three failures persist a lock that a fresh read still sees', () async {
    SharedPreferences.setMockInitialValues({});
    ParentGateLock.debugReset();
    await ParentGateLock.hydrate();

    await ParentGateLock.registerFailure();
    await ParentGateLock.registerFailure();
    expect(ParentGateLock.isLocked, isFalse);

    await ParentGateLock.registerFailure();
    expect(ParentGateLock.isLocked, isTrue);

    ParentGateLock.debugReset();
    await ParentGateLock.hydrate();
    expect(ParentGateLock.isLocked, isTrue);
  });
}
