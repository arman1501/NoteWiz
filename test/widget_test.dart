import 'package:flutter_test/flutter_test.dart';
import 'package:notewiz/main.dart';

void main() {
  testWidgets('NoteWiz smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NoteWizApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NoteWizApp), findsNothing);
  });
}
