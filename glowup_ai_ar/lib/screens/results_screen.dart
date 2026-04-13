import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../config/theme.dart';
import '../models/makeup_style.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final TransferResult result;
  final String originalImagePath;
  final MakeupStyle styleUsed;

  const ResultsScreen({
    Key? key,
    required this.result,
    required this.originalImagePath,
    required this.styleUsed,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _showComparison = false;

  Future<void> _shareResult() async {
    try {
      await Share.shareXFiles(
        [XFile(widget.result.resultImagePath)],
        text: 'Check out my makeup transformation with GlowUp!',
      );
    } catch (e) {
      _showSnackBar('Error sharing: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Your Result',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Result Image with comparison
                  _buildImageDisplayCard(),

                  const SizedBox(height: 32),

                  // Stats Card
                  _buildStatsCard(),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplayCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _showComparison
                ? Image.file(
                    File(widget.originalImagePath),
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(widget.result.resultImagePath),
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      setState(() => _showComparison = !_showComparison),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _showComparison
                          ? Icons.image_not_supported_outlined
                          : Icons.image,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _showComparison ? 'Original' : 'Result',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.borderColorLight,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          _buildStatRow(
            'Makeup Style',
            widget.styleUsed.name,
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Processing Time',
            '${widget.result.processingTime.toStringAsFixed(2)}s',
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Quality',
            widget.result.quality.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareResult,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSnackBar('Saved to gallery!');
                },
                icon: const Icon(Icons.download),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Another Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor,
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
