import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/sync_service.dart';
import '../../config/theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScanned;

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

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.validateQrCodeAsync(
        code,
        authProvider.currentUser!.id,
      );

      if (mounted) {
        if (response['success'] == true) {
          // Sync stamps
          await context.read<SyncService>().syncAll();
          
          // Show success with confetti-like message
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text(
                    'Úspech!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Získal si pečiatku!',
                    style: AppTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                  child: const Text('Super!'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] as String? ?? 'Neplatný QR kód'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastScanned = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web fallback - camera doesn't work on web
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Skenovať QR Kód'),
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📱 QR skener funguje len na mobilných zariadeniach',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Pre skaenovanie QR kódov použite mobilnú aplikáciu na iOS alebo Android zariadení.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Na PC použite "Pridať Pečiatku" v Employee dashboarde',
                                  style: TextStyle(fontSize: 12, color: AppTheme.infoColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Späť na Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mobile scanner for iOS/Android
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Skenovať QR Kód'),
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
          
          // Overlay with instructions
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
                  const Icon(Icons.qr_code_scanner, size: 48, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Nasmeruj kameru na QR kód',
                    style: AppTheme.headingSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
          
          // Flash toggle
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                    color: Colors.white,
                    size: 32,
                  );
                },
              ),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),
        ],
      ),
    );
  }
}

