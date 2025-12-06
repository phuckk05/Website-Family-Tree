import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Column(
        children: [
          _buildHeroSection(context),
          _buildOriginSection(context),
          _buildIntroductionSection(context),
          _buildFeatureCards(context),
          const CustomFooter(),
        ],
      ),
    );
  }

  // 1. Hero Banner - Ấn tượng đầu tiên
  Widget _buildHeroSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Trừ đi chiều cao header (ước lượng 60-80px) để banner vừa khít màn hình
    final bannerHeight = screenHeight - 80;

    return SizedBox(
      height:
          bannerHeight > 600 ? bannerHeight : 600, // Tăng chiều cao tối thiểu
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/image.png', // Ưu tiên dùng ảnh thật của bạn
              fit: BoxFit.cover,
              alignment:
                  Alignment.topCenter, // Căn chỉnh để lấy phần trên của cổng
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://images.unsplash.com/photo-1544084944-15a3ad968a75?q=80&w=2070&auto=format&fit=crop',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          // Gradient Overlay - Tinh tế hơn để làm nổi bật chữ
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dòng chữ nhỏ chào mừng
                  Text(
                    'CHÀO MỪNG ĐẾN VỚI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 14,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tiêu đề chính
                  Text(
                    'HỌ NGUYỄN\nTỘC ĐÌNH CHI 5',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: isMobile ? 32 : 56, // Responsive font size
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      height: 1.2,
                      fontFamily: 'PlayfairDisplay',
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 20,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Divider trang trí
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 1,
                        width: isMobile ? 50 : 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primaryGold.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Icon(
                          Icons.star,
                          color: AppColors.primaryGold,
                          size: isMobile ? 14 : 18,
                        ),
                      ),
                      Container(
                        height: 1,
                        width: isMobile ? 50 : 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGold.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Slogan
                  Text(
                    'Nối kết dòng họ • Giữ gìn truyền thống • Gắn kết thế hệ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                      shadows: const [
                        Shadow(blurRadius: 10, color: Colors.black),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  // Nút bấm được thiết kế lại sang trọng hơn
                  OutlinedButton(
                    onPressed: () {
                      CustomRouter.push(const FamilyTreePage());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      side: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 2,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 30 : 50,
                        vertical: isMobile ? 15 : 25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          0,
                        ), // Vuông vức cổ điển
                      ),
                      backgroundColor: Colors.black.withOpacity(
                        0.3,
                      ), // Nền tối nhẹ
                    ),
                    child: Text(
                      'XEM CÂY GIA PHẢ',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Nguồn Gốc Section - Mới thêm
  Widget _buildOriginSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: AppColors.ivoryWhite,
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
                      const SizedBox(height: 40),
                      _buildOriginText(isMobile),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: _buildOriginText(isMobile)),
                      const SizedBox(width: 60),
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
        const Text(
          'NGUỒN GỐC DÒNG HỌ',
          style: TextStyle(
            color: AppColors.woodBrown,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Lịch Sử Hình Thành & Phát Triển',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dòng họ Nguyễn Chi 5 có nguồn gốc từ vùng đất địa linh nhân kiệt... (Nội dung mẫu: Trải qua bao thăng trầm của lịch sử, các bậc tiền nhân đã dày công vun đắp, xây dựng nền móng vững chắc cho con cháu đời sau. Từ những ngày đầu khai hoang lập ấp, dòng họ đã luôn giữ vững nề nếp gia phong, đoàn kết thương yêu nhau.)',
          style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
        const Text(
          'Cây có cội, nước có nguồn. Con người có tổ có tông. Việc tìm về nguồn cội không chỉ là tri ân tổ tiên mà còn là bài học quý báu cho thế hệ trẻ về đạo lý uống nước nhớ nguồn.',
          style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildOriginImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/image.png'), // Ảnh đình làng/cổ kính
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 3. Giới Thiệu Section
  Widget _buildIntroductionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      color: const Color(0xFFF5F5F5), // Màu nền nhẹ khác biệt
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
                      const SizedBox(height: 40),
                      _buildIntroText(isMobile),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(child: _buildIntroImage()),
                      const SizedBox(width: 60),
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
        const Text(
          'GIỚI THIỆU',
          style: TextStyle(
            color: AppColors.woodBrown,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Gia Phả - Báu Vật Tinh Thần',
          style: TextStyle(
            color: Colors.black87,
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Website Gia Phả Họ Nguyễn Chi 5 được xây dựng với mong muốn kết nối tất cả các thành viên trong dòng họ, dù đang sinh sống ở bất cứ nơi đâu. Đây là nơi lưu giữ những thông tin quý giá về phả hệ, tiểu sử các bậc tiền nhân, và cập nhật những tin tức, sự kiện mới nhất của dòng họ.',
          style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 30),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.woodBrown,
            side: const BorderSide(color: AppColors.woodBrown),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: const Text('XEM CHI TIẾT'),
        ),
      ],
    );
  }

  Widget _buildIntroImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage('assets/images/image.png'), // Ảnh sách cũ/gia phả
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 4. Feature Cards
  Widget _buildFeatureCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final cardWidth = isMobile ? screenWidth - 40 : 350.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: AppColors.ivoryWhite,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'KHÁM PHÁ',
                style: TextStyle(
                  color: AppColors.woodBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hoạt Động & Tư Liệu',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 50),
              Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.event,
                    title: 'Sự Kiện Dòng Họ',
                    description:
                        'Cập nhật các ngày giỗ tổ, họp mặt và các sự kiện quan trọng.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=2069&auto=format&fit=crop',
                  ),
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.people,
                    title: 'Thành Viên',
                    description:
                        'Danh sách các thành viên, thông tin liên lạc và đóng góp.',
                    imageUrl:
                        'https://images.unsplash.com/photo-1511895426328-dc8714191300?q=80&w=2070&auto=format&fit=crop',
                  ),
                  _buildCard(
                    width: cardWidth,
                    icon: Icons.photo_library,
                    title: 'Thư Viện Ảnh',
                    description:
                        'Lưu giữ những khoảnh khắc đáng nhớ của đại gia đình.',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primaryGold),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.woodBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primaryGold,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Xem thêm'),
                      SizedBox(width: 5),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
