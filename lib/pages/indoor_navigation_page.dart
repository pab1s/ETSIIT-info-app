import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_pixelmatching/flutter_pixelmatching.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

import '../widgets/top_bar.dart';
import '../services/location_service.dart';
import '../entities/indoor.dart';

class IndoorNavPage extends StatefulWidget {
  final String subfolderName;

  const IndoorNavPage({super.key, required this.subfolderName});

  @override
  // ignore: library_private_types_in_public_api
  _IndoorNavPageState createState() => _IndoorNavPageState();
}

class _IndoorNavPageState extends State<IndoorNavPage>
    with SingleTickerProviderStateMixin {
  late List<String> sentences;
  int highlightedIndex = 0;
  StreamSubscription? _compassSubscription;
  CameraController? _cameraController;
  late Uint8List imageBytes;
  double _currentBearing = 0.0;
  Position? _currentPosition;
  late Timer _timer;
  bool isNearTarget = false;
  static const double proximityThreshold = 5.0; // 5 meters
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLocationAndOrientationListeners();
    sentences = receiveInstructions(widget.subfolderName);
    _initializePage();
  }

  void _initializePage() async {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
    _timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => _checkProximity());
    await _loadTargetImage(); // Ensure this is completed before any comparison
  }

  @override
  void dispose() {
    _timer.cancel();
    _cameraController?.dispose();
    _compassSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _checkProximity() async {
    if (_currentPosition == null) return;

    final targetCoordinates =
        receiveCoordinates(widget.subfolderName)[highlightedIndex];
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetCoordinates.latitude,
      targetCoordinates.longitude,
    );
    setState(() {
      isNearTarget = distance <= proximityThreshold;
    });
  }

  void _highlightNextOrFinish() {
    bool isLastSentence = highlightedIndex == sentences.length - 1;
    if (!isLastSentence) {
      _takePhotoAndCompare();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _cameraController?.initialize();
  }

  Future<void> _loadTargetImage() async {
    int imageIndex = highlightedIndex < sentences.length - 1
        ? highlightedIndex
        : highlightedIndex - 1;
    String imagePath = 'assets/indoor/${widget.subfolderName}/$imageIndex.jpeg';
    ByteData data = await rootBundle.load(imagePath);
    imageBytes = data.buffer.asUint8List();
  }

  void _takePhotoAndCompare() async {
    final ImagePicker picker = ImagePicker();
    await _loadTargetImage();

    try {
      // Capture image using device's camera
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        File imageFile = File(photo.path);
        Uint8List capturedImageBytes = await imageFile.readAsBytes();

        // Resize and compare images
        final similarity = await _compareImages(capturedImageBytes, imageBytes);
        _handleComparisonResult(similarity);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<double> _compareImages(
      Uint8List capturedImage, Uint8List targetImage) async {
    // Resize target image
    final imglib.Image? targetImg = imglib.decodeImage(targetImage);
    final imglib.Image resizedTargetImg =
        imglib.copyResize(targetImg!, width: 720);
    final resizedTargetBytes = imglib.encodeJpg(resizedTargetImg);

    // Initialize PixelMatching
    final matching = PixelMatching();
    await matching.initialize(image: resizedTargetBytes);

    // Process captured image
    double similarity = await matching.similarity(capturedImage);
    return similarity;
  }

  void _handleComparisonResult(double similarity) {
    print('Similarity: $similarity');

    if (similarity >= 0.85) {
      setState(() {
        highlightedIndex++;
      });
    } else {
      _showDialog("¡Ups!", "La imagen no coicide", retry: true);
    }
  }

  void _showDialog(String title, String content, {bool retry = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            if (retry)
              TextButton(
                child: const Text("Intentar de nuevo"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _takePhotoAndCompare();
                },
              ),
            TextButton(
              child: Text(retry ? "Continuar de todas formas" : "OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (retry) {
                  setState(() {
                    highlightedIndex++;
                  });
                  _controller.forward().then((_) => _controller.reverse());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _initLocationAndOrientationListeners() async {
    _currentPosition = await LocationService.determinePosition();

    _compassSubscription = FlutterCompass.events!.listen((compassEvent) {
      setState(() {
        if (_currentPosition != null && sentences.isNotEmpty) {
          final targetCoordinates =
              receiveCoordinates(widget.subfolderName)[highlightedIndex];
          double targetBearing = Geolocator.bearingBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            targetCoordinates.latitude,
            targetCoordinates.longitude,
          );
          _currentBearing = compassEvent.heading! - targetBearing;
        }
      });
    });
  }

  Future<bool> _isUserNearTarget() async {
    if (_currentPosition == null) {
      return false;
    }
    final targetCoordinates =
        receiveCoordinates(widget.subfolderName)[highlightedIndex];
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      targetCoordinates.latitude,
      targetCoordinates.longitude,
    );
    return distance <= proximityThreshold;
  }

  @override
  Widget build(BuildContext context) {
    bool isLastSentence = highlightedIndex == sentences.length - 1;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    List<String> displayedSentences = _getDisplayedSentences();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: "Localiza tu aula",
          //isDarkMode: isDarkMode,
        ),
      ),
      body: FutureBuilder<bool>(
        future: _isUserNearTarget(),
        builder: (context, snapshot) {
          bool isNearTarget = snapshot.data ?? false;

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isNearTarget)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "You are near!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Transform.rotate(
                  angle: -_currentBearing * (math.pi / 180.0),
                  child: const Icon(Icons.arrow_upward, size: 80),
                ),
                const SizedBox(height: 20),
                ...List.generate(displayedSentences.length, (index) {
                  int actualIndex =
                      sentences.indexOf(displayedSentences[index]);
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = actualIndex == highlightedIndex
                          ? _animation.value
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: actualIndex == highlightedIndex
                                ? Colors.blue[100]
                                : Colors.transparent,
                            border: actualIndex == highlightedIndex
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: Text(
                            displayedSentences[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _highlightNextOrFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastSentence
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    isLastSentence ? "Finish" : "Next",
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getDisplayedSentences() {
    int totalSentences = sentences.length;
    if (totalSentences <= 3) {
      return sentences;
    }

    if (highlightedIndex == 0) {
      return sentences.sublist(0, 3);
    } else if (highlightedIndex == totalSentences - 1) {
      return sentences.sublist(totalSentences - 3);
    } else {
      return sentences.sublist(highlightedIndex - 1, highlightedIndex + 2);
    }
  }
}
