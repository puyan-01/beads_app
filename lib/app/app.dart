import 'package:flutter/material.dart';

import '../presentation/shell/shell_page.dart';
import 'ui/app_theme.dart';

class BeadsApp extends StatelessWidget {
  const BeadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beads App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ShellPage(),
    );
  }
}
