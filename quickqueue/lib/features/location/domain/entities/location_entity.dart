import 'package:equatable/equatable.dart';

enum LocationCategory { hospital, bank }

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.id,
    required this.name,
    required this.area,
    required this.district,
    required this.category,
    required this.colorValue,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String area;
  final String district;
  final LocationCategory category;

  /// ARGB color value used to tint the location's avatar chip.
  final int colorValue;

  final double latitude;
  final double longitude;

  String get avatarLetter => category == LocationCategory.hospital ? 'H' : 'B';

  @override
  List<Object?> get props =>
      [id, name, area, district, category, colorValue, latitude, longitude];
}
