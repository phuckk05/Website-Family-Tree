// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subdomain_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasSubdomainHash() => r'fdff37f3a8d192ef262522b17a0b7528bad1456d';

/// Provider kiểm tra có subdomain không
///
/// Copied from [hasSubdomain].
@ProviderFor(hasSubdomain)
final hasSubdomainProvider = AutoDisposeProvider<bool>.internal(
  hasSubdomain,
  name: r'hasSubdomainProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasSubdomainHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasSubdomainRef = AutoDisposeProviderRef<bool>;
String _$mainDomainHash() => r'c309abc9a738da7d37b0de7f78ba7c357bd3893a';

/// Provider lấy main domain
///
/// Copied from [mainDomain].
@ProviderFor(mainDomain)
final mainDomainProvider = AutoDisposeProvider<String?>.internal(
  mainDomain,
  name: r'mainDomainProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mainDomainHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MainDomainRef = AutoDisposeProviderRef<String?>;
String _$fullHostHash() => r'c9c16a8f5d1b5c1929214436d2bdc4d636b8d955';

/// Provider lấy full host
///
/// Copied from [fullHost].
@ProviderFor(fullHost)
final fullHostProvider = AutoDisposeProvider<String>.internal(
  fullHost,
  name: r'fullHostProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fullHostHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FullHostRef = AutoDisposeProviderRef<String>;
String _$subdomainHash() => r'ccb21c098487f6912067fa2eb3f604d10d302b61';

/// Provider để lấy subdomain từ URL
///
/// Copied from [Subdomain].
@ProviderFor(Subdomain)
final subdomainProvider = NotifierProvider<Subdomain, String?>.internal(
  Subdomain.new,
  name: r'subdomainProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$subdomainHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Subdomain = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
