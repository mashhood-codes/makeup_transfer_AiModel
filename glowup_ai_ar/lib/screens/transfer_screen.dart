import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../services/makeup_api.dart';
import '../services/api_config.dart';
import '../services/secure_auth_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final MakeupAPI _api = MakeupAPI();
  final ImagePicker _picker = ImagePicker();

  File? _sourceImage;
  File? _styleImage;
  String? _resultImageUrl;
  bool _isProcessing = false;
  String? _selectedStyle;
  bool _serverConnected = false;
  List<Map<String, String>> _apiStyles = [];
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await ApiConfig.initialize();
    _checkServer();
    _loadStyles();
    final user = await SecureAuthService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _loadStyles() async {
    try {
      print('📥 Loading styles from API at: ${ApiConfig.baseUrl}');
      final styles = await _api.getStyles();
      print('✅ Styles loaded: ${styles.length} styles');
      setState(() => _apiStyles = styles);
    } catch (e) {
      print('❌ Error loading styles: $e');
      setState(() => _apiStyles = []);
    }
  }

  Future<Uint8List> _loadStyleImage(String thumbnailPath) async {
    try {
      final url = '${ApiConfig.baseUrl}$thumbnailPath';
      print('🖼️ Fetching style image from: $url');

      final response = await _api.dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('✅ Style image fetched');
        return Uint8List.fromList(response.data!);
      }
      throw Exception('Failed to fetch: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching style image: $e');
      rethrow;
    }
  }

  Future<void> _checkServer() async {
    final connected = await _api.checkHealth();
    setState(() => _serverConnected = connected);
    if (!connected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using fallback server: ${ApiConfig.baseUrl}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await SecureAuthService.logout();
    if (mounted) {
      context.go('/splash');
    }
  }

  Future<void> _pickSourceImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _sourceImage = File(image.path));
    }
  }

  Future<void> _pickStyleImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _styleImage = File(image.path);
        _selectedStyle = null;
      });
    }
  }

  Future<void> _applyMakeup() async {
    if (_sourceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select image first')),
      );
      return;
    }

    if (_selectedStyle == null && _styleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select style')),
      );
      return;
    }

    print('👉 User tapped APPLY MAKEUP');
    print('   - Server: ${ApiConfig.baseUrl}');
    print('   - Selected Style: $_selectedStyle');
    print('   - Custom Style: ${_styleImage?.path ?? "None"}');

    setState(() => _isProcessing = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing... Please wait 10-30 seconds')),
    );

    try {
      final styleId = _selectedStyle ?? 'custom';
      print('🚀 Calling transferMakeup with styleId: $styleId');

      final resultUrl = await _api.transferMakeup(_sourceImage!, styleId, customStyleFile: _styleImage);

      print('✅ Transfer complete!');
      print('   - Result URL: $resultUrl');

      setState(() {
        _resultImageUrl = resultUrl;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transfer complete! ✨')),
      );
    } catch (e) {
      print('❌ Transfer error: $e');
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Glowup AI',
          style: TextStyle(
            color: Color(0xFF2D1B4E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Tooltip(
                message: 'Server: ${ApiConfig.baseUrl}',
                child: Text(
                  _serverConnected ? 'Online' : 'Fallback',
                  style: TextStyle(
                    color: _serverConnected ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Profile'),
                onTap: () => print('Profile: $_currentUser'),
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              'Your Photo',
              _sourceImage,
              _pickSourceImage,
              Icons.photo_library,
            ),
            const SizedBox(height: 24),
            _buildStyleSelector(),
            const SizedBox(height: 24),
            _buildApplyButton(),
            const SizedBox(height: 24),
            if (_resultImageUrl != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, File? image, VoidCallback onTap, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1B4E),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8D5C4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D1B4E).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48, color: const Color(0xFFC97A7A)),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to select',
                        style: TextStyle(color: Color(0xFF858585), fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Makeup Styles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1B4E),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _apiStyles.length + 1,
          itemBuilder: (context, index) {
            if (index < _apiStyles.length) {
              final style = _apiStyles[index];
              final isSelected = _selectedStyle == style['id'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedStyle = style['id'];
                  _styleImage = null;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC97A7A) : const Color(0xFFE8D5C4),
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFC97A7A).withOpacity(0.3), blurRadius: 8)]
                        : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: FutureBuilder<Uint8List>(
                      future: _loadStyleImage(style['thumbnail']!),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      },
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: _pickStyleImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8D5C4), width: 2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 40, color: Color(0xFFC97A7A)),
                      SizedBox(height: 8),
                      Text('Custom', style: TextStyle(color: Color(0xFF2D1B4E), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        if (_styleImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_styleImage!, height: 120, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _applyMakeup,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC97A7A), Color(0xFFE1A4A4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC97A7A).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _isProcessing
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              )
            : const Center(
                child: Text(
                  'Apply Makeup',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
      ),
    );
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Result',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D1B4E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D1B4E).withOpacity(0.15),
                blurRadius: 15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              _resultImageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loading) {
                if (loading == null) return child;
                return Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 64),
                      SizedBox(height: 16),
                      Text('Failed to load result'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

}
