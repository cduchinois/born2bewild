import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraView extends StatefulWidget {
  final Function(CameraImage) onImage;
  final Function() onCapture;

  const CameraView({
    Key? key,
    required this.onImage,
    required this.onCapture,
  }) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
      _controller!.startImageStream((image) {
        if (!_isBusy) {
          _isBusy = true;
          widget.onImage(image);
          _isBusy = false;
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller?.value.isInitialized ?? false
            ? CameraPreview(_controller!)
            : const Center(child: CircularProgressIndicator()),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: widget.onCapture,
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
