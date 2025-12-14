import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/pages/home_page.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
// File này sẽ được tạo ra khi chạy flutterfire configure
import 'firebase_options.dart';

void main() async {
  /*
  Cấu hình để sử dụng firebase
  */
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  setPathUrlStrategy();

  // Khởi tạo Firebase với cấu hình từ flutterfire configure
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //run app với Riverpod
  runApp(const ProviderScope(child: GiaPhaApp()));
}

class GiaPhaApp extends ConsumerWidget {
  const GiaPhaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Cập nhật state sau khi build xong để tránh lỗi "setState during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(flatformNotifierProvider.notifier).updateFlatform(screenWidth);
    });

    return MaterialApp(
      navigatorKey: CustomRouter.navigatorKey, // Đăng ký navigatorKey
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
      home: const HomePage(),
    );
  }
}
