import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:website_gia_pha/core/router/admin_router.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/subdomain_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy(); // Remove # from URL

  // Khởi tạo Firebase với cấu hình đã hardcode
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //run app với Riverpod
  runApp(const ProviderScope(child: GiaPhaApp()));
}

class GiaPhaApp extends ConsumerWidget {
  const GiaPhaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy subdomain
    final subdomain = ref.watch(subdomainProvider);
    // subdomain = "nguyendinh" từ nguyendinh.giapha.site

    // Kiểm tra có subdomain không
    final hasSubdomain = ref.watch(hasSubdomainProvider);

    // Lấy main domain
    final mainDomain = ref.watch(mainDomainProvider);
    // mainDomain = "giapha.site"

    // Lấy full host
    final fullHost = ref.watch(fullHostProvider);
    // fullHost = "nguyendinh.giapha.site"

    debugPrint('Subdomain: $subdomain');
    debugPrint('Has Subdomain: $hasSubdomain');
    debugPrint('Main Domain: $mainDomain');
    debugPrint('Full Host: $fullHost');

    //Kiểm tra subdomain để phân luồng giao diện
    if (hasSubdomain) {
      if (subdomain == 'admin') {
        return MaterialApp.router(
          routerConfig: AppAdminRouter.adminRouter,
          title: 'Admin',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGold,
              // primary: AppColors.primaryGold,
              secondary: AppColors.woodBrown,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.ivoryWhite,
          ),
          builder: (context, child) {
            // Update platform state based on screen width
            final screenWidth = MediaQuery.of(context).size.width;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(flatformNotifierProvider.notifier)
                  .updateFlatform(screenWidth);
            });
            return child!;
          },
        );
      } else {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          title: 'Gia Phả Họ Nguyễn Đình - Chi 5',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGold,
              // primary: AppColors.primaryGold,
              secondary: AppColors.woodBrown,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.ivoryWhite,
          ),
          builder: (context, child) {
            // Update platform state based on screen width
            final screenWidth = MediaQuery.of(context).size.width;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(flatformNotifierProvider.notifier)
                  .updateFlatform(screenWidth);
            });
            return child!;
          },
        );
      }
    } else {
      return MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'Gia Phả Họ Nguyễn Đình - Chi 5',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGold,
            // primary: AppColors.primaryGold,
            secondary: AppColors.woodBrown,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.ivoryWhite,
        ),
        builder: (context, child) {
          // Update platform state based on screen width
          final screenWidth = MediaQuery.of(context).size.width;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(flatformNotifierProvider.notifier)
                .updateFlatform(screenWidth);
          });
          return child!;
        },
      );
    }
  }
}
