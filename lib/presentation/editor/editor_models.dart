class ImportConfig {
  const ImportConfig({
    required this.outputWidth,
    required this.outputHeight,
    required this.maxColors,
    required this.enableDithering,
    required this.keepBackground,
  });

  final int outputWidth;
  final int outputHeight;
  final int maxColors;
  final bool enableDithering;
  final bool keepBackground;
}

enum ExportPreset {
  preview,
  grid,
  indexedGuide,
}
