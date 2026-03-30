import 'package:flutter/material.dart';

import 'package:beads_app/presentation/home/home_page.dart';

class BeadsApp extends StatelessWidget {
  const BeadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beads App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E7A6A)),
      ),
      home: const HomePage(),
    );
  }
}

