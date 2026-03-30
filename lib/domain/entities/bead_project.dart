class BeadProject {
  const BeadProject({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.paletteId,
    required this.activeLayerId,
    this.thumbnailPath,
    this.syncState = 'local_only',
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int canvasWidth;
  final int canvasHeight;
  final String paletteId;
  final String activeLayerId;
  final String? thumbnailPath;
  final String syncState;

  BeadProject copyWith({
    String? name,
    DateTime? updatedAt,
    int? canvasWidth,
    int? canvasHeight,
    String? paletteId,
    String? activeLayerId,
    String? thumbnailPath,
    String? syncState,
  }) {
    return BeadProject(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      paletteId: paletteId ?? this.paletteId,
      activeLayerId: activeLayerId ?? this.activeLayerId,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      syncState: syncState ?? this.syncState,
    );
  }
}

