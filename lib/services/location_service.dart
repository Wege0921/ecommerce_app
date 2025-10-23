import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  Future<String?> getCityAndCountry() async {
    final ok = await _ensurePermission();
    if (!ok) return null;
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    final placemarks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isEmpty) return null;
    final p = placemarks.first;
    final city = p.locality?.isNotEmpty == true ? p.locality : p.subAdministrativeArea;
    final region = p.administrativeArea;
    final country = p.country;
    // Prefer City, Region (Country)
    if (city != null && city!.isNotEmpty && country != null && country!.isNotEmpty) {
      return "$city, ${country!}";
    }
    if (region != null && region!.isNotEmpty && country != null && country!.isNotEmpty) {
      return "$region, ${country!}";
    }
    return country ?? null;
  }
}
