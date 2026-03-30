class BeadColor {
  const BeadColor({
    required this.code,
    required this.name,
    required this.r,
    required this.g,
    required this.b,
  });

  final String code;
  final String name;
  final int r;
  final int g;
  final int b;

  int get argb =>
      (0xFF << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
}

