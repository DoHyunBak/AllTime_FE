import 'package:alltime_fe/app.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows login screen after splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const BetterFeedback(
        child: ProviderScope(
          child: AllTimeApp(),
        ),
      ),
    );

    expect(find.text('기숙사 생활의 모든 것'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('학생 데모'), findsOneWidget);
    expect(find.text('관리자 데모'), findsOneWidget);
  });
}
