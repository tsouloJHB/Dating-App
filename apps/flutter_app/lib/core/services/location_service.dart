import 'package:location/location.dart';

abstract class LocationService {
  Future<bool> requestLocationPermission();

  Future<LocationData?> getCurrentLocation();

  Future<bool> isLocationServiceEnabled();
}

class LocationServiceImpl implements LocationService {
  final Location _location = Location();

  @override
  Future<bool> requestLocationPermission() async {
    final permission = await _location.requestPermission();
    return permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      if (!await isLocationServiceEnabled()) {
        return null;
      }

      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return _location.serviceEnabled();
  }
}
