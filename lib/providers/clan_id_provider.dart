import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';

final clanIdProvider = Provider<int>((ref) {
  final clan = ref.watch(clanNotifierProvider);
  return clan.maybeWhen(data: (data) => data.first.id, orElse: () => 0);
});
