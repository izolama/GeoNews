import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../providers/geocam_provider.dart';

class GeoCamScreen extends StatefulWidget {
  const GeoCamScreen({super.key});

  @override
  State<GeoCamScreen> createState() => _GeoCamScreenState();
}

class _GeoCamScreenState extends State<GeoCamScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _hasTakenPhoto = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final permissionStatusCamera = await Permission.camera.request();
    final permissionStatusStorage = await Permission.storage.request();

    if (permissionStatusCamera != PermissionStatus.granted ||
        permissionStatusStorage != PermissionStatus.granted) {
      setState(() {
        _isCameraPermissionGranted = false;
      });
      debugPrint('Camera or storage permission denied');
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    try {
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
        _isCameraPermissionGranted = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture(GeoCamProvider provider) async {
    if (!_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      provider.savePhoto(photo.path);
      setState(() {
        _hasTakenPhoto = true;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeoCamProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Location Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (provider.isLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (provider.currentPosition != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latitude: ${provider.currentPosition!.latitude}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Longitude: ${provider.currentPosition!.longitude}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )
                              else
                                const Text('No location data'),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => provider.getCurrentLocation(),
                                icon: const Icon(Icons.location_on),
                                label: const Text('Get Location'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Camera Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isCameraInitialized &&
                                  _isCameraPermissionGranted &&
                                  !_hasTakenPhoto)
                                AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: CameraPreview(_controller!),
                                )
                              else if (provider.photoPath != null)
                                Image.file(File(provider.photoPath!))
                              else
                                const Center(
                                  child: Text('Camera not initialized'),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _isCameraInitialized
                                        ? () => _takePicture(provider)
                                        : null,
                                    icon: const Icon(Icons.camera),
                                    label: const Text('Take Photo'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => provider.resetData(),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Reset Data'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Save Data Button
                      ElevatedButton.icon(
                        onPressed: (provider.currentPosition != null &&
                                provider.photoPath != null)
                            ? () => provider.saveCurrentEntry()
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Data'),
                      ),
                      const SizedBox(height: 16),
                      // Saved Entries List
                      provider.savedEntries.isEmpty
                          ? const Center(child: Text('No saved entries'))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.savedEntries.length,
                              itemBuilder: (context, index) {
                                final entry = provider.savedEntries[index];
                                final location = entry['location'];
                                final photoPath = entry['photoPath'] as String?;
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: photoPath != null
                                        ? Image.file(File(photoPath),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover)
                                        : const Icon(Icons.image_not_supported),
                                    title: Text(
                                        'Lat: ${location['latitude']}, Lon: ${location['longitude']}'),
                                    subtitle: Text(
                                        'Timestamp: ${location['timestamp'] ?? 'N/A'}'),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
