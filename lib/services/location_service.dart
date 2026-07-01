import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.address,
  });
}

class LocationService {
  static Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin akses lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin akses lokasi ditolak secara permanen.');
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    String address = 'Alamat tidak ditemukan';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final List<String> parts = [];
        if (pm.street != null && pm.street!.isNotEmpty) parts.add(pm.street!);
        if (pm.subLocality != null && pm.subLocality!.isNotEmpty) parts.add(pm.subLocality!);
        if (pm.locality != null && pm.locality!.isNotEmpty) parts.add(pm.locality!);
        if (pm.subAdministrativeArea != null && pm.subAdministrativeArea!.isNotEmpty) {
          parts.add(pm.subAdministrativeArea!);
        }
        if (pm.administrativeArea != null && pm.administrativeArea!.isNotEmpty) {
          parts.add(pm.administrativeArea!);
        }
        address = parts.join(', ');
      }
    } catch (e) {
      address = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      address: address,
    );
  }
}
