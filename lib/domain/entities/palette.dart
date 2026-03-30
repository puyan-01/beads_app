import 'bead_color.dart';

class Palette {
  const Palette({
    required this.id,
    required this.name,
    required this.colors,
  });

  final String id;
  final String name;
  final List<BeadColor> colors;

  static const Palette defaultPalette = Palette(
    id: 'basic-16',
    name: 'Basic 16',
    colors: [
      BeadColor(code: 'WHT', name: 'White', r: 245, g: 245, b: 245),
      BeadColor(code: 'BLK', name: 'Black', r: 32, g: 32, b: 32),
      BeadColor(code: 'RED', name: 'Red', r: 210, g: 48, b: 58),
      BeadColor(code: 'ORG', name: 'Orange', r: 232, g: 132, b: 35),
      BeadColor(code: 'YLW', name: 'Yellow', r: 245, g: 211, b: 63),
      BeadColor(code: 'LIM', name: 'Lime', r: 159, g: 216, b: 67),
      BeadColor(code: 'GRN', name: 'Green', r: 58, g: 142, b: 66),
      BeadColor(code: 'CYN', name: 'Cyan', r: 58, g: 184, b: 191),
      BeadColor(code: 'BLU', name: 'Blue', r: 51, g: 103, b: 190),
      BeadColor(code: 'NVY', name: 'Navy', r: 40, g: 61, b: 128),
      BeadColor(code: 'PNK', name: 'Pink', r: 241, g: 150, b: 176),
      BeadColor(code: 'PUR', name: 'Purple', r: 138, g: 87, b: 165),
      BeadColor(code: 'BRN', name: 'Brown', r: 117, g: 78, b: 54),
      BeadColor(code: 'TAN', name: 'Tan', r: 178, g: 140, b: 94),
      BeadColor(code: 'GRY', name: 'Gray', r: 133, g: 133, b: 133),
      BeadColor(code: 'SKY', name: 'Sky', r: 165, g: 211, b: 237),
    ],
  );
}

