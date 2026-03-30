import 'package:beads_app/app/providers.dart';
import 'package:beads_app/domain/entities/bead_project.dart';
import 'package:beads_app/presentation/editor/editor_page.dart';
import 'package:beads_app/presentation/feature/feature_page.dart';
import 'package:beads_app/presentation/profile/profile_page.dart';
import 'package:beads_app/presentation/template/template_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester,
    Widget child, {
    FakeProjectRepository? repo,
    Future<List<BeadProject>> Function()? recentOverride,
  }) async {
    final repository = repo ?? FakeProjectRepository(initial: [sampleSnapshot()]);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWithValue(repository),
          assetStorageProvider.overrideWithValue(FakeAssetStorageService()),
          if (recentOverride != null)
            recentProjectsProvider.overrideWith((ref) async => await recentOverride()),
        ],
        child: MaterialApp(home: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('golden feature empty', (tester) async {
    await pumpPage(
      tester,
      const FeaturePage(),
      repo: FakeProjectRepository(initial: []),
      recentOverride: () async => [],
    );
    await expectLater(
      find.byType(FeaturePage),
      matchesGoldenFile('../goldens/feature_empty.png'),
    );
  });

  testWidgets('golden feature list', (tester) async {
    await pumpPage(tester, const FeaturePage());
    await expectLater(
      find.byType(FeaturePage),
      matchesGoldenFile('../goldens/feature_list.png'),
    );
  });

  testWidgets('golden template placeholder', (tester) async {
    await pumpPage(tester, const TemplatePage());
    await expectLater(
      find.byType(TemplatePage),
      matchesGoldenFile('../goldens/template_placeholder.png'),
    );
  });

  testWidgets('golden profile default', (tester) async {
    await pumpPage(tester, const ProfilePage());
    await expectLater(
      find.byType(ProfilePage),
      matchesGoldenFile('../goldens/profile_default.png'),
    );
  });

  testWidgets('golden editor default and selection', (tester) async {
    final snapshot = sampleSnapshot(width: 20, height: 20);
    await pumpPage(tester, EditorPage(initialSnapshot: snapshot));

    await expectLater(
      find.byType(EditorPage),
      matchesGoldenFile('../goldens/editor_default.png'),
    );

    await tester.tap(find.text('框选'));
    await tester.pumpAndSettle();

    final canvasFinder = find.byType(CustomPaint).first;
    final origin = tester.getTopLeft(canvasFinder) + const Offset(20, 20);
    await tester.dragFrom(origin, const Offset(64, 64));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(EditorPage),
      matchesGoldenFile('../goldens/editor_selection.png'),
    );
  });
}
