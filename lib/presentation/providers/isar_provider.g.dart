// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ensures the local database layer has been initialized in [main].

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

/// Ensures the local database layer has been initialized in [main].

final class DatabaseProvider
    extends $FunctionalProvider<IsarService, IsarService, IsarService>
    with $Provider<IsarService> {
  /// Ensures the local database layer has been initialized in [main].
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<IsarService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IsarService create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IsarService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IsarService>(value),
    );
  }
}

String _$databaseHash() => r'web_io_database_provider_v1';
