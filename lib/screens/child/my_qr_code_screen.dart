import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class MyQrCodeScreen extends StatelessWidget {
  const MyQrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Môj QR Kód')),
        body: const Center(child: Text('Nie si prihlásený')),
      );
    }

    // Generate unique QR code data for the child
    final qrData = 'CHILD:${user.id}:${user.email}';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Môj QR Kód',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎿',
                        style: TextStyle(fontSize: 60),
                      ).animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        user.name,
                        style: AppTheme.headingMedium,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        user.email,
                        style: AppTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(),
                
                const SizedBox(height: 40),
                
                // QR Code card
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 280,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.primaryColor,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: AppTheme.textPrimary,
                        ),
                      ).animate()
                        .scale(delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut)
                        .then()
                        .shimmer(duration: 2000.ms),
                      
                      const SizedBox(height: 24),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.qr_code, color: AppTheme.infoColor, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Toto je tvoj osobný QR kód',
                                style: TextStyle(
                                  color: AppTheme.infoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn().scale(),
                
                const SizedBox(height: 40),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '📱 Ako použiť?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildInstructionStep(
                        number: '1',
                        icon: Icons.qr_code_2,
                        title: 'Ukáž QR kód',
                        description: 'Keď splníš úlohu, ukáž tento QR kód zamestnancovi',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildInstructionStep(
                        number: '2',
                        icon: Icons.photo_camera,
                        title: 'Zamestnanec naskenuje',
                        description: 'Zamestnanec naskenuje tvoj QR kód svojím zariadením',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildInstructionStep(
                        number: '3',
                        icon: Icons.check_circle,
                        title: 'Získaš pečiatku!',
                        description: 'Pečiatka sa ti automaticky pridá do tvojho pasu',
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 40),
                
                // Tips
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.successColor, size: 32),
                      SizedBox(height: 12),
                      Text(
                        'Tipy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.successColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Zvýš jas obrazovky pre lepšie skenovanie\n'
                        '• QR kód funguje aj bez internetu\n'
                        '• Jeden QR kód pre všetky úlohy',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.bodyMedium.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}







