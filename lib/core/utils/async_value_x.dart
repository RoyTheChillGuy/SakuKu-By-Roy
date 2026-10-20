import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// Loaded value, or null while loading / on error.
  T? get dataOrNull => asData?.value;
}
