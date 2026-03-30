import 'package:beads_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BeadsApp()));
    expect(find.text('拼豆软件 P0'), findsOneWidget);
  });
}

