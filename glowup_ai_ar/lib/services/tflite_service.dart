import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteInferenceService {
  late Interpreter _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/makeup_transfer.tflite');
      _isLoaded = true;
      print('✅ TFLite model loaded');
    } catch (e) {
      print('❌ Model load error: $e');
      rethrow;
    }
  }

  bool get isLoaded => _isLoaded;

  Future<img.Image?> transferMakeup({
    required img.Image sourceImage,
    required img.Image styleImage,
  }) async {
    if (!_isLoaded) {
      throw Exception('Model not loaded');
    }

    try {
      const inputSize = 256;
      final srcResized = img.copyResize(sourceImage, width: inputSize, height: inputSize);
      final styResized = img.copyResize(styleImage, width: inputSize, height: inputSize);

      final srcTensor = _imageToBytesBuffer(srcResized);
      final styTensor = _imageToBytesBuffer(styResized);

      final maskC = Float32List(inputSize * inputSize * 6);
      final maskS = Float32List(inputSize * inputSize * 6);
      for (int i = 0; i < maskC.length; i++) {
        maskC[i] = 1.0;
        maskS[i] = 1.0;
      }

      final diffC = Float32List(inputSize * inputSize * 3);
      final diffS = Float32List(inputSize * inputSize * 3);

      final lmsC = Float32List(68 * 2);
      final lmsS = Float32List(68 * 2);

      for (int i = 0; i < 68; i++) {
        final angle = 2.0 * pi * i / 68;
        final x = (inputSize / 2.0) + (inputSize / 4.0) * cos(angle);
        final y = (inputSize / 2.0) + (inputSize / 4.0) * sin(angle);
        lmsC[i * 2] = x;
        lmsC[i * 2 + 1] = y;
        lmsS[i * 2] = x;
        lmsS[i * 2 + 1] = y;
      }

      print('🔄 Running inference...');

      final output = Float32List(1 * inputSize * inputSize * 3);

      _interpreter.runWithNamedOutputs({
        'content': srcTensor,
        'style': styTensor,
        'mask_c': maskC,
        'mask_s': maskS,
        'diff_c': diffC,
        'diff_s': diffS,
        'landmarks_c': lmsC,
        'landmarks_s': lmsS,
      }, {'output': output});

      print('✅ Inference complete');

      return _bytesBufferToImage(output, inputSize);
    } catch (e) {
      print('❌ Inference error: $e');
      rethrow;
    }
  }

  Float32List _imageToBytesBuffer(img.Image image) {
    const imageHeight = 256;
    const imageWidth = 256;

    final buffer = Float32List(1 * imageHeight * imageWidth * 3);
    int pixelIndex = 0;

    for (int i = 0; i < imageHeight; i++) {
      for (int j = 0; j < imageWidth; j++) {
        final pixel = image.getPixelSafe(j, i);
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;

        buffer[pixelIndex++] = r;
        buffer[pixelIndex++] = g;
        buffer[pixelIndex++] = b;
      }
    }

    return buffer;
  }

  img.Image _bytesBufferToImage(Float32List buffer, int size) {
    final image = img.Image(width: size, height: size);
    int pixelIndex = 0;

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        final r = ((buffer[pixelIndex++].clamp(0.0, 1.0) * 255).toInt()) & 0xFF;
        final g = ((buffer[pixelIndex++].clamp(0.0, 1.0) * 255).toInt()) & 0xFF;
        final b = ((buffer[pixelIndex++].clamp(0.0, 1.0) * 255).toInt()) & 0xFF;

        image.setPixelSafe(j, i, img.getColor(r, g, b));
      }
    }

    return image;
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
      _isLoaded = false;
    }
  }
}
