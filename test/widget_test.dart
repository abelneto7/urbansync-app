import 'package:flutter_test/flutter_test.dart';

import 'package:urbansync_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UrbanSyncApp());

    expect(find.text('UrbanSync'), findsWidgets);
  });
}
