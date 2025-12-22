import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/clan.dart';
import 'package:website_gia_pha/services/clan_service.dart';
import 'package:website_gia_pha/services/subdomain_service.dart';

class ClanNotifier extends StreamNotifier<Set<Clan>> {
  @override
  Stream<Set<Clan>> build() {
    final clanService = ref.read(clanServiceProvider);
    final subdomain = SubdomainService.getSubdomain();

    if (subdomain != null && subdomain.isNotEmpty && subdomain != 'admin') {
      return clanService
          .getClansBySubdomain(subdomain)
          .map((list) => list.toSet());
    }

    return clanService.getClansStream().map((list) => list.toSet());
  }

  Future<bool> addClan(Clan clan) async {
    try {
      await ref.read(clanServiceProvider).addClan(clan);
      return true;
    } catch (e) {
      debugPrint('Lỗi addClan: $e');
      return false;
    }
  }

  Future<bool> updateClan(int clanId, Clan clan) async {
    try {
      await ref.read(clanServiceProvider).updateClan(clanId, clan);
      return true;
    } catch (e) {
      debugPrint('Lỗi updateClan: $e');
      return false;
    }
  }

  Future<bool> deleteClan(Clan clan) async {
    try {
      await ref.read(clanServiceProvider).deleteClan(clan.id);
      return true;
    } catch (e) {
      debugPrint('Lỗi deleteClan: $e');
      return false;
    }
  }
}

final clanNotifierProvider = StreamNotifierProvider<ClanNotifier, Set<Clan>>(
  ClanNotifier.new,
);
