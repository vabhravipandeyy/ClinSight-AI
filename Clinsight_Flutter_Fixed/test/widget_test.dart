import 'package:flutter_test/flutter_test.dart';

import 'package:clinsight_ai/main.dart';

void main() {
  testWidgets('login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ClinSightApp());

    expect(find.text('ClinSight AI'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
