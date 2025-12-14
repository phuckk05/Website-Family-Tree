import 'package:flutter/material.dart';
import 'package:website_gia_pha/themes/app_colors.dart';

/// Footer với phong cách vintage 1990s Vietnamese
///
/// Hiển thị thông tin liên hệ, bản quyền và các liên kết quan trọng
/// với thiết kế ấm áp, trang trọng như các tài liệu gia phả cổ
class CustomFooter extends StatefulWidget {
  const CustomFooter({super.key});

  @override
  State<CustomFooter> createState() => _CustomFooterState();
}

class _CustomFooterState extends State<CustomFooter> {
  String? _hoveredLink;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.woodBrown.withOpacity(0.95), AppColors.woodBrown],
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Footer Content
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
              vertical: isMobile ? 32 : 48,
            ),
            child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),

          // Decorative Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryGold.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom Bar
          _buildBottomBar(isMobile),
        ],
      ),
    );
  }

  /// Layout cho desktop (3 cột)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAboutSection()),
        const SizedBox(width: 48),
        Expanded(child: _buildContactSection()),
        const SizedBox(width: 48),
        Expanded(child: _buildQuickLinksSection()),
      ],
    );
  }

  /// Layout cho mobile (stacked)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAboutSection(),
        const SizedBox(height: 32),
        _buildContactSection(),
        const SizedBox(height: 32),
        _buildQuickLinksSection(),
      ],
    );
  }

  /// Section: Về Gia Tộc
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('VỀ GIA TỘC'),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.temple_buddhist,
                color: AppColors.primaryGold,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HỌ NGUYỄN ĐÌNH',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CHI 5',
                    style: TextStyle(
                      color: AppColors.creamPaper.withOpacity(0.8),
                      fontSize: 13,
                      letterSpacing: 1,
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Gìn giữ truyền thống, lưu giữ kỷ niệm,\nnối dài dòng họ qua các thế hệ.',
          style: TextStyle(
            color: AppColors.creamPaper.withOpacity(0.9),
            fontSize: 14,
            height: 1.6,
            fontFamily: 'Serif',
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Section: Liên Hệ
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('LIÊN HỆ'),
        const SizedBox(height: 16),
        _buildContactItem(
          Icons.location_on,
          'Nhà Thờ Họ',
          'Xã Bạch Hà, Tỉnh Nghệ An',
        ),
        const SizedBox(height: 12),
        _buildContactItem(Icons.phone, 'Điện thoại', '0328262101'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.email, 'Email', 'phuckk2101@gmail.com'),
      ],
    );
  }

  /// Section: Liên Kết Nhanh
  Widget _buildQuickLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('LIÊN KẾT NHANH'),
        const SizedBox(height: 16),
        _buildFooterLink('Trang chủ', Icons.home),
        _buildFooterLink('Gia phả', Icons.account_tree),
        _buildFooterLink('Hình ảnh', Icons.photo_library),
        _buildFooterLink('Liên hệ', Icons.contact_mail),
        const SizedBox(height: 16),
        _buildFooterLink('Chính sách bảo mật', Icons.privacy_tip),
        _buildFooterLink('Điều khoản sử dụng', Icons.description),
      ],
    );
  }

  /// Xây dựng tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.primaryGold,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  /// Xây dựng item liên hệ
  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryGold.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.creamPaper.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'Serif',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng link với hover effect
  Widget _buildFooterLink(String text, IconData icon) {
    final isHovered = _hoveredLink == text;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLink = text),
      onExit: (_) => setState(() => _hoveredLink = null),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to respective page
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isHovered
                        ? AppColors.primaryGold
                        : AppColors.creamPaper.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color:
                      isHovered
                          ? AppColors.primaryGold
                          : AppColors.creamPaper.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Serif',
                  decoration:
                      isHovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                  decorationColor: AppColors.primaryGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng bottom bar với copyright
  Widget _buildBottomBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: 20,
      ),
      child: Column(
        children: [
          if (isMobile) ...[
            _buildCopyrightText(),
            const SizedBox(height: 8),
            _buildCreditsText(),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildCopyrightText(), _buildCreditsText()],
            ),
        ],
      ),
    );
  }

  /// Text bản quyền
  Widget _buildCopyrightText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.copyright,
          color: AppColors.creamPaper.withOpacity(0.6),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          '${DateTime.now().year} Họ Nguyễn Đình Chi 5. All rights reserved.',
          style: TextStyle(
            color: AppColors.creamPaper.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Serif',
          ),
        ),
      ],
    );
  }

  /// Text credits
  Widget _buildCreditsText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Made with ',
          style: TextStyle(
            color: AppColors.creamPaper.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Serif',
          ),
        ),
        Icon(
          Icons.favorite,
          color: AppColors.dustyRose.withOpacity(0.8),
          size: 14,
        ),
        Text(
          ' for family',
          style: TextStyle(
            color: AppColors.creamPaper.withOpacity(0.7),
            fontSize: 12,
            fontFamily: 'Serif',
          ),
        ),
      ],
    );
  }
}
