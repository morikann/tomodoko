import 'package:geolocator/geolocator.dart';

class Location {
  double? latitude;
  double? longitude;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }

  String calculateDistance(la1, lo1, la2, lo2) {
    try {
      double distance = Geolocator.distanceBetween(la1, lo1, la2, lo2);
      return distance.round().toString();
    } catch (e) {
      return '---';
    }
  }

  double calculateBearing(la1, lo1, la2, lo2) {
    try {
      double bearing = Geolocator.bearingBetween(la1, lo1, la2, lo2);
      return bearing;
    } catch (e) {
      return 0;
    }
  }
}
