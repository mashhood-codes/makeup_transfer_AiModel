class MakeupStyle {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String category;

  MakeupStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
  });

  factory MakeupStyle.fromJson(Map<String, dynamic> json) {
    return MakeupStyle(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      imagePath: json['image_path'] as String? ?? '',
      category: json['category'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image_path': imagePath,
        'category': category,
      };
}

class TransferRequest {
  final String imagePath;
  final String styleId;
  final String? customStylePath;

  TransferRequest({
    required this.imagePath,
    required this.styleId,
    this.customStylePath,
  });

  Map<String, dynamic> toJson() => {
        'image_path': imagePath,
        'style_id': styleId,
        'custom_style_path': customStylePath,
      };
}

class TransferResult {
  final bool success;
  final String resultImagePath;
  final double processingTime;
  final String quality;
  final String message;

  TransferResult({
    required this.success,
    required this.resultImagePath,
    required this.processingTime,
    required this.quality,
    required this.message,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      success: json['success'] as bool? ?? false,
      resultImagePath: json['result_path'] as String? ?? '',
      processingTime: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
      quality: json['quality'] as String? ?? 'high',
      message: json['message'] as String? ?? '',
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });
}
