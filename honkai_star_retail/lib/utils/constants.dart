import 'package:flutter/material.dart';

class AppConstants {
  // ==========================================
  // API CONFIGURATION
  // ==========================================
  // Jika pakai Emulator Android: http://10.0.2.2:3000
  // Jika pakai HP Asli: http://IP_LAPTOP_KAMU:3000
//   static const String baseUrl = 'http://10.0.2.2:3000/api'; BUAT ANDRO EMULATOR (ANDROID STUDIO)
// http://IP_LAPTOP_KAMU:3000 BUAT HP FISIK
  static const String baseUrl = 'http://localhost:3000/api';

  // ==========================================
  // UI DESIGN CUSTOMIZATION (Requirement)
  // Memenuhi syarat merubah 2-4 properti tema
  // ==========================================
  
  // 1. Properti Warna (Background & Tint)
  static const Color primaryColor = Color(0xFF0066FF); // Biru Khas Honkai
  static const Color backgroundColor = Color(0xFF0B0E11); // Dark Theme
  static const Color cardColor = Color(0xFF1C1F26);
  static const Color accentColor = Color(0xFF64B5F6);

  // 2. Properti Font Family & Size
  static const String fontMain = 'Inter'; // Pastikan sudah daftar di pubspec
  static const double fontSizeTitle = 22.0;
  static const double fontSizeBody = 14.0;

  // 3. Spacing & Alpha/Opacity
  static const double defaultPadding = 16.0;
  static const double overlayAlpha = 0.7;
}