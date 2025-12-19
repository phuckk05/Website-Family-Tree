import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:website_gia_pha/APIs/cloudinary_api.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/providers/album_provider.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/providers/clan_id_provider.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/loading_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

import 'package:website_gia_pha/utils/file_picker_stub.dart'
    if (dart.library.html) 'package:website_gia_pha/utils/web_file_picker.dart';

// StateProvider cho menu được chọn
final _selectedMenuProvider = StateProvider.autoDispose<int>((ref) => 0);

// StateProvider cho hover upload area
final _isHoverUploadProvider = StateProvider.autoDispose<bool>((ref) => false);

// StateProvider cho danh sách ảnh đã chọn
final _selectedImagesProvider = StateProvider.autoDispose<List<dynamic>>(
  (ref) => [],
);

final _isFocus = StateProvider.autoDispose<bool>((ref) => false);
//StateProvider albums đã được chọn
// final _selectedAlbumProvider = StateProvider<Album?>((ref) => null);

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
  // Controllers cho form thêm/sửa album
  late TextEditingController tileController;
  late TextEditingController descriptionController;
  late TextEditingController yearController;
  //Image picker
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryApi _cloudinaryApi = CloudinaryApi();
  //Các hàm lấy ảnh từ thiết bị
  Future<void> pickImages() async {
    try {
      if (kIsWeb) {
        // Web: Dùng file_picker
        await _pickImagesWeb();
      } else {
        // Mobile/Desktop: Dùng image_picker
        await _pickImagesMobile();
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chọn ảnh: $e', NotificationType.error);
      }
    }
  }

  /// Pick ảnh trên Web (file_picker)
  Future<void> _pickImagesWeb() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final picked = await pickImagesWeb();

      if (picked != null && picked.isNotEmpty) {
        // Lưu danh sách file (PlatformFile có bytes cho web)
        ref.read(_selectedImagesProvider.notifier).state = picked;

        if (mounted) {
          ref
              .read(notificationProvider.notifier)
              .show('Đã chọn ${picked.length} ảnh', NotificationType.success);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi chọn ảnh trên web: $e');
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chọn ảnh web: $e', NotificationType.error);
      }
    }
  }

  /// Pick ảnh trên Mobile/Desktop (image_picker)
  Future<void> _pickImagesMobile() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85, // Nén ảnh 85% chất lượng
      );

      if (images.isNotEmpty) {
        // Lưu danh sách XFile
        ref.read(_selectedImagesProvider.notifier).state = images;

        if (mounted) {
          ref
              .read(notificationProvider.notifier)
              .show('Đã chọn ${images.length} ảnh', NotificationType.success);
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi chọn ảnh trên mobile/desktop: $e');
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chọn ảnh mobile: $e', NotificationType.error);
      }
    }
  }

  /// Pick ảnh từ camera (chỉ mobile)
  Future<void> pickImageFromCamera() async {
    if (kIsWeb) {
      ref
          .read(notificationProvider.notifier)
          .show('Camera không khả dụng trên web', NotificationType.error);
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        // Thêm ảnh vào danh sách
        final currentImages = ref.read(_selectedImagesProvider);
        ref.read(_selectedImagesProvider.notifier).state = [
          ...currentImages,
          image,
        ];

        if (mounted) {
          ref
              .read(notificationProvider.notifier)
              .show('Đã chụp ảnh thành công', NotificationType.success);
        }
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chụp ảnh: $e', NotificationType.error);
      }
    }
  }

  /// Xóa ảnh đã chọn
  void removeSelectedImage(int index) {
    final currentImages = ref.read(_selectedImagesProvider);
    final newImages = List.from(currentImages)..removeAt(index);
    ref.read(_selectedImagesProvider.notifier).state = newImages;
  }

  /// Clear tất cả ảnh đã chọn
  void clearSelectedImages() {
    ref.read(_selectedImagesProvider.notifier).state = [];
  }

  //Xử lý chuyển ảnh về rul
  void _uploadSelectedImages(int albumId) async {
    final selectedImages = ref.read(_selectedImagesProvider);
    if (selectedImages.isEmpty) {
      ref
          .read(notificationProvider.notifier)
          .show('Chưa có ảnh nào được chọn', NotificationType.error);
      return;
    }
    ref.read(loadingNotifierProvider.notifier).show('Đang upload ảnh...');
    try {
      // ignore: unused_local_variable
      List<String> uploadedUrls = [];
      if (kIsWeb) {
        // Web: Upload từ bytes
        List<Uint8List> imageBytesList =
            selectedImages.map<Uint8List>((file) => file.bytes!).toList();
        List<String> fileNames =
            selectedImages.map<String>((file) => file.name).toList();

        uploadedUrls = await _cloudinaryApi.uploadMultipleImagesFromBytes(
          imageBytesList,
          fileNames,
          folder: 'family_album',
        );
      } else {
        // Mobile/Desktop: Upload từ file paths
        List<String> filePaths =
            selectedImages.map<String>((file) => file.path).toList();

        uploadedUrls = await _cloudinaryApi.uploadMultipleImagesFromPath(
          filePaths,
          folder: 'family_album',
        );
      }
      //lấy clanId
      final clanId = ref.read(clanIdProvider);
      //ghi vào firebase album photos
      final success = await ref
          .read(albumNotifierProvider.notifier)
          .addPhotoToAlbum(clanId, uploadedUrls, albumId);
      // kiểm tra và thông báo
      if (success) {
        ref.read(loadingNotifierProvider.notifier).hide();
        clearSelectedImages();
        ref
            .read(notificationProvider.notifier)
            .show('Đã upload ảnh thành công', NotificationType.success);
      }
    } catch (e) {
      ref.read(loadingNotifierProvider.notifier).hide();
      ref
          .read(notificationProvider.notifier)
          .show('Lỗi khi upload ảnh !', NotificationType.error);
      debugPrint('Lỗi khi upload ảnh: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers mới mỗi lần page được tạo
    tileController = TextEditingController();
    descriptionController = TextEditingController();
    yearController = TextEditingController();

    // Reset menu và images về trạng thái ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(_selectedMenuProvider.notifier).state = 0;
        ref.read(_selectedImagesProvider.notifier).state = [];
        ref.read(_isHoverUploadProvider.notifier).state = false;
      }
    });
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
    final authState = ref.watch(authProvider);

    // Show loading while checking auth
    return authState.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              MainLayout(index: 7, child: Center(child: Text('Error: $error'))),
      data: (isLoggedIn) {
        // Redirect if not logged in
        if (!isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AppRouter.go(context, AppRouter.login);
            }
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        return _buildMainContent(isMobile, selectedIndex);
      },
    );
  }

  Widget _buildMainContent(bool isMobile, int selectedIndex) {
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
        // Hiển thị danh sách album - watch state trực tiếp
        Consumer(
          builder: (context, ref, child) {
            final albums = ref.watch(albumNotifierProvider);

            // if (albums.isEmpty) {
            //   return Container(
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: AppColors.vintageIvory.withOpacity(0.3),
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(
            //         color: AppColors.bronzeBorder.withOpacity(0.3),
            //         width: 1,
            //       ),
            //     ),
            //     child: Text(
            //       'Chưa có album nào. Nhấn "Tạo Album Mới" để thêm.',
            //       style: TextStyle(
            //         fontFamily: 'serif',
            //         fontSize: 14,
            //         color: AppColors.mutedText,
            //         fontStyle: FontStyle.italic,
            //       ),
            //     ),
            //   );
            // }
            return albums.when(
              data: (data) {
                return _buildAlbumList(data);
              },
              error: (error, stackTrace) {
                return Text(
                  'Lỗi khi tải album: $error',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    color: AppColors.goldBorder,
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }

  /// Xây dựng danh sách album
  Widget _buildAlbumList(List<Album> albums) {
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
        Consumer(
          builder: (context, ref, child) {
            final isHover = ref.watch(_isHoverUploadProvider);
            return MouseRegion(
              onEnter:
                  (_) => ref.read(_isHoverUploadProvider.notifier).state = true,
              onExit:
                  (_) =>
                      ref.read(_isHoverUploadProvider.notifier).state = false,
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () {
                  clearSelectedImages();
                  pickImages();
                },
                borderRadius: BorderRadius.circular(12),
                child: DottedBorder(
                  color: isHover ? AppColors.deepGreen : AppColors.bronzeBorder,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isHover
                              ? AppColors.deepGreen.withOpacity(0.05)
                              : AppColors.vintageIvory.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color:
                                isHover
                                    ? AppColors.deepGreen
                                    : AppColors.mutedText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kéo thả ảnh vào đây hoặc nhấn để chọn',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 14,
                              color:
                                  isHover
                                      ? AppColors.deepGreen
                                      : AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                              fontWeight:
                                  isHover ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Nút chụp ảnh (chỉ mobile)
        if (!kIsWeb)
          _buildActionButton(
            icon: Icons.camera_alt_outlined,
            label: 'Chụp Ảnh',
            onPressed: pickImageFromCamera,
          ),

        const SizedBox(height: 24),

        // Hiển thị preview ảnh đã chọn
        Consumer(
          builder: (context, ref, child) {
            final selectedImages = ref.watch(_selectedImagesProvider);

            if (selectedImages.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã chọn ${selectedImages.length} ảnh:',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: clearSelectedImages,
                      icon: Icon(Icons.clear_all, color: AppColors.mutedText),
                      label: Text(
                        'Xóa tất cả',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildImagePreviewGrid(selectedImages),
                const SizedBox(height: 24),
              ],
            );
          },
        ),

        _buildActionButton(
          icon: Icons.photo_library_outlined,
          label: 'Chọn Album Đích',
          onPressed: () async {
            final selectedImages = ref.read(_selectedImagesProvider);
            if (selectedImages.isEmpty) {
              ref
                  .read(notificationProvider.notifier)
                  .show('Vui lòng chọn ảnh trước!', NotificationType.error);
              return;
            }
            // Hiển thị dialog chọn album đích
            _showChooseAlbumDialog();
          },
        ),
      ],
    );
  }

  /// Xây dựng grid preview ảnh
  Widget _buildImagePreviewGrid(List<dynamic> images) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return _buildImagePreviewItem(image, index);
        },
      ),
    );
  }

  /// Xây dựng item preview ảnh
  Widget _buildImagePreviewItem(dynamic image, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.creamPaper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.bronzeBorder.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child:
                kIsWeb
                    ? Image.memory(
                      image.bytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                    : FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.deepGreen,
                            strokeWidth: 2,
                          ),
                        );
                      },
                    ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => removeSelectedImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
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
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
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
        Consumer(
          builder: (context, ref, child) {
            final albums = ref.watch(albumNotifierProvider);
            return albums.when(
              data: (data) {
                if (data.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 10 : 32),
                    child: Center(
                      child: Text(
                        'Chưa có album nào',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children:
                        data
                            .map<Widget>(
                              (e) => _buildDemoList(e.title.toString()),
                            )
                            .toList(),
                  );
                }
              },
              error: (error, stackTrace) {
                return Center(
                  child: Text(
                    'Lỗi tải dữ liệu album: $error',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: AppColors.darkBrown,
                    ),
                  ),
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
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

  void _showChooseAlbumDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Consumer(
            builder:
                (context, ref, child) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 600,
                    ),
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
                          'Chọn album đích',
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

                        // Danh sách album - watch state trực tiếp
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final albums = ref.watch(albumNotifierProvider);

                              return albums.when(
                                data: (data) {
                                  if (data.isEmpty) {
                                    return Center(
                                      child: Text(
                                        'Chưa có album nào. Vui lòng tạo album trước.',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.vintageIvory
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.bronzeBorder
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        separatorBuilder:
                                            (context, index) => Divider(
                                              color: AppColors.bronzeBorder
                                                  .withOpacity(0.3),
                                              height: 1,
                                            ),
                                        itemBuilder: (context, index) {
                                          final album = data[index];

                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showConfirmSaveAlbum(album);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            album.title,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'serif',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  AppColors
                                                                      .darkBrown,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            'Năm: ${album.year}',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'serif',
                                                              fontSize: 12,
                                                              color:
                                                                  AppColors
                                                                      .mutedText,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
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
                                        },
                                      ),
                                    );
                                  }
                                },
                                error: (error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      'Lỗi tải dữ liệu album: $error',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  );
                                },
                                loading:
                                    () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );
                            },
                          ),
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Quay Lại',
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showConfirmSaveAlbum(Album selectedAlbum) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Consumer(
            builder:
                (context, ref, child) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 600,
                    ),
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
                          'Xác nhận lưu',
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

                        // Thông tin album đã chọn
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.vintageIvory.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.bronzeBorder.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Builder(
                            builder: (context) {
                              final album = selectedAlbum;

                              // ignore: unnecessary_null_comparison
                              if (album == null) {
                                return Text(
                                  'Không có album được chọn',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 14,
                                    color: AppColors.mutedText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.photo_album,
                                        size: 20,
                                        color: AppColors.deepGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Album đích',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    album.title,
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Năm: ${album.year}',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 14,
                                      color: AppColors.mutedText,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  if (album.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      album.description,
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 13,
                                        color: AppColors.mutedText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Quay Lại',
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
                                  onPressed: () {
                                    _uploadSelectedImages(selectedAlbum.id);
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'lưu',
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
                          ],
                        ),
                      ],
                    ),
                  ),
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
                                final isOpen = ref.read(_isFocus);
                                if (isOpen) return;

                                if (actionAlbum != ActionAlbum.delete &&
                                    (titleController.text.isEmpty ||
                                        descriptionController.text.isEmpty ||
                                        yearController.text.isEmpty)) {
                                  ref
                                      .read(notificationProvider.notifier)
                                      .show(
                                        'Vui lòng nhập đầy đủ thông tin album!',
                                        NotificationType.error,
                                      );
                                  return;
                                }

                                ref.read(_isFocus.notifier).state = true;

                                try {
                                  switch (actionAlbum) {
                                    case ActionAlbum.add:
                                      final newAlbum = Album.create(
                                        title: titleController.text,
                                        description: descriptionController.text,
                                        year: yearController.text,
                                      );

                                      final clan = ref.watch(
                                        clanNotifierProvider,
                                      );

                                      clan.when(
                                        data:
                                            (data) => ref
                                                .read(
                                                  albumNotifierProvider
                                                      .notifier,
                                                )
                                                .addAlbum(
                                                  data.first.id,
                                                  newAlbum,
                                                ),
                                        error:
                                            (error, stackTrace) => debugPrint(
                                              'lỗi thêm clan ${error}',
                                            ),
                                        loading: () {},
                                      );

                                      if (mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Thêm album thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                      }

                                      titleController.clear();
                                      descriptionController.clear();
                                      yearController.clear();
                                      break;

                                    case ActionAlbum.edit:
                                      final updatedAlbum = Album(
                                        id: id!,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                        year: yearController.text,
                                      );
                                      final clanId = ref.watch(clanIdProvider);
                                      final success = await ref
                                          .read(albumNotifierProvider.notifier)
                                          .updateAlbum(clanId, updatedAlbum);

                                      if (success && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Cập nhật album thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                        titleController.clear();
                                        descriptionController.clear();
                                        yearController.clear();
                                      }
                                      break;

                                    case ActionAlbum.delete:
                                      final deletedAlbum = Album(
                                        id: id!,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                        year: yearController.text,
                                      );
                                      final clanId = ref.watch(clanIdProvider);

                                      final response = await ref
                                          .read(albumNotifierProvider.notifier)
                                          .removeAlbum(clanId, deletedAlbum);

                                      if (response && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Xóa album thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                      }

                                      break;
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .show(
                                          'Có lỗi xảy ra: $e',
                                          NotificationType.error,
                                        );
                                  }
                                } finally {
                                  ref.read(_isFocus.notifier).state = false;
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
