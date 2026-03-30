import 'package:beads_app/app/app.dart';
import 'package:beads_app/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {FakeProjectRepository? repository}) async {
    final repo = repository ?? FakeProjectRepository(initial: [sampleSnapshot()]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectRepositoryProvider.overrideWithValue(repo),
          assetStorageProvider.overrideWithValue(FakeAssetStorageService()),
        ],
        child: const BeadsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.textContaining('测试项目').first);
    await tester.pumpAndSettle();
  }

  testWidgets('底部 Tab 可以切换 功能/我的', (tester) async {
    await pumpApp(tester);

    expect(find.text('功能'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('设置与版本信息'), findsOneWidget);
  });

  testWidgets('从功能页进入编辑器后，底部 Tab 隐藏', (tester) async {
    await pumpApp(tester);
    await openEditor(tester);

    expect(find.text('功能'), findsNothing);
    expect(find.text('我的'), findsNothing);
    expect(find.text('测试项目'), findsOneWidget);
  });

  testWidgets('编辑器工具栏顺序固定并可切换选中态', (tester) async {
    await pumpApp(tester);
    await openEditor(tester);

    final labels = ['画笔', '橡皮', '吸色', '框选', '移动'];
    var prevDx = -1.0;
    for (final label in labels) {
      final finder = find.text(label);
      expect(finder, findsOneWidget);
      final dx = tester.getTopLeft(finder).dx;
      expect(dx, greaterThan(prevDx));
      prevDx = dx;
    }

    final before = tester.widget<Text>(find.text('橡皮'));
    expect(before.style?.color, isNot(Colors.white));

    await tester.tap(find.text('橡皮'));
    await tester.pump(const Duration(milliseconds: 180));

    final after = tester.widget<Text>(find.text('橡皮'));
    expect(after.style?.color, Colors.white);
  });

  testWidgets('创建项目弹窗字段校验与按钮状态正确', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add_box_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.enterText(find.byType(TextField).at(2), '58');
    await tester.pumpAndSettle();

    expect(find.text('请填写名称，并保证宽高在 8~256 之间'), findsOneWidget);
    final invalidButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '创建'));
    expect(invalidButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), '有效项目');
    await tester.enterText(find.byType(TextField).at(1), '58');
    await tester.enterText(find.byType(TextField).at(2), '58');
    await tester.pumpAndSettle();

    final validButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '创建'));
    expect(validButton.onPressed, isNotNull);
  });
}
