import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/pages/family_tree_page.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/custom_footer.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildStatsSection(context),
            _buildOriginSection(context),
            _buildTimelineSection(context),
            _buildIntroductionSection(context),
            _buildFeatureCards(context),
            _buildCallToActionSection(context),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  // 1. HERO SECTION - Nâng cấp với animation
  Widget _buildHeroSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final bannerHeight = screenHeight - 80;

    return Stack(
      children: [
        SizedBox(
          height: bannerHeight > 600 ? bannerHeight : 600,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background-pc.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: bannerHeight > 600 ? bannerHeight : 600,
          width: double.infinity,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 40 : 60,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.7),
                  width: 2,
                ),
                color: Colors.black.withOpacity(0.25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'CHÀO MỪNG ĐẾN VỚI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isMobile ? 12 : 14,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'HỌ NGUYỄN ĐÌNH\nCHI 5',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: isMobile ? 36 : 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        height: 1.15,
                        fontFamily: 'PlayfairDisplay',
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 6),
                            blurRadius: 25,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1400),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 2,
                          width: isMobile ? 40 : 100,
                          color: AppColors.primaryGold.withOpacity(0.9),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Icon(
                            Icons.spa,
                            color: AppColors.primaryGold,
                            size: isMobile ? 18 : 28,
                          ),
                        ),
                        Container(
                          height: 2,
                          width: isMobile ? 40 : 100,
                          color: AppColors.primaryGold.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Nối kết dòng họ • Giữ gìn truyền thống • Gắn kết thế hệ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                      shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      CustomRouter.push(const FamilyTreePage());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 35 : 60,
                        vertical: isMobile ? 18 : 28,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryGold,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        'XEM CÂY GIA PHẢ',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. STATS SECTION - MỚI
  Widget _buildStatsSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final stats = [
      {'number': '600+', 'label': 'Thành Viên'},
      {'number': '25', 'label': 'Thế Hệ'},
      {'number': '500+', 'label': 'Năm Lịch Sử'},
    ];

    return Container(
      color: const Color(0xFF1E1E1E), // Matte Black Lighter
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child:
              isMobile
                  ? Column(
                    children:
                        stats
                            .map(
                              (stat) => Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: _buildStatItem(stat),
                              ),
                            )
                            .toList(),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        stats.map((stat) => _buildStatItem(stat)).toList(),
                  ),
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, String> stat) {
    return Column(
      children: [
        Text(
          stat['number']!,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          stat['label']!,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // 3. ORIGIN SECTION
  Widget _buildOriginSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFF121212), // Matte Black Darker
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child:
              isMobile
                  ? Column(
                    children: [
                      _buildOriginImage(),
                      const SizedBox(height: 50),
                      _buildOriginText(isMobile),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: _buildOriginText(isMobile)),
                      const SizedBox(width: 80),
                      Expanded(child: _buildOriginImage()),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildOriginText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NGUỒN GỐC',
          style: TextStyle(
            color: AppColors.primaryGold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Lịch Sử & Truyền Thống',
          style: TextStyle(
            color: Colors.white, // White text
            fontSize: isMobile ? 28 : 42,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 4, width: 50, color: AppColors.primaryGold),
        const SizedBox(height: 25),
        const Text(
          'Nguyễn Xí (1397-1465) - Thái sư Cương quốc công, là thủy tổ của dòng họ Nguyễn Đình. Ông có công lao to lớn trong khởi nghĩa Lam Sơn, tham gia đánh đuổi giặc Minh, giành lại độc lập cho dân tộc.',
          style: TextStyle(
            color: Colors.white70, // Light grey text
            fontSize: 16,
            height: 1.7,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
        const Text(
          '"Cây có cội, nước có nguồn. Con người có tổ có tông."',
          style: TextStyle(
            color: AppColors.primaryGold, // Gold text
            fontSize: 15,
            height: 1.7,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOriginImage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 35,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/image.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  // 4. TIMELINE SECTION - MỚI
  Widget _buildTimelineSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFF1E1E1E), // Matte Black Lighter
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'DÒNG THỜI GIAN',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Các Mốc Lịch Sử Quan Trọng',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 50),
              isMobile ? _buildTimelineMobile() : _buildTimelineDesktop(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineDesktop() {
    final events = [
      {'year': '1397', 'event': 'Nguyễn Xí sinh ra'},
      {'year': '1427', 'event': 'Tham gia Lam Sơn'},
      {'year': '1465', 'event': 'Phong Thái sư'},
      {'year': '2024', 'event': 'Website Gia Phả'},
    ];

    return Row(
      children: List.generate(
        events.length,
        (index) => Expanded(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 3),
                  color: Colors.black, // Dark circle
                ),
                child: Center(
                  child: Text(
                    events[index]['year']!,
                    style: const TextStyle(
                      color: AppColors.primaryGold, // Gold text
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                events[index]['event']!,
                style: const TextStyle(
                  color: Colors.white70, // Light grey text
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineMobile() {
    final events = [
      {'year': '1397', 'event': 'Nguyễn Xí sinh ra'},
      {'year': '1427', 'event': 'Tham gia Lam Sơn'},
      {'year': '1465', 'event': 'Phong Thái sư'},
      {'year': '2024', 'event': 'Website Gia Phả'},
    ];

    return Column(
      children: List.generate(
        events.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  color: Colors.black, // Dark circle
                ),
                child: Center(
                  child: Text(
                    events[index]['year']!.substring(2),
                    style: const TextStyle(
                      color: AppColors.primaryGold, // Gold text
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      events[index]['year']!,
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      events[index]['event']!,
                      style: const TextStyle(
                        color: Colors.white70, // Light grey text
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. INTRODUCTION SECTION
  Widget _buildIntroductionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFF121212), // Matte Black Darker
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child:
              isMobile
                  ? Column(
                    children: [
                      _buildIntroImage(),
                      const SizedBox(height: 50),
                      _buildIntroText(isMobile),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: _buildIntroImage()),
                      const SizedBox(width: 80),
                      Expanded(child: _buildIntroText(isMobile)),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildIntroText(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VỀ WEBSITE',
          style: TextStyle(
            color: AppColors.primaryGold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Kết Nối & Giữ Gìn Truyền Thống',
          style: TextStyle(
            color: Colors.white, // White text
            fontSize: isMobile ? 28 : 42,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 20),
        Container(height: 4, width: 50, color: AppColors.primaryGold),
        const SizedBox(height: 25),
        const Text(
          'Website Gia Phả Họ Nguyễn Đình - Chi 5 được xây dựng để kết nối các thành viên dòng họ, lưu giữ thông tin quý giá về phả hệ và tiểu sử các bậc tiền nhân.',
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.7),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryGold,
                width: 2,
              ), // Gold border
            ),
            child: const Text(
              'XEM CHI TIẾT',
              style: TextStyle(
                color: AppColors.primaryGold, // Gold text
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroImage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/image.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  // 6. FEATURE CARDS
  Widget _buildFeatureCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth - 40 : 360.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF1E1E1E), // Matte Black Lighter
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'KHÁM PHÁ',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hoạt Động & Tư Liệu',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 60),
              Wrap(
                spacing: 35,
                runSpacing: 35,
                alignment: WrapAlignment.center,
                children: [
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.event,
                    title: 'Sự Kiện',
                    description:
                        'Cập nhật các ngày giỗ tổ và sự kiện quan trọng.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2069&auto=format&fit=crop',
                  ),
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.people,
                    title: 'Thành Viên',
                    description: 'Danh sách thành viên và thông tin liên lạc.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1511895426328-dc8714191300?q=80&w=2070&auto=format&fit=crop',
                  ),
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.photo_library,
                    title: 'Thư Viện',
                    description: 'Lưu giữ những khoảnh khắc của đại gia đình.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1509909756405-be0199881695?q=80&w=2070&auto=format&fit=crop',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required double width,
    required IconData icon,
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Dark card background
        borderRadius: BorderRadius.circular(20), // Rounded card
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ), // Rounded top image
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black, // Dark icon background
                        border: Border.all(
                          color: AppColors.primaryGold,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primaryGold,
                        size: 22,
                      ), // Gold icon
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold, // Gold title
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70, // Light grey description
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'CHI TIẾT',
                          style: TextStyle(
                            color: AppColors.primaryGold, // Gold button text
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primaryGold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. CALL TO ACTION SECTION
  Widget _buildCallToActionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFF121212), // Matte Black Darker
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
        horizontal: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                'Bạn là thành viên Họ Nguyễn Đình?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Hãy đăng ký để cập nhật thông tin gia phả và kết nối với các thành viên khác',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 16 : 18,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 35 : 55,
                    vertical: isMobile ? 16 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(30), // Rounded button
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'ĐĂNG KÝ NGAY',
                    style: TextStyle(
                      color: AppColors.woodBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
