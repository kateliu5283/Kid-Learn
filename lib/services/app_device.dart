import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 這台裝置的穩定 id，用來讓同一支手機重登時只換掉自己的 token。
class AppDevice {
  AppDevice._();

  static const storageKey = 'app_device_id_v1';

  static Future<({String id, String label})> identity(
    FlutterSecureStorage storage,
  ) async {
    var id = await storage.read(key: storageKey);
    if (id == null || !RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(id)) {
      id = newId(Random.secure());
      await storage.write(key: storageKey, value: id);
    }
    return (id: id, label: platformLabel());
  }

  static String newId(Random random) {
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static String platformLabel() {
    if (kIsWeb) return 'Web';
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.android => 'Android',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'App',
    };
  }
}
