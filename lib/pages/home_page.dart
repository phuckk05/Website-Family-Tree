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
          _buildBanner(context),
          _buildIntroduction(context),
          _buildCategories(context),
          _buildEventsTimeline(context),
          const CustomFooter(),
        ],
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SizedBox(
      height: 500,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background-pc.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: AppColors.woodBrown);
              },
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'HỌ NGUYỄN – TỘC ĐÌNH CHI 5',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nối kết dòng họ • Giữ gìn truyền thống • Gắn kết thế hệ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      CustomRouter.push(const FamilyTreePage());
                    },
                    child: const Text(
                      'Xem cây gia phả',
                      style: TextStyle(
                        color: AppColors.woodBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildIntroduction(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child:
          isDesktop
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildIntroImage()),
                  const SizedBox(width: 40),
                  Expanded(child: _buildIntroText()),
                ],
              )
              : Column(
                children: [
                  _buildIntroImage(),
                  const SizedBox(height: 30),
                  _buildIntroText(),
                ],
              ),
    );
  }

  Widget _buildIntroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/background-pc.png', // Placeholder for church image
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 50)),
            ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Giới thiệu về dòng họ',
          style: TextStyle(
            color: AppColors.woodBrown,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Lịch sử hình thành chi họ bắt nguồn từ...',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        SizedBox(height: 10),
        Text(
          'Tổ tiên khai sáng đã đặt nền móng vững chắc...',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        SizedBox(height: 10),
        Text(
          'Với triết lý "Uống nước nhớ nguồn", con cháu đời đời ghi nhớ công ơn...',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Danh mục chính',
            style: TextStyle(
              color: AppColors.woodBrown,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildCategoryCard(Icons.account_tree, 'Gia phả'),
              _buildCategoryCard(Icons.photo_library, 'Hình ảnh'),
              _buildCategoryCard(Icons.description, 'Tài liệu'),
              _buildCategoryCard(Icons.event, 'Sự kiện'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Container(
      width: 250,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.woodBrown,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 50),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTimeline(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Tin tức & Sự kiện',
            style: TextStyle(
              color: AppColors.woodBrown,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildTimelineItem(
                  '10/03/2025',
                  'Giỗ tổ dòng họ',
                  'Tổ chức tại nhà thờ họ...',
                ),
                _buildTimelineItem(
                  '15/04/2025',
                  'Họp mặt định kỳ',
                  'Bàn về việc tu sửa...',
                ),
                _buildTimelineItem(
                  '01/05/2025',
                  'Trao học bổng khuyến học',
                  'Dành cho con cháu có thành tích...',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.darkRed,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 60, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(description, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
