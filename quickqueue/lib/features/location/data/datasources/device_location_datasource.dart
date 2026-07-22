import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/coordinates.dart';

abstract class DeviceLocationDataSource {
  Future<Coordinates> getCurrentPosition();
}

/// Wraps the `geolocator` plugin's permission flow so callers just get a
/// [Coordinates] or a descriptive [AppException] instead of dealing with
/// service/permission checks themselves.
class GeolocatorDeviceLocationDataSource implements DeviceLocationDataSource {
  @override
  Future<Coordinates> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const ValidationException('Turn on location services to find nearby places.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const ValidationException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ValidationException(
        kIsWeb
            ? "Location access is blocked for this site. Allow it in your browser's site settings and try again."
            : 'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
    return Coordinates(latitude: position.latitude, longitude: position.longitude);
  }
}
