import 'package:flutter/foundation.dart';

/// Service để lấy subdomain từ URL
class SubdomainService {
  //Lấy subdomain từ firebase

  /// Lấy subdomain từ URL hiện tại
  /// Ví dụ: nguyendinh.giapha.site → "nguyendinh"
  static String? getSubdomain() {
    if (!kIsWeb) return null;

    try {
      final host = Uri.base.host;

      // Localhost hoặc IP address
      if (host == 'localhost' ||
          host.startsWith('127.') ||
          host.startsWith('192.168.') ||
          host.contains(':')) {
        return null;
      }

      // Tách domain parts
      final parts = host.split('.');

      // Cần ít nhất 3 parts để có subdomain (subdomain.domain.tld)
      if (parts.length < 3) {
        return null;
      }

      // Lấy subdomain (phần đầu tiên)
      final subdomain = parts[0];

      // Loại bỏ các subdomain hệ thống như www
      if (subdomain.toLowerCase() == 'www') {
        return null;
      }

      return subdomain;
    } catch (e) {
      debugPrint('Lỗi khi lấy subdomain: $e');
      return null;
    }
  }

  /// Kiểm tra xem có subdomain không
  static bool hasSubdomain() {
    return getSubdomain() != null;
  }

  /// Lấy full domain (không bao gồm subdomain)
  /// Ví dụ: nguyendinh.giapha.site → "giapha.site"
  static String? getMainDomain() {
    if (!kIsWeb) return null;

    try {
      final host = Uri.base.host;
      final parts = host.split('.');

      if (parts.length < 2) {
        return host;
      }

      // Lấy 2 phần cuối (domain.tld)
      return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
    } catch (e) {
      debugPrint('Lỗi khi lấy main domain: $e');
      return null;
    }
  }

  /// Lấy full host
  static String getFullHost() {
    if (!kIsWeb) return 'localhost';
    return Uri.base.host;
  }

  /// Log thông tin domain để debug
  static void logDomainInfo() {
    debugPrint('=== Domain Info ===');
    debugPrint('Full host: ${getFullHost()}');
    debugPrint('Main domain: ${getMainDomain()}');
    debugPrint('Subdomain: ${getSubdomain()}');
    debugPrint('Has subdomain: ${hasSubdomain()}');
    debugPrint('==================');
  }
}
