import 'package:flutter_test/flutter_test.dart';

import 'package:ai_education/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiEducationApp());

    expect(find.text('Learn AI\nStep by Step'), findsOneWidget);
    expect(find.text('Student Register'), findsOneWidget);
    expect(find.text('Moderator Login'), findsOneWidget);
  });
}
