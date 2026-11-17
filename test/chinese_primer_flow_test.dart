import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/curriculum/catalog.dart';
import 'package:kid_learn/curriculum/chinese/primer/kangxuan_primer.dart';
import 'package:kid_learn/models/lesson.dart';
import 'package:kid_learn/providers/progress_provider.dart';
import 'package:kid_learn/screens/handwriting/handwriting_hub_screen.dart';
import 'package:kid_learn/screens/lesson_detail_screen.dart';
import 'package:kid_learn/screens/quiz_screen.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => 1,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  testWidgets('首冊課程可進入生字手寫，一下課程不出現這一步', (tester) async {
    final lesson = kKangxuanPrimerLessons.first;
    await _pump(tester, LessonDetailScreen(lesson: lesson));

    expect(find.text('生字手寫'), findsOneWidget);
    expect(find.text('${lesson.writingPractice.length} 個字'), findsOneWidget);
    expect(find.text('${lesson.questions.length} 題'), findsOneWidget);

    await tester.ensureVisible(find.text('生字手寫'));
    await tester.tap(find.text('生字手寫'));
    await tester.pumpAndSettle();

    expect(find.text('康軒・貓咪'), findsOneWidget);
    expect(find.text(lesson.writingPractice.first.char), findsWidgets);
    expect(find.text(lesson.writingPractice.first.zhuyin), findsOneWidget);
    expect(find.text('下一字'), findsOneWidget);
  });

  testWidgets('沒有生字的課程不出現手寫步驟', (tester) async {
    final later = kLessons.firstWhere(
      (item) =>
          item.subjectId == 'chinese' &&
          item.grade == 1 &&
          item.semester == Semester.second,
    );
    expect(later.writingPractice, isEmpty);
    await _pump(tester, LessonDetailScreen(lesson: later));
    await tester.scrollUntilVisible(find.text('測驗'), 400);
    expect(find.text('測驗'), findsOneWidget);
    expect(find.text('生字手寫'), findsNothing);
  });

  testWidgets('測驗會用本課題庫，答對後進到下一題', (tester) async {
    final lesson = kKangxuanPrimerLessons.first;
    final first = lesson.questions.first;
    await _pump(tester, QuizScreen(lesson: lesson));

    expect(find.text('貓咪（1/${lesson.questions.length}）'), findsOneWidget);
    expect(find.text(first.prompt), findsOneWidget);

    final answer = first.options[first.correctIndex];
    await tester.ensureVisible(find.text(answer));
    await tester.tap(find.text(answer));
    await tester.pump();
    await tester.tap(find.text('確認答案'));
    await tester.pump();

    expect(find.text(first.explanation!), findsOneWidget);
    await tester.tap(find.text('下一題'));
    await tester.pump();
    expect(find.text('第 2 題'), findsOneWidget);
    expect(find.text(lesson.questions[1].prompt), findsOneWidget);
  });

  testWidgets('一年級手寫首頁列出課本生字，並可打開該課', (tester) async {
    await _pump(tester, const HandwritingHubScreen());
    expect(find.text('課本生字'), findsOneWidget);
    expect(find.text('康軒・貓咪'), findsOneWidget);
    await tester.tap(find.text('康軒・貓咪'));
    await tester.pumpAndSettle();
    expect(find.text('下一字'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('翰林・手拉手'), 400);
    expect(find.text('翰林・手拉手'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('南一・踢踏踢'), 400);
    expect(find.text('南一・踢踏踢'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: MaterialApp(home: home),
    ),
  );
  await tester.pump();
}
