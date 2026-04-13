import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../models/makeup_style.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final MakeupStyle? style;
  final String? customStylePath;

  const ProcessingScreen({
    Key? key,
    required this.imagePath,
    this.style,
    this.customStylePath,
  }) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ApiService _apiService;

  String _status = 'Preparing image...';
  double _progress = 0.0;
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _processImage();
  }

  Future<void> _processImage() async {
    try {
      setState(() => _status = 'Uploading image...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _status = 'Analyzing makeup style...');
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _status = 'Applying makeup transfer...';
        _progress = 0.3;
      });

      // Support both preset and custom styles
      final styleId = widget.style?.id ?? 'custom';
      final result = await _apiService.transferMakeup(
        imagePath: widget.imagePath,
        styleId: styleId,
        customStylePath: widget.customStylePath,
      );

      setState(() => _progress = 0.9);

      if (result.success && result.data != null) {
        setState(() => _status = 'Finalizing result...');
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          setState(() => _isProcessing = false);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                result: result.data!,
                originalImagePath: widget.imagePath,
                styleUsed: widget.style,
              ),
            ),
          );
        }
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isProcessing,
      child: Scaffold(
        body: Center(
          child: _isProcessing
              ? _buildProcessingState()
              : _buildErrorState(),
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated circle
        ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.2),
                ],
              ),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Status text
        Text(
          _status,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 24),

        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: _progress,
              backgroundColor: AppTheme.borderColorLight,
              valueColor: AlwaysStoppedAnimation(
                Color.lerp(
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                  _progress,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          '${(_progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 40),

        Text(
          'Processing with AI',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Failed',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred during processing',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
