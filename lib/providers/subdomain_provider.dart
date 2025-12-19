import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:website_gia_pha/services/subdomain_service.dart';

part 'subdomain_provider.g.dart';

/// Provider để lấy subdomain từ URL
@Riverpod(keepAlive: true)
class Subdomain extends _$Subdomain {
  @override
  String? build() {
    final subdomain = SubdomainService.getSubdomain();
    // Log để debug
    SubdomainService.logDomainInfo();
    return subdomain;
  }

  /// Refresh subdomain (nếu cần)
  void refresh() {
    state = SubdomainService.getSubdomain();
  }
}

/// Provider kiểm tra có subdomain không
@riverpod
bool hasSubdomain(HasSubdomainRef ref) {
  final subdomain = ref.watch(subdomainProvider);
  return subdomain != null && subdomain.isNotEmpty;
}

/// Provider lấy main domain
@riverpod
String? mainDomain(MainDomainRef ref) {
  return SubdomainService.getMainDomain();
}

/// Provider lấy full host
@riverpod
String fullHost(FullHostRef ref) {
  return SubdomainService.getFullHost();
}
