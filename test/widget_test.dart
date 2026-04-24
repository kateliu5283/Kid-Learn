import 'package:flutter_test/flutter_test.dart';
import 'package:kid_learn/app.dart';

void main() {
  testWidgets('App 啟動顯示 Splash', (WidgetTester tester) async {
    await tester.pumpWidget(const KidLearnApp());
    expect(find.text('小學堂'), findsOneWidget);
  });
}
