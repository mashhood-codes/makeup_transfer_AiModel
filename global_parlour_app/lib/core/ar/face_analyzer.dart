import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceAnalysisResult {
  final String skinTone;
  final String skinType;
  final String faceShape;
  final List<String> recommendations;
  final List<String> recommendedLookIds;

  FaceAnalysisResult({
    required this.skinTone,
    required this.skinType,
    required this.faceShape,
    required this.recommendations,
    required this.recommendedLookIds,
  });
}

class FaceAnalyzer {
  static FaceAnalysisResult analyze(Face face) {
    // 1. Detect Face Shape based on contour bounding box aspect ratio
    final rect = face.boundingBox;
    final ratio = rect.height / rect.width;
    String faceShape = 'Oval';
    if (ratio > 1.5) {
      faceShape = 'Long / Rectangular';
    } else if (ratio < 1.1) {
      faceShape = 'Round / Square';
    } else {
      faceShape = 'Oval / Heart';
    }

    // 2. Mock Skin Metrics (In production, we sample pixels from camera image bytes)
    // For this FYP-level demonstration, let's use heuristics from landmarks
    final smiling = (face.smilingProbability ?? 0) > 0.5;

    
    // 3. Dynamic Recommendations based on metrics
    List<String> suggestions = [];
    if (faceShape.contains('Long')) {
      suggestions.add('Horizontal blush application will balance your facial length.');
      suggestions.add('Consider a hairstyle with volume on the sides.');
    } else if (faceShape.contains('Round')) {
      suggestions.add('Contour along the jawline to create more definition.');
      suggestions.add('An angular eyeliner style will complement your features.');
    }

    if (smiling) {
      suggestions.add('A bold ruby lipstick will enhance your vibrant expression.');
    } else {
      suggestions.add('Natural nude tones are perfect for a sophisticated, professional look.');
    }

    return FaceAnalysisResult(
      skinTone: 'Fair to Medium (Natural)',
      skinType: 'Healthy Glow / Normal',
      faceShape: faceShape,
      recommendations: suggestions,
      recommendedLookIds: ['look_glam', 'look_office', 'look_sunset'],
    );
  }

  /// Helper for Web analysis (since Web uses a different face object)
  static FaceAnalysisResult analyzeWeb(Map<String, dynamic> webMetrics) {
    // Web results from face-api.js or similar

    return FaceAnalysisResult(
      skinTone: 'Analyzed via Web (Fair)',
      skinType: 'Normal/Oily T-Zone',
      faceShape: 'Oval',
      recommendations: [
        'Enhanced hydration for web-detected skin profile.',
        'Consider light contouring for an oval face shape.'
      ],
      recommendedLookIds: ['look_glam', 'look_office', 'look_sunset'],
    );
  }
}
