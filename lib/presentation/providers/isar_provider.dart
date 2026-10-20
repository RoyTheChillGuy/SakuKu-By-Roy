import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/isar_service.dart';

part 'isar_provider.g.dart';

/// Ensures the local database layer has been initialized in [main].
@Riverpod(keepAlive: true)
IsarService database(Ref ref) => IsarService.instance;
