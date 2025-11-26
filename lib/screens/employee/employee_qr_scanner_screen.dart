import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/task_model.dart';
import '../../services/api_service.dart';
import '../../services/sync_service.dart';
import '../../config/theme.dart';

class EmployeeQrScannerScreen extends StatefulWidget {
  const EmployeeQrScannerScreen({super.key});

  @override
  State<EmployeeQrScannerScreen> createState() => _EmployeeQrScannerScreenState();
}

class _EmployeeQrScannerScreenState extends State<EmployeeQrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScanned;
  int? _scannedChildId;
  String? _scannedChildName;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null || code == _lastScanned) return;

    setState(() {
      _isProcessing = true;
      _lastScanned = code;
    });

    // Parse QR code: CHILD:userId:email
    if (code.startsWith('CHILD:')) {
      final parts = code.split(':');
      if (parts.length >= 3) {
        final childId = int.tryParse(parts[1]);
        final childEmail = parts[2];
        
        if (childId != null) {
          // Fetch child details
          final apiService = context.read<ApiService>();
          final users = await apiService.getUsers(role: 'child');
          final child = users.firstWhere((u) => u.id == childId, orElse: () => users.first);
          
          setState(() {
            _scannedChildId = childId;
            _scannedChildName = child.name;
          });
          
          // Show task selection dialog
          if (mounted) {
            await _showTaskSelectionDialog(childId, child.name);
          }
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Neplatný QR kód dieťaťa'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastScanned = null;
        _scannedChildId = null;
        _scannedChildName = null;
      });
    }
  }

  Future<void> _showTaskSelectionDialog(int childId, String childName) async {
    // Load tasks
    final apiService = context.read<ApiService>();
    final tasks = await apiService.getTasks();
    
    if (tasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Žiadne dostupné úlohy')),
        );
      }
      return;
    }

    if (!mounted) return;

    final selectedTask = await showModalBottomSheet<TaskModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.successColor,
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vyber úlohu',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pre: $childName',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Tasks list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(task.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${task.points} bodov'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.pop(context, task),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (selectedTask != null && mounted) {
      await _giveStamp(childId, selectedTask, childName);
    }
  }

  Future<void> _giveStamp(int childId, TaskModel task, String childName) async {
    final apiService = context.read<ApiService>();
    final success = await apiService.giveStamp(childId, task.id);

    if (mounted) {
      if (success) {
        await context.read<SyncService>().syncAll();
        
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text(
                  'Úspech!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Pečiatka pridaná pre $childName'),
                const SizedBox(height: 8),
                Text(
                  '${task.title} (+${task.points} bodov)',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chyba pri pridávaní pečiatky'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web fallback
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Skenovať QR Dieťaťa'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 100,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'QR Skener na Webe',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '📱 QR skener funguje len na mobilných zariadeniach',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Na PC použite "Pridať Pečiatku" v Employee dashboarde',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Späť'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mobile scanner
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Skenovať QR Dieťaťa'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcodeDetected,
          ),
          
          // Scanning overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          
          // Instructions
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Spracovávam...',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        const Icon(Icons.qr_code_2, size: 48, color: AppTheme.primaryColor),
                        const SizedBox(height: 12),
                        const Text(
                          'Naskenuj QR kód dieťaťa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dieťa ti ukáže svoj osobný QR kód',
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ).animate()
              .fadeIn()
              .slideY(begin: 0.2, end: 0),
          ),
        ],
      ),
    );
  }
}

// Scanner overlay painter
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corners
    final cornerPaint = Paint()
      ..color = AppTheme.successColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}







