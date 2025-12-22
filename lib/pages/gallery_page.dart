import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/providers/album_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

/// Trang thư viện hình ảnh gia phả với phong cách vintage 1990s
///
/// Hiển thị các album ảnh gia đình theo phong cách nostalgic
/// như những cuốn album ảnh cũ, polaroid, khung ảnh gỗ

// StateProvider cho hover index
final _hoveredIndexProvider = StateProvider.autoDispose<int?>((ref) => null);

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Dữ liệu mẫu cho các album
  // final Set<dynamic> _albums = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      index: 3,
      child: Container(
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

              // Gallery Grid - Watch state trực tiếp
              Consumer(
                builder: (context, ref, child) {
                  final platform = ref.watch(flatformNotifierProvider);
                  final isMobile = platform == 1;

                  // No data state
                  // if (albums.isEmpty) {
                  //   return Padding(
                  //     padding: EdgeInsets.all(isMobile ? 10 : 32),
                  //     child: Center(
                  //       child: Text(
                  //         'Chưa có album nào',
                  //         style: TextStyle(
                  //           fontFamily: 'serif',
                  //           color: AppColors.mutedText,
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // }
                  final albums = ref.watch(albumNotifierProvider);

                  return albums.when(
                    loading:
                        () => Padding(
                          padding: EdgeInsets.all(isMobile ? 10 : 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.deepGreen,
                              ),
                            ),
                          ),
                        ),
                    error:
                        (error, stack) => Padding(
                          padding: EdgeInsets.all(isMobile ? 10 : 32),
                          child: Center(
                            child: Text(
                              'Lỗi tải album: $error',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: AppColors.mutedText,
                              ),
                            ),
                          ),
                        ),
                    data: (albums) {
                      if (albums.isEmpty) {
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
                        return Padding(
                          padding: EdgeInsets.all(isMobile ? 10 : 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _getCrossAxisCount(
                                        context,
                                      ),
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                    ),
                                itemCount: albums.length,
                                itemBuilder: (context, index) {
                                  // ignore: unnecessary_cast
                                  final album = albums[index] as Album;
                                  return _buildAlbumCard(album, index);
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),

              // Vintage Footer Note
              _buildFooterNote(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Xác định số cột dựa trên platform
  int _getCrossAxisCount(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    if (platform == 3) return 3; // Desktop
    if (platform == 2) return 2; // Tablet
    return 1; // Mobile
  }

  /// Xây dựng header với phong cách vintage
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
          // Decorative top line
          Container(
            height: 2,
            width: 150,
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [
              //     Colors.transparent,
              //     AppColors.goldBorder,
              //     Colors.transparent,
              //   ],
              // ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'THƯ VIỆN KỶ NIỆM',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isMobile ? 28 : 48,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrown,
              letterSpacing: 6,
              shadows: [
                Shadow(
                  color: AppColors.sepiaTone.withOpacity(0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Những khoảnh khắc đáng nhớ của gia tộc',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppColors.mutedText,
              letterSpacing: 1,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Decorative bottom line
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

  /// Xây dựng card album với hiệu ứng hover
  Widget _buildAlbumCard(Album album, int index) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    return Consumer(
      builder: (context, ref, child) {
        final hoveredIndex = ref.watch(_hoveredIndexProvider);
        final isHovered = hoveredIndex == index;

        return MouseRegion(
          onEnter:
              (_) => ref.read(_hoveredIndexProvider.notifier).state = index,
          onExit: (_) => ref.read(_hoveredIndexProvider.notifier).state = null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform:
                Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.creamPaper,
                      AppColors.vintageIvory,
                      AppColors.warmBeige.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isHovered
                            ? AppColors.goldBorder
                            : AppColors.bronzeBorder.withOpacity(0.5),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isHovered
                              ? AppColors.sepiaTone.withOpacity(0.4)
                              : AppColors.sepiaTone.withOpacity(0.2),
                      blurRadius: isHovered ? 16 : 12,
                      offset: Offset(0, isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Corner decorations
                    ..._buildCornerDecorations(),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with vintage background
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.sepiaTone.withOpacity(0.2),
                                    AppColors.bronzeBorder.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.goldBorder.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.photo_sharp,
                                size: isMobile ? 24 : 48,
                                color: AppColors.deepGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Center(
                            child: Text(
                              album.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBrown,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Divider
                          Center(
                            child: Container(
                              height: 1,
                              width: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.bronzeBorder.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Year
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.vintageIvory.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.bronzeBorder.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                album.year,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description
                          Center(
                            child: Text(
                              album.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 14,
                                color: AppColors.mutedText,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // View button
                          Center(
                            child: InkWell(
                              onTap: () {
                                // Navigate với album ID trong URL
                                AppRouter.goNamed(
                                  context,
                                  'gallery-detail',
                                  pathParameters: {
                                    'albumId': album.id.toString(),
                                  },
                                  extra: album,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.sepiaTone,
                                      AppColors.bronzeBorder,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.softShadow,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Xem Album',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        color: AppColors.creamPaper,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: AppColors.creamPaper,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tạo các góc trang trí vintage cho card
  List<Widget> _buildCornerDecorations() {
    return [
      // Top left
      Positioned(
        top: 8,
        left: 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.bronzeBorder, width: 2),
              left: BorderSide(color: AppColors.bronzeBorder, width: 2),
            ),
          ),
        ),
      ),
      // Top right
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.bronzeBorder, width: 2),
              right: BorderSide(color: AppColors.bronzeBorder, width: 2),
            ),
          ),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 8,
        left: 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.bronzeBorder, width: 2),
              left: BorderSide(color: AppColors.bronzeBorder, width: 2),
            ),
          ),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 8,
        right: 8,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.bronzeBorder, width: 2),
              right: BorderSide(color: AppColors.bronzeBorder, width: 2),
            ),
          ),
        ),
      ),
    ];
  }

  /// Xây dựng ghi chú cuối trang
  Widget _buildFooterNote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.deepGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Những bức ảnh này là tài sản quý giá của gia tộc, hãy giữ gìn và trân trọng.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 14,
                color: AppColors.mutedText,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
