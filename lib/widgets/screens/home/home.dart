import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recorder/core/logging.dart';

late List<CameraDescription> _cameras;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _controller;

  bool _isCameraPermissionDenied = false;
  bool _isMicrophonePermissionDenied = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  requestPermissions() async {
    /**
     * Request for camera permission.
     */
    logger.wtf(await Permission.camera.request().isLimited);
    logger.wtf(await Permission.microphone.request().isLimited);
    final isCameraGranted = await Permission.camera.request().isGranted;
    if (isCameraGranted) setupCameras();
    setState(() {
      _isCameraPermissionDenied = !isCameraGranted;
    });

    /**
     * Request for microphone permission.
     */
    final isMicrophoneGranted = await Permission.microphone.request().isGranted;
    setState(() {
      _isMicrophonePermissionDenied = !isMicrophoneGranted;
    });
  }

  requestDeniedPermissions() async {
    await openAppSettings();
    await requestPermissions();
    await setupCameras();
  }

  setupCameras() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0],
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraPermissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Permission denied for camera"),
            TextButton(
              onPressed: requestDeniedPermissions,
              child: const Text("Open settings"),
            ),
          ],
        ),
      );
    }

    if (_isMicrophonePermissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Permission denied for microphone"),
            TextButton(
              onPressed: requestDeniedPermissions,
              child: const Text("Open settings"),
            ),
          ],
        ),
      );
    }

    return Container(
      child: _controller != null && _controller!.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            )
          : Container(),
    );
  }
}
