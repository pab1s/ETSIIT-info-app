// pedometer_service.dart

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  Stream<StepCount>? _stepCountStream;

  Future<void> initializePedometer() async {
    if (await _requestPermission()) {
      _stepCountStream = Pedometer.stepCountStream;
    } else {
      throw Exception('Activity Recognition permission denied');
    }
  }

  Stream<StepCount>? get stepCountStream => _stepCountStream;

  Future<bool> _requestPermission() async {
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<bool> requestActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.request();
    return status.isGranted;
  }
}
