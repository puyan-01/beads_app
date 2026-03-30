class BeadLayer {
  const BeadLayer({
    required this.id,
    required this.name,
    required this.visible,
    required this.cells,
  });

  final String id;
  final String name;
  final bool visible;
  final List<int> cells;

  BeadLayer copyWith({
    String? id,
    String? name,
    bool? visible,
    List<int>? cells,
  }) {
    return BeadLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      visible: visible ?? this.visible,
      cells: cells ?? this.cells,
    );
  }
}

