import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:website_gia_pha/APIs/cloudinary_api.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/models/clan.dart';
import 'package:website_gia_pha/providers/album_provider.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/providers/clan_id_provider.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/loading_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/label.dart';
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

final _selectedManageImageProvider = StateProvider.autoDispose<List<dynamic>>(
  (ref) => [],
);

final _isTaped = StateProvider.autoDispose<bool>((ref) => false);

final _isFocus = StateProvider.autoDispose<bool>((ref) => false);

// StateProvider cho upload ảnh album đang chạy
final _isUploadingAlbumProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

//StateProvider albums đã được chọn
// final _selectedAlbumProvider = StateProvider<Album?>((ref) => null);

late final ProviderSubscription sub;

enum ActionAlbum { add, edit, delete }

enum ActionManageContent { add, edit, delete }

enum ActionGenerationContent { add, edit, delete }

enum ActionStory { add, edit, delete }

enum MenuAction {
  manageAlbums,
  addPhotos,
  import,
  export,
  manageContent,
  generalSettings,
}

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
      'title': 'Quản lý nội dung',
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

  //Các controler của Quản lý nội dung
  late TextEditingController nameController;
  late TextEditingController chiController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  late TextEditingController sloganController;
  late TextEditingController sourceSloganController;
  late TextEditingController sourceUrlController;

  //Image picker
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryApi _cloudinaryApi = CloudinaryApi();
  //Các hàm lấy ảnh từ thiết bị
  Future<void> pickImages(AutoDisposeStateProvider provider) async {
    try {
      if (kIsWeb) {
        // Web: Dùng file_picker
        await _pickImagesWeb(provider);
      } else {
        // Mobile/Desktop: Dùng image_picker
        await _pickImagesMobile(provider);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chọn ảnh: $e', NotificationType.error);
      }
    }
  }

  /// Pick a single image (web or mobile)
  Future<void> pickSingleImage(AutoDisposeStateProvider provider) async {
    try {
      if (kIsWeb) {
        await _pickSingleImageWeb(provider);
      } else {
        await _pickSingleImageMobile(provider);
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Lỗi khi chọn ảnh: $e', NotificationType.error);
      }
    }
  }

  Future<void> _pickSingleImageWeb(AutoDisposeStateProvider provider) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final picked = await pickImagesWeb();
      if (picked != null && picked.isNotEmpty) {
        // chỉ giữ 1 ảnh
        ref.read(provider.notifier).state = [picked.first];
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // Đảm bảo UI update
        if (mounted) {
          ref
              .read(notificationProvider.notifier)
              .show('Đã chọn 1 ảnh', NotificationType.success);
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

  Future<void> _pickSingleImageMobile(AutoDisposeStateProvider provider) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        ref.read(provider.notifier).state = [image];
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // Đảm bảo UI update
        if (mounted) {
          ref
              .read(notificationProvider.notifier)
              .show('Đã chọn 1 ảnh', NotificationType.success);
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

  /// Pick ảnh trên Web (file_picker)
  Future<void> _pickImagesWeb(AutoDisposeStateProvider provider) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final picked = await pickImagesWeb();

      if (picked != null && picked.isNotEmpty) {
        // Lưu danh sách file (PlatformFile có bytes cho web)
        ref.read(provider.notifier).state = picked;

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
  Future<void> _pickImagesMobile(AutoDisposeStateProvider provider) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85, // Nén ảnh 85% chất lượng
      );

      if (images.isNotEmpty) {
        // Lưu danh sách XFile
        ref.read(provider.notifier).state = images;

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
  void removeSelectedImage(int index, AutoDisposeStateProvider provider) {
    final currentImages = ref.read(provider);
    final newImages = List.from(currentImages)..removeAt(index);
    ref.read(provider.notifier).state = newImages;
  }

  /// Clear tất cả ảnh đã chọn
  void clearSelectedImages(AutoDisposeStateProvider provider) {
    ref.read(provider.notifier).state = [];
  }

  /// Upload single image and update clan soucreUrl
  Future<void> _uploadSingleImageAndUpdateClan(
    BuildContext context,
    Clan clan,
  ) async {
    final selectedImages = ref.read(_selectedManageImageProvider);
    if (selectedImages.isEmpty) {
      ref
          .read(notificationProvider.notifier)
          .show('Chưa có ảnh nào được chọn', NotificationType.error);
      return;
    }
    ref.read(loadingNotifierProvider.notifier).show('Đang upload ảnh...');
    try {
      String uploadedUrl;
      if (kIsWeb) {
        // Web: Upload từ bytes
        Uint8List imageBytes = selectedImages.first.bytes!;
        String fileName = selectedImages.first.name;
        uploadedUrl = await _cloudinaryApi.uploadImageFromBytes(
          imageBytes,
          fileName,
          folder: 'family_decoration',
        );
      } else {
        // Mobile/Desktop: Upload từ file path
        String filePath = selectedImages.first.path;
        uploadedUrl = await _cloudinaryApi.uploadImageFromPath(
          filePath,
          folder: 'family_decoration',
        );
      }

      // Update clan with new soucreUrl
      Clan updatedClan = Clan(
        id: clan.id,
        name: clan.name,
        chi: clan.chi,
        subNameUrl: clan.subNameUrl,
        phone: clan.phone,
        email: clan.email,
        address: clan.address,
        slogan: clan.slogan,
        soucreSolgan: clan.soucreSolgan,
        soucreUrl: uploadedUrl,
        generations: clan.generations,
        stories: clan.stories,
        createdAt: clan.createdAt,
      );

      final success = await ref
          .read(clanNotifierProvider.notifier)
          .updateClan(clan.id, updatedClan);

      ref.read(loadingNotifierProvider.notifier).hide();
      if (success != null) {
        // Update controller
        sourceUrlController.text = uploadedUrl;
        clearSelectedImages(_selectedManageImageProvider);
        ref
            .read(notificationProvider.notifier)
            .show('Cập nhật ảnh thành công!', NotificationType.success);
      } else {
        ref
            .read(notificationProvider.notifier)
            .show('Cập nhật ảnh thất bại!', NotificationType.error);
      }
    } catch (e) {
      ref.read(loadingNotifierProvider.notifier).hide();
      ref
          .read(notificationProvider.notifier)
          .show('Lỗi khi upload ảnh: $e', NotificationType.error);
      debugPrint('Lỗi khi upload ảnh: $e');
    }
  }

  //Xử lý chuyển ảnh về rul
  Future<bool> _uploadSelectedImages(
    int albumId,
    AutoDisposeStateProvider provider,
  ) async {
    final selectedImages = ref.read(provider);
    if (selectedImages.isEmpty) {
      ref
          .read(notificationProvider.notifier)
          .show('Chưa có ảnh nào được chọn', NotificationType.error);
      return false;
    }
    ref.read(loadingNotifierProvider.notifier).show('Đang upload ảnh...');
    try {
      List<String> uploadedUrls = [];
      if (kIsWeb) {
        // Web: Upload từ bytes — xử lý cẩn thận để tránh type errors trên JS
        List<Uint8List> imageBytesList = [];
        List<String> fileNames = [];
        for (var i = 0; i < selectedImages.length; i++) {
          final file = selectedImages[i];
          try {
            final bytes = (file as dynamic).bytes;
            final name = (file as dynamic).name ?? 'image_$i';
            if (bytes is Uint8List) {
              imageBytesList.add(bytes);
              fileNames.add(name.toString());
            } else {
              debugPrint(
                'Không thể đọc bytes từ file: $name (type=${bytes.runtimeType})',
              );
            }
          } catch (e) {
            debugPrint('Lỗi khi lấy bytes từ file: $e');
          }
        }

        if (imageBytesList.isEmpty) {
          ref.read(loadingNotifierProvider.notifier).hide();
          ref
              .read(notificationProvider.notifier)
              .show(
                'Không có dữ liệu ảnh hợp lệ để upload',
                NotificationType.error,
              );
          return false;
        }

        uploadedUrls = await _cloudinaryApi.uploadMultipleImagesFromBytes(
          imageBytesList,
          fileNames,
          folder: 'family_album',
        );
      } else {
        // Mobile/Desktop: Upload từ file paths
        List<String> filePaths = [];
        for (var i = 0; i < selectedImages.length; i++) {
          final file = selectedImages[i];
          try {
            final path = (file as dynamic).path;
            if (path is String && path.isNotEmpty) {
              filePaths.add(path);
            } else {
              debugPrint('Invalid file.path for item $i: ${path.runtimeType}');
            }
          } catch (e) {
            debugPrint('Lỗi khi lấy path từ file: $e');
          }
        }

        if (filePaths.isEmpty) {
          ref.read(loadingNotifierProvider.notifier).hide();
          ref
              .read(notificationProvider.notifier)
              .show(
                'Không có đường dẫn ảnh hợp lệ để upload',
                NotificationType.error,
              );
          return false;
        }

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
        clearSelectedImages(provider);
        ref
            .read(notificationProvider.notifier)
            .show('Đã upload ảnh thành công', NotificationType.success);
        return true;
      } else {
        ref.read(loadingNotifierProvider.notifier).hide();
        ref
            .read(notificationProvider.notifier)
            .show('Upload ảnh thất bại', NotificationType.error);
        return false;
      }
    } catch (e) {
      ref.read(loadingNotifierProvider.notifier).hide();
      ref
          .read(notificationProvider.notifier)
          .show('Lỗi khi upload ảnh !', NotificationType.error);
      debugPrint('Lỗi khi upload ảnh: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers mới mỗi lần page được tạo
    tileController = TextEditingController();
    descriptionController = TextEditingController();
    yearController = TextEditingController();

    final clan = ref.read(clanNotifierProvider);

    nameController = TextEditingController(
      text:
          clan.whenData((data) => data.isNotEmpty ? data.first.name : '').value,
    );

    chiController = TextEditingController(
      text:
          clan.whenData((data) => data.isNotEmpty ? data.first.chi : '').value,
    );
    phoneController = TextEditingController(
      text:
          clan
              .whenData((data) => data.isNotEmpty ? data.first.phone : '')
              .value,
    );
    emailController = TextEditingController(
      text:
          clan
              .whenData((data) => data.isNotEmpty ? data.first.email : '')
              .value,
    );
    addressController = TextEditingController(
      text:
          clan
              .whenData((data) => data.isNotEmpty ? data.first.address : '')
              .value,
    );
    sloganController = TextEditingController(
      text:
          clan
              .whenData((data) => data.isNotEmpty ? data.first.slogan : '')
              .value,
    );
    sourceSloganController = TextEditingController(
      text:
          clan
              .whenData(
                (data) => data.isNotEmpty ? data.first.soucreSolgan : '',
              )
              .value,
    );
    sourceUrlController = TextEditingController(
      text:
          clan
              .whenData((data) => data.isNotEmpty ? data.first.soucreUrl : '')
              .value,
    );

    // Reset menu và images về trạng thái ban đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(_selectedMenuProvider.notifier).state = 0;
        ref.read(_selectedImagesProvider.notifier).state = [];
        ref.read(_isHoverUploadProvider.notifier).state = false;
        ref.read(_isFocus.notifier).state = false;
        ref.read(_isTaped.notifier).state = false;
      }
    });
  }

  @override
  void dispose() {
    tileController.dispose();
    descriptionController.dispose();
    yearController.dispose();

    nameController.dispose();
    chiController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    sloganController.dispose();
    sourceSloganController.dispose();
    sourceUrlController.dispose();

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
                // Icon(
                //   _menuItems[selectedIndex]['icon'] as IconData,
                //   color: AppColors.deepGreen,
                //   size: 32,
                // ),
                // const SizedBox(width: 16),
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
                          // fontStyle: FontStyle.italic,
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
            padding: EdgeInsets.all(isMobile ? 10 : 32),
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
          'Danh sách Album ',
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
            return albums.when(
              data: (data) {
                if (data.isEmpty) {
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
                      'Chưa có album nào.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        color: AppColors.mutedText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
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
                  clearSelectedImages(_selectedImagesProvider);
                  pickImages(_selectedImagesProvider);
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
                      onPressed:
                          () => clearSelectedImages(_selectedImagesProvider),
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
                _buildImagePreviewGrid(selectedImages, _selectedImagesProvider),
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
  Widget _buildImagePreviewGrid(
    List<dynamic> images,
    AutoDisposeStateProvider<List<dynamic>> provider,
  ) {
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
          return _buildImagePreviewItem(image, index, provider);
        },
      ),
    );
  }

  /// Xây dựng item preview ảnh
  Widget _buildImagePreviewItem(
    dynamic image,
    int index,
    AutoDisposeStateProvider<List<dynamic>> provider,
  ) {
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
            onTap: () => removeSelectedImage(index, provider),
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
    final clan = ref.watch(clanNotifierProvider);
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    return clan.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(
              icon: Icons.info_outline,
              text: 'Thêm, sửa, xóa các bài viết và nội dung trên trang chủ.',
            ),
            const SizedBox(height: 24),
            _buildVintageTextField(
              controller: nameController,
              label: 'Tên dòng họ',
              icon: Icons.family_restroom_outlined,
              maxLines: isMobile ? 1 : 1,
              keyboardType: TextInputType.text,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: chiController,
              label: 'Chi họ',
              icon: Icons.groups_outlined,
              maxLines: isMobile ? 1 : 1,
              keyboardType: TextInputType.text,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: phoneController,
              label: 'Số điện thoại liên hệ',
              icon: Icons.phone_outlined,
              maxLines: isMobile ? 1 : 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.phone,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: emailController,
              label: 'Email liên hệ',
              icon: Icons.email_outlined,
              maxLines: isMobile ? 1 : 1,
              keyboardType: TextInputType.emailAddress,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: addressController,
              label: 'Địa chỉ nhà thờ họ',
              icon: Icons.home_outlined,
              maxLines: isMobile ? 2 : 1,
              keyboardType: TextInputType.streetAddress,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: sloganController,
              label: 'Khẩu hiệu',
              icon: Icons.campaign_outlined,
              maxLines: isMobile ? 2 : 1,
              keyboardType: TextInputType.text,
              menuAction: MenuAction.manageContent,
            ),
            const SizedBox(height: 16),
            _buildVintageTextField(
              controller: sourceSloganController,
              label: 'Mô tả nguồn gốc',
              icon: Icons.history_edu_outlined,
              maxLines: isMobile ? 4 : 6,
              keyboardType: TextInputType.multiline,
              menuAction: MenuAction.manageContent,
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
            ),
            const SizedBox(height: 16),

            //tiếp phần sourcreUrl - hiển thị 1 ảnh, lấy từ sourceUrlController nếu có
            Builder(
              builder: (context) {
                final src = sourceUrlController.text.trim();
                final hasSource = src.isNotEmpty && src != 'Chưa có ảnh';
                final leftLabel =
                    hasSource ? 'Ảnh trang trí trang chủ' : 'Thêm ảnh';
                final actionText = hasSource ? 'Thay đổi' : 'Thêm ảnh';
                final selected = ref.watch(_selectedManageImageProvider);
                final hasSelected = selected.isNotEmpty;
                final buttonText = hasSelected ? 'Lưu' : actionText;
                final buttonIcon = hasSelected ? Icons.save : Icons.add;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label(
                      labelString: leftLabel,
                      onPressed: () async {
                        if (!hasSelected) {
                          clearSelectedImages(_selectedManageImageProvider);
                          await pickSingleImage(_selectedManageImageProvider);
                        } else {
                          // Upload
                          _uploadSingleImageAndUpdateClan(context, data.first);
                        }
                      },
                      iconData: buttonIcon,
                      textIcon: buttonText,
                    ),
                    const SizedBox(height: 12),
                    // Preview: ưu tiên ảnh đã chọn, nếu không thì dùng sourceUrl, nếu không thì hiển thị placeholder
                    Center(
                      child: Builder(
                        builder: (context) {
                          final selected = ref.watch(
                            _selectedManageImageProvider,
                          );
                          final platform = ref.watch(flatformNotifierProvider);
                          final isMobile = platform == 1;

                          if (selected.isNotEmpty) {
                            final image = selected.first;
                            return _buildSelectedImagePreview(
                              image,
                              isMobile,
                              onRemove:
                                  () => clearSelectedImages(
                                    _selectedManageImageProvider,
                                  ),
                            );
                          }

                          if (hasSource) {
                            return _buildCurrentImagePreview(src, isMobile);
                          }

                          return _buildPlaceholderPreview(isMobile);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            label(
              labelString: 'Các thế hệ',
              onPressed: () {
                _showAddGenerationDialog(
                  null,
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                  ActionGenerationContent.add,
                  data.first,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildListGeneration(data.first.generations!, data.first),
            const SizedBox(height: 16),
            label(
              labelString: 'Các câu chuyện',
              onPressed: () {
                _showAddStoryDialog(
                  null,
                  TextEditingController(),
                  TextEditingController(),
                  TextEditingController(),
                  ActionStory.add,
                  data.first,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildListStory(data.first.stories!, data.first),
            const SizedBox(height: 16),
            ref.watch(_isTaped)
                ? _buildActionButton(
                  icon: Icons.save_outlined,
                  label: 'Lưu thay đổi',
                  onPressed: () async {
                    Clan updatedClan = Clan(
                      id: data.first.id,
                      name: nameController.text,
                      chi: chiController.text,
                      subNameUrl: data.first.subNameUrl,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: addressController.text,
                      slogan: sloganController.text,
                      soucreSolgan: sourceSloganController.text,
                      soucreUrl: data.first.soucreUrl,
                      generations: data.first.generations,
                      stories: data.first.stories,
                      createdAt: data.first.createdAt,
                    );

                    final success = await ref
                        .read(clanNotifierProvider.notifier)
                        .updateClan(data.first.id, updatedClan);
                    if (success) {
                      ref
                          .read(notificationProvider.notifier)
                          .show(
                            'Cập nhật thông tin thành công!',
                            NotificationType.success,
                          );
                      ref.read(_isTaped.notifier).state = false;
                      // nameController.unfocus(context);
                      // chiController.unfocus(context);
                      // phoneController.unfocus(context);
                      // emailController.unfocus(context);
                      // addressController.unfocus(context);
                      // sloganController.unfocus(context);
                      // sourceSloganController.unfocus(context);
                      // addressController.unfocus(context);
                    } else {
                      ref
                          .read(notificationProvider.notifier)
                          .show(
                            'Cập nhật thông tin thất bại!',
                            NotificationType.error,
                          );
                    }
                    ;
                  },
                )
                : const SizedBox.shrink(),
          ],
        );
      },
      error: (error, stackTrace) => CircularProgressIndicator(),
      loading: () => CircularProgressIndicator(),
    );
  }

  /// Xây dựng danh sách thế hệ
  Widget _buildListGeneration(List<Generation> generations, Clan clan) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    if (generations.isEmpty) {
      return Text(
        'Chưa có thế hệ nào.',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 13,
          color: AppColors.mutedText,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: generations.length,
        itemBuilder: (context, index) {
          final generation = generations[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.bronzeBorder.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: AppColors.goldBorder.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldBorder.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.account_tree_outlined,
                          size: 18,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            generation.title,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 14,
                              color: AppColors.darkBrown,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            generation.name,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              color: AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            generation.year,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vintageIvory.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.bronzeBorder.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: AppColors.mutedText,
                                size: 18,
                              ),
                              onPressed: () {
                                _showAddGenerationDialog(
                                  generation.id,
                                  TextEditingController(text: generation.title),
                                  TextEditingController(text: generation.name),
                                  TextEditingController(text: generation.year),
                                  ActionGenerationContent.edit,
                                  clan,
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
                                _showAddGenerationDialog(
                                  generation.id,
                                  TextEditingController(text: generation.title),
                                  TextEditingController(text: generation.name),
                                  TextEditingController(text: generation.year),
                                  ActionGenerationContent.delete,
                                  clan,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vintageIvory.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.bronzeBorder.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: AppColors.mutedText,
                              size: 18,
                            ),
                            onPressed: () {
                              _showAddGenerationDialog(
                                generation.id,
                                TextEditingController(text: generation.title),
                                TextEditingController(text: generation.name),
                                TextEditingController(text: generation.year),
                                ActionGenerationContent.edit,
                                clan,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outlined,
                              color: AppColors.mutedText,
                              size: 18,
                            ),
                            onPressed: () {
                              _showAddGenerationDialog(
                                generation.id,
                                TextEditingController(text: generation.title),
                                TextEditingController(text: generation.name),
                                TextEditingController(text: generation.year),
                                ActionGenerationContent.delete,
                                clan,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ///Xây dựng danh sách câu chuyện
  Widget _buildListStory(List<Story> stories, Clan clan) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    if (stories.isEmpty) {
      return Text(
        'Chưa có câu chuyện nào.',
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 13,
          color: AppColors.mutedText,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.bronzeBorder.withOpacity(0.08),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: AppColors.goldBorder.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.goldBorder.withOpacity(0.2),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.duration,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 14,
                              color: AppColors.darkBrown,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.title,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 13,
                              color: AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            story.description,
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 12,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vintageIvory.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.bronzeBorder.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: AppColors.mutedText,
                                size: 18,
                              ),
                              onPressed: () {
                                _showAddStoryDialog(
                                  story.id,
                                  TextEditingController(text: story.duration),
                                  TextEditingController(text: story.title),
                                  TextEditingController(
                                    text: story.description,
                                  ),
                                  ActionStory.edit,
                                  clan,
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
                                _showAddStoryDialog(
                                  story.id,
                                  TextEditingController(text: story.duration),
                                  TextEditingController(text: story.title),
                                  TextEditingController(
                                    text: story.description,
                                  ),
                                  ActionStory.delete,
                                  clan,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vintageIvory.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.bronzeBorder.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: AppColors.mutedText,
                              size: 18,
                            ),
                            onPressed: () {
                              _showAddStoryDialog(
                                story.id,
                                TextEditingController(text: story.duration),
                                TextEditingController(text: story.title),
                                TextEditingController(text: story.description),
                                ActionStory.edit,
                                clan,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outlined,
                              color: AppColors.mutedText,
                              size: 18,
                            ),
                            onPressed: () {
                              _showAddStoryDialog(
                                story.id,
                                TextEditingController(text: story.duration),
                                TextEditingController(text: story.title),
                                TextEditingController(text: story.description),
                                ActionStory.delete,
                                clan,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddStoryDialog(
    int? id,
    TextEditingController durationController,
    TextEditingController titleController,
    TextEditingController descriptionController,
    ActionStory actionStory,
    Clan clan,
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
                    Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      actionStory == ActionStory.add
                          ? 'Thêm câu chuyện'
                          : actionStory == ActionStory.edit
                          ? 'Chỉnh sửa câu chuyện'
                          : 'Xóa câu chuyện',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    _buildVintageTextField(
                      controller: durationController,
                      label: 'Thời gian (VD: 1900-1950)',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageContent,
                    ),
                    const SizedBox(height: 16),
                    _buildVintageTextField(
                      controller: titleController,
                      label: 'Tiêu đề',
                      icon: Icons.title,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageContent,
                    ),
                    const SizedBox(height: 16),
                    _buildVintageTextField(
                      controller: descriptionController,
                      label: 'Mô tả',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageContent,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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

                                if (actionStory != ActionStory.delete &&
                                    (durationController.text.isEmpty ||
                                        titleController.text.isEmpty ||
                                        descriptionController.text.isEmpty)) {
                                  ref
                                      .read(notificationProvider.notifier)
                                      .show(
                                        'Nhập đủ thông tin câu chuyện!',
                                        NotificationType.error,
                                      );
                                  return;
                                }

                                ref.read(_isFocus.notifier).state = true;

                                try {
                                  final clanId = ref.watch(clanIdProvider);
                                  switch (actionStory) {
                                    case ActionStory.add:
                                      final newStory = Story.create(
                                        duration: durationController.text,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                      );
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations: clan.generations,
                                        stories: [...?clan.stories, newStory],
                                        createdAt: clan.createdAt,
                                      );
                                      final successAdd = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);
                                      if (successAdd && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Thêm câu chuyện thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                      }
                                      break;
                                    case ActionStory.edit:
                                      final updatedStory = Story(
                                        id: id!,
                                        duration: durationController.text,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                      );
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations: clan.generations,
                                        stories:
                                            clan.stories!.map((e) {
                                              if (e.id == id)
                                                return updatedStory;
                                              return e;
                                            }).toList(),
                                        createdAt: clan.createdAt,
                                      );
                                      final successEdit = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);
                                      if (successEdit && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Cập nhật câu chuyện thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                      }
                                      break;
                                    case ActionStory.delete:
                                      final deletedStory = Story(
                                        id: id!,
                                        duration: durationController.text,
                                        title: titleController.text,
                                        description: descriptionController.text,
                                      );
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations: clan.generations,
                                        stories:
                                            clan.stories!.contains(deletedStory)
                                                ? clan.stories!
                                                    .where((e) => e.id != id)
                                                    .toList()
                                                : clan.stories!,
                                        createdAt: clan.createdAt,
                                      );
                                      final successDel = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);
                                      if (successDel && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Xóa câu chuyện thành công!',
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
                                          'Lỗi câu chuyện : $e',
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
                                actionStory == ActionStory.add
                                    ? 'Thêm'
                                    : actionStory == ActionStory.edit
                                    ? 'Lưu'
                                    : 'Xóa',
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

  void _showAddGenerationDialog(
    int? id,
    TextEditingController titleMCController,
    TextEditingController nameMCController,
    TextEditingController yearMCController,
    ActionGenerationContent actionGenerationContent,
    Clan clan,
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
                      actionGenerationContent == ActionGenerationContent.add
                          ? 'Thêm thế hệ Mới'
                          : actionGenerationContent ==
                              ActionGenerationContent.edit
                          ? 'Chỉnh sửa thế hệ'
                          : 'Xóa thế hệ',
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
                      controller: titleMCController,
                      label: 'Thứ tự thế hệ (VD: Thế hệ thứ 1-5)',
                      icon: Icons.title,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageAlbums,
                    ),
                    const SizedBox(height: 16),
                    // Mô tả
                    _buildVintageTextField(
                      controller: nameMCController,
                      label: 'Tên gọi thế hệ (VD: Tiền thân)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageAlbums,
                    ),
                    const SizedBox(height: 16),
                    // Năm
                    _buildVintageTextField(
                      controller: yearMCController,
                      label: 'Giai đoạn (VD: 1300-1350)',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.phone,
                      menuAction: MenuAction.manageAlbums,
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

                                if (actionGenerationContent !=
                                        ActionGenerationContent.delete &&
                                    (titleMCController.text.isEmpty ||
                                        nameMCController.text.isEmpty ||
                                        yearMCController.text.isEmpty)) {
                                  ref
                                      .read(notificationProvider.notifier)
                                      .show(
                                        'Nhập đủ thông tin thế hệ!',
                                        NotificationType.error,
                                      );
                                  return;
                                }

                                ref.read(_isFocus.notifier).state = true;

                                try {
                                  switch (actionGenerationContent) {
                                    case ActionGenerationContent.add:
                                      final newGeneration = Generation.create(
                                        title: titleMCController.text,
                                        name: nameMCController.text,
                                        year: yearMCController.text,
                                      );
                                      final clanId = ref.watch(clanIdProvider);
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations: [
                                          ...?clan.generations,
                                          newGeneration,
                                        ],
                                        stories: clan.stories,
                                        createdAt: clan.createdAt,
                                      );
                                      final success = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);

                                      if (success && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Thêm thế hệ thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                        titleMCController.clear();
                                        nameMCController.clear();
                                        yearMCController.clear();
                                      }
                                      break;
                                    case ActionGenerationContent.edit:
                                      final updatedGeneration = Generation(
                                        id: id!,
                                        title: titleMCController.text,
                                        name: nameMCController.text,
                                        year: yearMCController.text,
                                      );
                                      final clanId = ref.watch(clanIdProvider);
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations:
                                            clan.generations!.map((e) {
                                              if (e.id == id) {
                                                return updatedGeneration;
                                              }
                                              return e;
                                            }).toList(),
                                        stories: clan.stories,
                                        createdAt: clan.createdAt,
                                      );
                                      final success = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);

                                      if (success && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Cập nhật thế hệ thành công!',
                                              NotificationType.success,
                                            );
                                        Navigator.pop(context);
                                        titleMCController.clear();
                                        nameMCController.clear();
                                        yearMCController.clear();
                                      }
                                      break;

                                    case ActionGenerationContent.delete:
                                      final deletedGeneration = Generation(
                                        id: id!,
                                        title: titleMCController.text,
                                        name: nameMCController.text,
                                        year: yearMCController.text,
                                      );
                                      final clanId = ref.watch(clanIdProvider);
                                      final updateClan = Clan(
                                        id: clan.id,
                                        name: clan.name,
                                        chi: clan.chi,
                                        subNameUrl: clan.subNameUrl,
                                        address: clan.address,
                                        phone: clan.phone,
                                        email: clan.email,
                                        slogan: clan.slogan,
                                        soucreSolgan: clan.soucreSolgan,
                                        soucreUrl: clan.soucreUrl,
                                        generations:
                                            clan.generations!.contains(
                                                  deletedGeneration,
                                                )
                                                ? clan.generations!
                                                    .where((e) => e.id != id)
                                                    .toList()
                                                : clan.generations!,
                                        stories: clan.stories,
                                        createdAt: clan.createdAt,
                                      );
                                      final response = await ref
                                          .read(clanNotifierProvider.notifier)
                                          .updateClan(clanId, updateClan);

                                      if (response && mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .show(
                                              'Xóa thế hệ thành công!',
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
                                          'Lỗi thế hệ : $e',
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
                                actionGenerationContent ==
                                        ActionGenerationContent.add
                                    ? 'Thêm'
                                    : actionGenerationContent ==
                                        ActionGenerationContent.edit
                                    ? 'Lưu'
                                    : 'Xóa',
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

  //hiển thị dialog chọn album đích
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
                                    _uploadSelectedImages(
                                      selectedAlbum.id,
                                      _selectedImagesProvider,
                                    );
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
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageAlbums,
                    ),
                    const SizedBox(height: 16),
                    // Mô tả
                    _buildVintageTextField(
                      controller: descriptionController,
                      label: 'Mô tả',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      keyboardType: TextInputType.text,
                      menuAction: MenuAction.manageAlbums,
                    ),
                    const SizedBox(height: 16),
                    // Năm
                    _buildVintageTextField(
                      controller: yearController,
                      label: 'Năm (VD: 2024)',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.phone,
                      menuAction: MenuAction.manageAlbums,
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
    required MenuAction menuAction,
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
        onChanged: (value) {
          if (menuAction == MenuAction.manageContent) {
            ref.read(_isTaped.notifier).state =
                value.trim() !=
                ref.read(clanNotifierProvider).whenData((value) {
                  switch (label) {
                    case 'Tên dòng họ':
                      return value.first.name;
                    case 'Chi họ':
                      return value.first.chi;
                    case 'Số điện thoại liên hệ':
                      return value.first.phone ?? '';
                    case 'Email liên hệ':
                      return value.first.email ?? '';
                    case 'Địa chỉ nhà thờ họ':
                      return value.first.address ?? '';
                    case 'Khẩu hiệu':
                      return value.first.slogan ?? '';
                    case 'Mô tả nguồn gốc':
                      return value.first.soucreSolgan ?? '';
                    default:
                      return '';
                  }
                }).value;
          }
        },
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
          // Icon(icon, color: AppColors.deepGreen, size: 24),
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

  /// Widget preview cho ảnh đã chọn
  Widget _buildSelectedImagePreview(
    dynamic image,
    bool isMobile, {
    required VoidCallback onRemove,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isMobile ? 180 : 220,
      width: isMobile ? 180 : 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.vintageIvory.withOpacity(0.4),
                  AppColors.creamPaper.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            color: AppColors.vintageIvory.withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.deepGreen,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Container(
                            color: AppColors.vintageIvory.withOpacity(0.3),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.mutedText,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
          ),
          // Overlay with label
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.image, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ảnh mới đã chọn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget preview cho ảnh hiện tại
  Widget _buildCurrentImagePreview(String imageUrl, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isMobile ? 180 : 220,
      width: isMobile ? 180 : 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.vintageIvory.withOpacity(0.3),
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.vintageIvory.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                      color: AppColors.deepGreen,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.vintageIvory.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.mutedText,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải ảnh',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Overlay with label
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.deepGreen.withOpacity(0.8),
                    AppColors.deepGreen.withOpacity(0.4),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ảnh trang trí hiện tại',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  /// Widget placeholder khi chưa có ảnh
  Widget _buildPlaceholderPreview(bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isMobile ? 120 : 140,
      width: isMobile ? 120 : 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 2,
        ),
        color: AppColors.vintageIvory.withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              color: AppColors.mutedText,
              size: isMobile ? 32 : 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có ảnh trang trí',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: isMobile ? 12 : 14,
                color: AppColors.mutedText,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chọn ảnh để thay đổi',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: AppColors.mutedText.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
