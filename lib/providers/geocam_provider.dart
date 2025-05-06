import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GeoCamProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _photoPath;
  bool _isLoading = false;

  // New list to hold saved entries of location and photo
  List<Map<String, dynamic>> _savedEntries = [];

  Position? get currentPosition => _currentPosition;
  String? get photoPath => _photoPath;
  bool get isLoading => _isLoading;

  // Getter for saved entries
  List<Map<String, dynamic>> get savedEntries => _savedEntries;

  GeoCamProvider() {
    _loadSavedData();
  }

  Future<void> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (position.altitude == 0.0) {
        throw Exception('Altitude accuracy is insufficient');
      }

      if (position.heading == 0.0) {
        debugPrint(
            'Warning: Heading accuracy is insufficient, ignoring heading value.');
        position = Position(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: position.timestamp,
          accuracy: position.accuracy,
          altitude: position.altitude,
          heading: -1.0,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePhoto(String path) async {
    _photoPath = path;
    notifyListeners();
  }

  Future<void> resetData() async {
    _currentPosition = null;
    _photoPath = null;
    _savedEntries = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('location');
    await prefs.remove('photo');
    await prefs.remove('savedEntries');
    notifyListeners();
  }

  // New method to add current location and photo as a saved entry
  Future<void> saveCurrentEntry() async {
    if (_currentPosition == null || _photoPath == null) return;

    final entry = {
      'location': {
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'timestamp': _currentPosition!.timestamp?.toIso8601String(),
        'accuracy': _currentPosition!.accuracy,
        'altitude': _currentPosition!.altitude,
        'heading': _currentPosition!.heading,
        'speed': _currentPosition!.speed,
        'speedAccuracy': _currentPosition!.speedAccuracy,
      },
      'photoPath': _photoPath,
    };

    _savedEntries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved entries list
    final savedEntriesJson = prefs.getString('savedEntries');
    if (savedEntriesJson != null) {
      final List<dynamic> decodedList = json.decode(savedEntriesJson);
      _savedEntries = decodedList.map((item) {
        final locationMap = item['location'];
        return {
          'location': {
            'latitude': locationMap['latitude'],
            'longitude': locationMap['longitude'],
            'timestamp': locationMap['timestamp'] != null
                ? DateTime.parse(locationMap['timestamp'])
                : DateTime.now(),
            'accuracy': (locationMap['accuracy'] as num).toDouble(),
            'altitude': (locationMap['altitude'] as num).toDouble(),
            'heading': (locationMap['heading'] as num).toDouble(),
            'speed': (locationMap['speed'] as num).toDouble(),
            'speedAccuracy': (locationMap['speedAccuracy'] as num).toDouble(),
          },
          'photoPath': item['photoPath'],
        };
      }).toList();
    }

    // Load current location and photo path for UI
    final locationJson = prefs.getString('location');
    if (locationJson != null) {
      final locationMap = json.decode(locationJson);
      _currentPosition = Position(
        latitude: locationMap['latitude'],
        longitude: locationMap['longitude'],
        timestamp: locationMap['timestamp'] != null
            ? DateTime.parse(locationMap['timestamp'])
            : DateTime.now(),
        accuracy: (locationMap['accuracy'] as num).toDouble(),
        altitude: (locationMap['altitude'] as num).toDouble(),
        heading: (locationMap['heading'] as num).toDouble(),
        speed: (locationMap['speed'] as num).toDouble(),
        speedAccuracy: (locationMap['speedAccuracy'] as num).toDouble(),
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }

    _photoPath = prefs.getString('photo');

    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEntries', json.encode(_savedEntries));
  }
}
