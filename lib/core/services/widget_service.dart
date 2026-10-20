import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Handles `sakuku://scan_receipt` from home-screen widget / deep links.
class WidgetLaunchService {
  WidgetLaunchService._();

  static final WidgetLaunchService instance = WidgetLaunchService._();

  static const scanReceiptUri = 'sakuku://scan_receipt';

  final AppLinks _appLinks = AppLinks();
  final StreamController<void> _scanTriggers = StreamController.broadcast();

  bool _pendingScanReceipt = false;
  bool _initialized = false;

  Stream<void> get scanReceiptTriggers => _scanTriggers.stream;

  bool get hasPendingScanReceipt => _pendingScanReceipt;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;

    try {
      final initial = await _appLinks.getInitialLink();
      _handleUri(initial);
      _appLinks.uriLinkStream.listen(_handleUri);
    } catch (e) {
      debugPrint('WidgetLaunchService init failed: $e');
    }
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;
    if (!_isScanReceiptDeepLink(uri)) return;
    _pendingScanReceipt = true;
    _scanTriggers.add(null);
  }

  bool _isScanReceiptDeepLink(Uri uri) {
    if (uri.scheme != 'sakuku') return false;
    if (uri.host == 'scan_receipt') return true;
    final path = uri.path.replaceFirst('/', '');
    return path == 'scan_receipt';
  }

  /// Returns true once when a scan-receipt launch was queued.
  bool consumePendingScanReceipt() {
    if (!_pendingScanReceipt) return false;
    _pendingScanReceipt = false;
    return true;
  }
}
