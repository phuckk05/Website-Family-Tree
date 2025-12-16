import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/providers/album_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

// StateProvider cho menu được chọn
final _selectedMenuProvider = StateProvider.autoDispose<int>((ref) => 0);

enum ActionAlbum { add, edit, delete }

/// Trang cài đặt và quản lý nội dung
///
/// Đây là nơi cập nhật data các page:
/// - Quản lý thư viện ảnh và album
/// - Import/Export dữ liệu gia phả
/// - Cài đặt giao diện và hệ thống
class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  // Danh sách menu chức năng
  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.photo_library_outlined,
      'title': 'Quản lý album',
      'description': 'Thêm/Sửa/Xóa album ảnh',
    },
    {
      'icon': Icons.add_photo_alternate_outlined,
      'title': 'Thêm ảnh',
      'description': 'Upload ảnh vào album',
    },
    {
      'icon': Icons.account_tree_outlined,
      'title': 'Import gia phả',
      'description': 'Nhập dữ liệu gia phả',
    },
    {
      'icon': Icons.download_outlined,
      'title': 'Export dữ liệu',
      'description': 'Xuất dữ liệu ra file',
    },
    {
      'icon': Icons.article_outlined,
      'title': 'Quản lý bài viết',
      'description': 'Thêm/Sửa nội dung',
    },
    {
      'icon': Icons.settings_outlined,
      'title': 'Cài Đặt Chung',
      'description': 'Cấu hình hệ thống',
    },
  ];

  TextEditingController tileController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    tileController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final selectedIndex = ref.watch(_selectedMenuProvider);

    return MainLayout(
      index: 7,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warmBeige,
              AppColors.paperBeige,
              AppColors.lightBrown.withOpacity(0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Vintage Header
              _buildVintageHeader(),

              // Main Content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 10 : 32),
                    child:
                        isMobile
                            ? _buildMobileLayout(selectedIndex)
                            : _buildDesktopLayout(selectedIndex),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng header vintage
  Widget _buildVintageHeader() {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 32,
        vertical: isMobile ? 20 : 40,
      ),
      decoration: BoxDecoration(),
      child: Column(
        children: [
          Text(
            'CÀI ĐẶT & QUẢN LÝ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBrown,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Quản lý nội dung và cấu hình hệ thống',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            width: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldBorder,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout cho desktop/tablet
  Widget _buildDesktopLayout(int selectedIndex) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu bên trái (flex 3)
          Expanded(flex: 3, child: _buildMenuPanel()),
          const SizedBox(width: 24),
          // Content bên phải (flex 7)
          Expanded(flex: 7, child: _buildContentPanel(selectedIndex)),
        ],
      ),
    );
  }

  /// Layout cho mobile
  Widget _buildMobileLayout(int selectedIndex) {
    return Column(
      children: [
        _buildMenuPanel(),
        const SizedBox(height: 16),
        _buildContentPanel(selectedIndex),
      ],
    );
  }

  /// Panel menu chức năng
  Widget _buildMenuPanel() {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final selectedIndex = ref.watch(_selectedMenuProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.creamPaper, AppColors.warmBeige],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBrown.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.deepGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'CHỨC NĂNG',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final isSelected = selectedIndex == index;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(_selectedMenuProvider.notifier).state = index;
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.lightBrown.withOpacity(0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.goldBorder
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color:
                              isSelected
                                  ? AppColors.deepGreen
                                  : AppColors.mutedText,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 16,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                  color:
                                      isSelected
                                          ? AppColors.darkBrown
                                          : AppColors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'] as String,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.goldBorder,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Panel hiển thị nội dung
  Widget _buildContentPanel(int selectedIndex) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.creamPaper, AppColors.warmBeige],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.lightBrown.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _menuItems[selectedIndex]['icon'] as IconData,
                  color: AppColors.deepGreen,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _menuItems[selectedIndex]['title'] as String,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBrown,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _menuItems[selectedIndex]['description'] as String,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14,
                          color: AppColors.mutedText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: _buildDemoContent(selectedIndex),
          ),
        ],
      ),
    );
  }

  /// Nội dung demo cho từng menu
  Widget _buildDemoContent(int index) {
    switch (index) {
      case 0:
        return _buildAlbumManagement();
      case 1:
        return _buildPhotoUpload();
      case 2:
        return _buildImportFamily();
      case 3:
        return _buildExportData();
      case 4:
        return _buildContentManagement();
      case 5:
        return _buildGeneralSettings();
      default:
        return _buildPlaceholder();
    }
  }

  /// Demo: Quản lý Album
  Widget _buildAlbumManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.info_outline,
          text:
              'Quản lý các album ảnh trong thư viện. Tạo mới, chỉnh sửa hoặc xóa album.',
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.add_box_outlined,
          label: 'Tạo Album Mới',
          onPressed: () {
            // Hiển thị dialog thêm album
            _showAddAlbumDialog(
              null,
              tileController,
              descriptionController,
              yearController,
              ActionAlbum.add,
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Danh sách Album:',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 12),
        // Hiển thị danh sách album từ StreamBuilder
        StreamBuilder<Set<dynamic>>(
          stream: ref.watch(albumNotifierProvider.notifier).getAlbums(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.deepGreen),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.vintageIvory.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bronzeBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Có lỗi khi tải danh sách album',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              );
            }

            final albums = snapshot.data?.toList() ?? [];
            if (albums.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.vintageIvory.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bronzeBorder.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Chưa có album nào. Nhấn "Tạo Album Mới" để thêm.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return _buildAlbumList(albums);
          },
        ),
      ],
    );
  }

  /// Xây dựng danh sách album
  Widget _buildAlbumList(List<dynamic> albums) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: albums.length,
        separatorBuilder:
            (context, index) => Divider(
              color: AppColors.bronzeBorder.withOpacity(0.3),
              height: 1,
            ),
        itemBuilder: (context, index) {
          final album = albums[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.photo_library_outlined,
              color: AppColors.deepGreen,
              size: 20,
            ),
            title: Text(
              album.title,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown,
              ),
            ),
            subtitle: Text(
              '${album.description} • ${album.year}',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 12,
                color: AppColors.mutedText,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.mutedText,
                    size: 18,
                  ),
                  onPressed: () {
                    _showAddAlbumDialog(
                      album.id,
                      TextEditingController(text: album.title),
                      TextEditingController(text: album.description),
                      TextEditingController(text: album.year),
                      ActionAlbum.edit,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outlined,
                    color: AppColors.mutedText,
                    size: 18,
                  ),
                  onPressed: () {
                    _showAddAlbumDialog(
                      album.id,
                      TextEditingController(text: album.title),
                      TextEditingController(text: album.description),
                      TextEditingController(text: album.year),
                      ActionAlbum.delete,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Demo: Thêm Ảnh
  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.upload_file,
          text:
              'Upload ảnh mới vào các album đã có. Hỗ trợ nhiều định dạng: JPG, PNG, GIF.',
        ),
        const SizedBox(height: 24),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.vintageIvory.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.bronzeBorder,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 64,
                  color: AppColors.mutedText,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kéo thả ảnh vào đây hoặc nhấn để chọn',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.mutedText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.photo_library_outlined,
          label: 'Chọn Album Đích',
          onPressed: () {
            // TODO: Implement
          },
        ),
      ],
    );
  }

  /// Demo: Import Gia Phả
  Widget _buildImportFamily() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.warning_amber_outlined,
          text:
              'Nhập dữ liệu gia phả từ file JSON hoặc Excel. Lưu ý: dữ liệu cũ sẽ được ghi đè.',
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.upload_file_outlined,
          label: 'Chọn File Import',
          onPressed: () {
            // TODO: Implement
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.preview_outlined,
          label: 'Xem Trước Dữ Liệu',
          onPressed: () {
            // TODO: Implement
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Định dạng hỗ trợ:',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 12),
        // _buildDemoList(['JSON (.json)', 'Excel (.xlsx, .xls)', 'CSV (.csv)']),
      ],
    );
  }

  /// Demo: Export Dữ Liệu
  Widget _buildExportData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.info_outline,
          text: 'Xuất toàn bộ dữ liệu gia phả ra file để sao lưu hoặc chia sẻ.',
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.download_outlined,
          label: 'Export JSON',
          onPressed: () {
            // TODO: Implement
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.table_chart_outlined,
          label: 'Export Excel',
          onPressed: () {
            // TODO: Implement
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'Export PDF',
          onPressed: () {
            // TODO: Implement
          },
        ),
      ],
    );
  }

  /// Demo: Quản lý Bài Viết
  Widget _buildContentManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.info_outline,
          text: 'Thêm, sửa, xóa các bài viết và nội dung trên trang chủ.',
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          icon: Icons.add_circle_outline,
          label: 'Tạo Bài Viết Mới',
          onPressed: () {
            // TODO: Implement
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Danh sách bài viết:',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<Set<dynamic>>(
          stream: ref.watch(albumNotifierProvider.notifier).getAlbums(),
          builder: (context, snapshot) {
            final Set<dynamic> albums = snapshot.data ?? {};
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Lỗi tải danh sách album: ${snapshot.error}');
            }

            if (albums.isEmpty) {
              return Text(
                'Chưa có bài viết nào.',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14,
                  color: AppColors.mutedText,
                  fontStyle: FontStyle.italic,
                ),
              );
            }
            return Column(
              children:
                  albums
                      .map<Widget>((e) => _buildDemoList(e.title.toString()))
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  /// Demo: Cài Đặt Chung
  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          icon: Icons.settings_suggest_outlined,
          text: 'Cấu hình các thông số chung của hệ thống.',
        ),
        const SizedBox(height: 24),
        _buildSettingItem(
          'Tên Dòng Họ',
          'Họ Nguyễn Văn',
          Icons.family_restroom_outlined,
        ),
        const SizedBox(height: 16),
        _buildSettingItem('Ngôn Ngữ', 'Tiếng Việt', Icons.language_outlined),
        const SizedBox(height: 16),
        _buildSettingItem(
          'Màu Chủ Đạo',
          'Vintage Brown',
          Icons.palette_outlined,
        ),
        const SizedBox(height: 16),
        _buildSettingItem('Tự Động Sao Lưu', 'Bật', Icons.backup_outlined),
      ],
    );
  }

  /// Widget placeholder
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: AppColors.mutedText,
          ),
          const SizedBox(height: 16),
          Text(
            'Chức năng đang phát triển',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget info box
  Widget _buildInfoBox({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBrown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                color: AppColors.darkBrown,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepGreen, AppColors.deepGreen.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget demo list
  Widget _buildDemoList(String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.check_circle_outline,
          color: AppColors.deepGreen,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            color: AppColors.darkBrown,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: AppColors.mutedText, size: 18),
          onPressed: () {
            // TODO: Implement edit
          },
        ),
      ),
    );
  }

  /// Hiển thị dialog thêm album mới
  void _showAddAlbumDialog(
    int? id,
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController yearController,
    ActionAlbum actionAlbum,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.creamPaper, AppColors.warmBeige],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldBorder, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      Icons.photo_library_outlined,
                      size: 48,
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      actionAlbum == ActionAlbum.add
                          ? 'Thêm Album Mới'
                          : actionAlbum == ActionAlbum.edit
                          ? 'Chỉnh Sửa Album'
                          : 'Xóa Album',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Divider
                    Container(
                      height: 2,
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.goldBorder,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tiêu đề
                    _buildVintageTextField(
                      controller: titleController,
                      label: 'Tiêu đề album',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 16),
                    // Mô tả
                    _buildVintageTextField(
                      controller: descriptionController,
                      label: 'Mô tả',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Năm
                    _buildVintageTextField(
                      controller: yearController,
                      label: 'Năm (VD: 2024)',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Nút Hủy
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.vintageIvory,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.bronzeBorder,
                                width: 2,
                              ),
                            ),
                            child: TextButton(
                              onPressed: () => {Navigator.pop(context)},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.mutedText,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Nút Thêm
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.deepGreen,
                                  AppColors.deepGreen.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () async {
                                // Kiểm tra dữ liệu nhập
                                if (titleController.text.isEmpty ||
                                    descriptionController.text.isEmpty ||
                                    yearController.text.isEmpty) {
                                  // Hiển thị cảnh báo nếu chưa nhập đầy đủ
                                  ref
                                      .read(notificationProvider.notifier)
                                      .show(
                                        'Vui lòng nhập đầy đủ thông tin album trước khi thêm!',
                                        type: NotificationType.error,
                                      );
                                } else {
                                  switch (actionAlbum) {
                                    case ActionAlbum.add:
                                      try {
                                        Album newAlbum = Album.create(
                                          title: titleController.text,
                                          description:
                                              descriptionController.text,
                                          year: yearController.text,
                                        );
                                        await ref
                                            .read(
                                              albumNotifierProvider.notifier,
                                            )
                                            .addAlbum(newAlbum);

                                        if (mounted) {
                                          // Hiển thị thông báo thành công
                                          ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .show(
                                                'Thêm album thành công!',
                                                type: NotificationType.success,
                                              );
                                          // Đóng dialog
                                          Navigator.pop(context);
                                        }

                                        // Xoá dữ liệu trong controller
                                        titleController.clear();
                                        descriptionController.clear();
                                        yearController.clear();
                                      } catch (e) {
                                        if (mounted) {
                                          ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .show(
                                                'Lỗi khi thêm album: $e',
                                                type: NotificationType.error,
                                              );
                                        }
                                      }
                                      break;
                                    case ActionAlbum.edit:
                                      try {
                                        Album updatedAlbum = Album(
                                          id: id!,
                                          title: titleController.text,
                                          description:
                                              descriptionController.text,
                                          year: yearController.text,
                                        );
                                        ref
                                            .read(
                                              albumNotifierProvider.notifier,
                                            )
                                            .updateAlbum(updatedAlbum);

                                        if (mounted) {
                                          // Hiển thị thông báo thành công
                                          ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .show(
                                                'Cập nhật album thành công!',
                                                type: NotificationType.success,
                                              );
                                          // Đóng dialog
                                          Navigator.pop(context);
                                        }

                                        // Xoá dữ liệu trong controller
                                        titleController.clear();
                                        descriptionController.clear();
                                        yearController.clear();
                                      } catch (e) {
                                        if (mounted) {
                                          ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .show(
                                                'Lỗi khi cập nhật album: $e',
                                                type: NotificationType.error,
                                              );
                                        }
                                      }
                                      break;
                                    case ActionAlbum.delete:
                                      Album deletedAlbum = Album(
                                        id: id!,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                        year: yearController.text,
                                      );
                                      ref
                                          .read(albumNotifierProvider.notifier)
                                          .removeAlbum(deletedAlbum);
                                      if (mounted) {
                                        // Hiển thị thông báo thành công
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Xóa album thành công!',
                                              type: NotificationType.success,
                                            );
                                        // Đóng dialog
                                        Navigator.pop(context);
                                      }
                                      break;
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                actionAlbum == ActionAlbum.add
                                    ? 'Thêm Album'
                                    : actionAlbum == ActionAlbum.edit
                                    ? 'Lưu Thay Đổi'
                                    : 'Xóa Album',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.creamPaper,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  /// Xây dựng text field vintage
  Widget _buildVintageTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 15,
          color: AppColors.darkBrown,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'serif',
            color: AppColors.mutedText,
          ),
          prefixIcon: Icon(icon, color: AppColors.sepiaTone, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Widget setting item
  Widget _buildSettingItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.mutedText),
            onPressed: () {
              // TODO: Implement edit
            },
          ),
        ],
      ),
    );
  }
}
