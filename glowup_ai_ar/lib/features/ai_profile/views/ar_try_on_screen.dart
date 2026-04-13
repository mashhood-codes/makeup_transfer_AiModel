import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'web_ar_view.dart';
import '../../../core/ar/ar_engine.dart';
import '../../../core/ar/ar_filter_constants.dart';
import '../../../core/ar/face_analyzer.dart';

class ARTryOnScreen extends StatefulWidget {
  const ARTryOnScreen({super.key});

  @override
  State<ARTryOnScreen> createState() => _ARTryOnScreenState();
}

class _ARTryOnScreenState extends State<ARTryOnScreen> {
  CameraController? _cameraController;
  late final FaceDetector _faceDetector;
  bool _isDetecting = false;
  List<Face> _faces = [];
  Size? _imageSize;
  
  ARFilter _selectedFilter = ARFilterConstants.filters.first;
  int _currentLookIndex = 0;
  bool _isScanningPulse = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
          performanceMode: FaceDetectorMode.fast,
        ),
      );
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {});

      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting) return;
        _isDetecting = true;
        _processImage(image);
      });
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        setState(() {
          _faces = faces;
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        });
      }
    } catch (e) {
      // Ignored
    } finally {
      if (mounted) _isDetecting = false;
    }
  }

  void _onFilterSelected(ARFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _showAnalysis() async {
    if (_faces.isEmpty && !kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No face detected to scan!')));
      return;
    }

    setState(() => _isScanningPulse = true);
    final pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) setState(() {});
    });
    await Future.delayed(const Duration(seconds: 2));
    pulseTimer.cancel();
    if (!mounted) return;
    setState(() => _isScanningPulse = false);

    final result = kIsWeb 
        ? FaceAnalyzer.analyzeWeb({}) 
        : FaceAnalyzer.analyze(_faces.first);

    setState(() {
      _currentLookIndex = 0;
      // Auto-apply first look
      final lookId = result.recommendedLookIds.first;
      _selectedFilter = ARFilterConstants.filters.firstWhere((f) => f.id == lookId);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.pinkAccent),
                    SizedBox(width: 12),
                    Text('AI BEAUTY SCAN RESULTS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildResultRow('Face Shape', result.faceShape),
                _buildResultRow('Skin Type', result.skinType),
                _buildResultRow('Skin Tone', result.skinTone),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white10),
                ),
                const Text('APPLIED PROFESSIONAL LOOK', style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Text(_selectedFilter.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Text(_selectedFilter.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.check_circle, color: Colors.greenAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _currentLookIndex = (_currentLookIndex + 1) % result.recommendedLookIds.length;
                      final lookId = result.recommendedLookIds[_currentLookIndex];
                      setState(() {
                        _selectedFilter = ARFilterConstants.filters.firstWhere((f) => f.id == lookId);
                      });
                      setModalState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('TRY NEXT PROFESSIONAL LOOK'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('GOT IT'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _cameraController?.dispose();
      _faceDetector.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PRO AI TRY-ON', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.flip_camera_ios), onPressed: () {}),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb ? WebARTryOnView(selectedFilterId: _selectedFilter.id) : _buildMobileCamera(),
          _buildOverlayControls(),
        ],
      ),
    );
  }

  Widget _buildMobileCamera() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        if (_faces.isNotEmpty && _imageSize != null)
          Positioned.fill(
            child: CustomPaint(
              painter: FaceOverlayPainter(
                faces: _faces,
                imageSize: _imageSize!,
                filter: _selectedFilter,
                isScanning: _isScanningPulse,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: FloatingActionButton.extended(
            onPressed: _showAnalysis,
            backgroundColor: Colors.pinkAccent,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('SCAN FACE'),
          ),
        ),
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: ARFilterConstants.filters.length,
            itemBuilder: (context, index) {
              final filter = ARFilterConstants.filters[index];
              final isSelected = _selectedFilter.id == filter.id;
              return GestureDetector(
                onTap: () => _onFilterSelected(filter),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? Colors.pinkAccent : Colors.white24, width: 3),
                    color: Colors.black26,
                  ),
                  child: Center(
                    child: Text(filter.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final ARFilter filter;
  final bool isScanning;

  FaceOverlayPainter({required this.faces, required this.imageSize, required this.filter, this.isScanning = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty && !isScanning) return;

    if (isScanning) {
      _drawScanningPulse(canvas, size);
      return;
    }

    final scaleX = size.width / imageSize.height;
    final scaleY = size.height / imageSize.width;

    for (final face in faces) {
      if (filter.type == FilterType.look && filter.composition != null) {
        final comp = filter.composition!;
        if (comp.containsKey('lips')) {
          _drawLipstick(canvas, size, face, scaleX, scaleY, comp['lips']!);
        }
        if (comp.containsKey('liner')) {
          _drawEyeliner(canvas, size, face, scaleX, scaleY);
        }
        if (comp.containsKey('blush')) {
          _drawBlush(canvas, size, face, scaleX, scaleY, comp['blush']!);
        }
        if (comp.containsKey('hair')) {
          _drawHairTint(canvas, size, face, scaleX, scaleY, comp['hair']!);
        }
      } else {
        if (filter.id == 'classic_red' || filter.id == 'nude_glow' || filter.id == 'pink_blush') {
          _drawLipstick(canvas, size, face, scaleX, scaleY, filter.primaryColor ?? Colors.red);
        }
        
        if (filter.id == 'winged_eyes' || filter.id == 'classic_red') {
          _drawEyeliner(canvas, size, face, scaleX, scaleY);
        }

        if (filter.id == 'pink_blush' || filter.id == 'nude_glow') {
          _drawBlush(canvas, size, face, scaleX, scaleY, filter.primaryColor ?? Colors.pinkAccent);
        }
        
        if (filter.id.contains('hair')) {
          _drawHairTint(canvas, size, face, scaleX, scaleY, filter.primaryColor ?? Colors.transparent);
        }
      }
    }
  }

  void _drawScanningPulse(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final y = (DateTime.now().millisecondsSinceEpoch % 2000) / 2000 * size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    
    final rectPaint = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.05);
    canvas.drawRect(Rect.fromLTWH(0, y - 20, size.width, 40), rectPaint);
  }

  void _drawHairTint(Canvas canvas, Size size, Face face, double scaleX, double scaleY, Color color) {
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour != null) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        
        // Mock hair region above forehead
        final p1 = faceContour.points[0];
        final centerX = size.width - p1.y * scaleX;
        final centerY = p1.x * scaleY - 50;
        canvas.drawCircle(Offset(centerX, centerY), 80, paint);
    }
  }

  void _drawLipstick(Canvas canvas, Size size, Face face, double scaleX, double scaleY, Color color) {
    final lipsBottom = face.contours[FaceContourType.lowerLipBottom];
    final lipsTop = face.contours[FaceContourType.upperLipTop];
    if (lipsBottom != null && lipsTop != null) {
      final path = Path();
      for (var i = 0; i < lipsTop.points.length; i++) {
        final p = lipsTop.points[i];
        final x = p.y * scaleX;
        final y = p.x * scaleY;
        if (i == 0) {
          path.moveTo(size.width - x, y);
        } else {
          path.lineTo(size.width - x, y);
        }
      }
      for (var i = lipsBottom.points.length - 1; i >= 0; i--) {
        final p = lipsBottom.points[i];
        final x = p.y * scaleX;
        final y = p.x * scaleY;
        path.lineTo(size.width - x, y);
      }
      path.close();
      ARMakeupEngine.drawLipstick(canvas, path, color, 0.4);
    }
  }

  void _drawEyeliner(Canvas canvas, Size size, Face face, double scaleX, double scaleY) {
    final leftEye = face.contours[FaceContourType.leftEye];
    final rightEye = face.contours[FaceContourType.rightEye];
    
    if (leftEye != null) {
      final p = Path();
      p.moveTo(size.width - leftEye.points[0].y * scaleX, leftEye.points[0].x * scaleY);
      for (var pt in leftEye.points) {
        p.lineTo(size.width - pt.y * scaleX, pt.x * scaleY);
      }
      ARMakeupEngine.drawEyeliner(canvas, p, Colors.black, 0.6);
    }
    if (rightEye != null) {
      final p = Path();
      p.moveTo(size.width - rightEye.points[0].y * scaleX, rightEye.points[0].x * scaleY);
      for (var pt in rightEye.points) {
        p.lineTo(size.width - pt.y * scaleX, pt.x * scaleY);
      }
      ARMakeupEngine.drawEyeliner(canvas, p, Colors.black, 0.6);
    }
  }

  void _drawBlush(Canvas canvas, Size size, Face face, double scaleX, double scaleY, Color color) {
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour != null && faceContour.points.length > 20) {
      // Mock cheek centers based on face contour
      final leftCheek = Offset(size.width - faceContour.points[8].y * scaleX, faceContour.points[8].x * scaleY);
      final rightCheek = Offset(size.width - faceContour.points[28].y * scaleX, faceContour.points[28].x * scaleY);
      ARMakeupEngine.drawBlush(canvas, leftCheek, 40, color, 0.3);
      ARMakeupEngine.drawBlush(canvas, rightCheek, 40, color, 0.3);
    }
  }

  @override
  bool shouldRepaint(FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces || oldDelegate.filter != filter || oldDelegate.isScanning != isScanning;
  }
}
