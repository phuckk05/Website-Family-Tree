import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/family_member.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/family_tree_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

// StateProvider cho giới tính trong edit dialog
final _editDialogGenderProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

// StateProvider cho giới tính trong add child dialog
final _addChildDialogGenderProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

/// Trang này cho phép:
/// - Xem toàn bộ cây gia phả dạng cây phả hệ
/// - Phóng to/thu nhỏ và di chuyển xung quanh cây
/// - Tìm kiếm thành viên trong gia phả
/// - Thêm, sửa, xóa thành viên (nếu đã đăng nhập)
/// - Thêm vợ/chồng cho thành viên
class FamilyTreePage extends ConsumerStatefulWidget {
  const FamilyTreePage({super.key});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

/// State của FamilyTreePage với khả năng animation
class _FamilyTreePageState extends ConsumerState<FamilyTreePage>
    with SingleTickerProviderStateMixin {
  /// Controller để điều khiển việc zoom và pan của InteractiveViewer
  final TransformationController _transformationController =
      TransformationController();

  /// Controller cho ô tìm kiếm thành viên
  final TextEditingController _searchController = TextEditingController();

  /// Key để xác định vị trí của tree content trong layout
  final GlobalKey _treeContentKey = GlobalKey();

  /// Controller cho animation khi zoom đến một node
  late AnimationController _animationController;

  /// Flag để kiểm tra đã focus vào root node lần đầu chưa
  bool _hasInitialFocused = false;

  //Lấy id clan hiện tại để update

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Zoom và di chuyển camera đến một node cụ thể trong cây gia phả
  ///
  /// [memberId] ID của thành viên cần focus đến
  void _zoomToNode(String memberId) {
    // Đợi frame render xong mới tìm được vị trí
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nodeContext = GlobalObjectKey(memberId).currentContext;
      final treeContext = _treeContentKey.currentContext;

      if (nodeContext != null && treeContext != null) {
        final nodeBox = nodeContext.findRenderObject() as RenderBox;
        final treeBox = treeContext.findRenderObject() as RenderBox;

        // Vị trí của node so với góc trái trên của tree content
        final nodeOffset = nodeBox.localToGlobal(
          Offset.zero,
          ancestor: treeBox,
        );
        final nodeSize = nodeBox.size;

        // Tâm của node
        final nodeCenter =
            nodeOffset + Offset(nodeSize.width / 2, nodeSize.height / 2);

        // Kích thước viewport
        final renderBox = context.findRenderObject() as RenderBox;
        final viewportSize = renderBox.size;

        // Scale mong muốn
        const double scale = 1.0;

        // Tính toán translation
        final viewportCenter = Offset(
          viewportSize.width / 2,
          viewportSize.height / 2,
        );

        final translation = viewportCenter - nodeCenter * scale;

        final matrix =
            Matrix4.identity()
              ..translate(translation.dx, translation.dy)
              ..scale(scale);

        // Reset animation cũ nếu đang chạy
        _animationController.reset();

        final animation = Matrix4Tween(
          begin: _transformationController.value,
          end: matrix,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );

        animation.addListener(() {
          _transformationController.value = animation.value;
        });

        _animationController.forward();
      } else {
        debugPrint("Không tìm thấy node context cho $memberId");
      }
    });
  }

  /// Tìm kiếm ID của thành viên theo tên
  ///
  /// Tìm kiếm đрекурсивно trong cây gia phả
  /// [node] Node gốc để bắt đầu tìm kiếm
  /// [name] Tên hoặc một phần tên cần tìm (không phân biệt hoa thường)
  ///
  /// Returns: ID của thành viên nếu tìm thấy, null nếu không tìm thấy
  String? _findMemberIdByName(FamilyMember node, String name) {
    if (node.name.toLowerCase().contains(name.toLowerCase())) {
      return node.id;
    }
    for (final child in node.children) {
      final foundId = _findMemberIdByName(child, name);
      if (foundId != null) return foundId;
    }
    return null;
  }

  /// Phóng to cây gia phả (zoom in) theo tỷ lệ 1.2x
  /// Zoom vào tâm của viewport hiện tại
  void _zoomIn() {
    final renderBox = context.findRenderObject() as RenderBox;
    final viewportSize = renderBox.size;
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);

    final matrix = _transformationController.value;
    final newMatrix =
        Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..scale(1.2)
          ..translate(-center.dx, -center.dy)
          ..multiply(matrix);

    _transformationController.value = newMatrix;
  }

  /// Thu nhỏ cây gia phả (zoom out) theo tỷ lệ 0.8x
  /// Zoom ra từ tâm của viewport hiện tại
  void _zoomOut() {
    final renderBox = context.findRenderObject() as RenderBox;
    final viewportSize = renderBox.size;
    final center = Offset(viewportSize.width / 2, viewportSize.height / 2);

    final matrix = _transformationController.value;
    final newMatrix =
        Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..scale(0.8)
          ..translate(-center.dx, -center.dy)
          ..multiply(matrix);

    _transformationController.value = newMatrix;
  }

  @override
  Widget build(BuildContext context) {
    final rootMemberAsync = ref.watch(familyTreeProvider);

    // Tự động focus vào root khi load xong lần đầu
    if (rootMemberAsync.hasValue && !_hasInitialFocused) {
      final root = rootMemberAsync.value!;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _zoomToNode(root.id);
        }
      });
      _hasInitialFocused = true;
    }

    void handleSearch() {
      final value = _searchController.text;
      if (rootMemberAsync.hasValue && value.isNotEmpty) {
        final root = rootMemberAsync.value!;
        final foundId = _findMemberIdByName(root, value);
        if (foundId != null) {
          _zoomToNode(foundId);
          ref
              .read(notificationProvider.notifier)
              .show(
                'Đã tìm thấy thành viên "$value"',
                NotificationType.success,
              );
        } else {
          ref
              .read(notificationProvider.notifier)
              .show(
                'Không tìm thấy thành viên "$value"!',
                NotificationType.error,
              );
        }
      }
    }

    return MainLayout(
      enableScroll: false,
      index: 2,
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
        child: Column(
          children: [
            // Nostalgic Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                color: AppColors.creamPaper.withOpacity(0.9),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.bronzeBorder.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: [_buildVintageSearchBar(handleSearch)]),
            ),
            // Tree View with old paper texture
            Expanded(
              child: Stack(
                children: [
                  // Background texture overlay
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZmlsdGVyIGlkPSJub2lzZSI+PGZlVHVyYnVsZW5jZSB0eXBlPSJmcmFjdGFsTm9pc2UiIGJhc2VGcmVxdWVuY3k9IjAuOSIgbnVtT2N0YXZlcz0iNCIvPjwvZmlsdGVyPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbHRlcj0idXJsKCNub2lzZSkiIG9wYWNpdHk9IjAuMDMiLz48L3N2Zz4=',
                        ),
                        repeat: ImageRepeat.repeat,
                        opacity: 0.4,
                      ),
                    ),
                  ),
                  rootMemberAsync.when(
                    data:
                        (rootMember) => InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(5000),
                          minScale: 0.01,
                          maxScale: 5.0,
                          constrained: false,
                          child: Padding(
                            key: _treeContentKey,
                            padding: const EdgeInsets.all(500.0),
                            child: _buildTree(rootMember),
                          ),
                        ),
                    error:
                        (err, stack) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.creamPaper,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.burgundyAccent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'Lỗi tải phả hệ: $err',
                              style: TextStyle(
                                color: AppColors.burgundyAccent,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                        ),
                    loading:
                        () => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.sepiaTone,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Đang tải phả hệ...',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  color: AppColors.mutedText,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                  // Vintage Floating Controls
                  Positioned(
                    bottom: ref.watch(flatformNotifierProvider) == 1 ? 5 : 24,
                    right: ref.watch(flatformNotifierProvider) == 1 ? 5 : 24,
                    child: _buildVintageControls(rootMemberAsync),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng thanh tìm kiếm với phong cách vintage
  ///
  /// Bao gồm ô nhập liệu và nút tìm kiếm với style cổ điển
  /// [handleSearch] Callback được gọi khi người dùng bấm tìm kiếm
  Widget _buildVintageSearchBar(VoidCallback handleSearch) {
    final isMobile =
        ref.watch(flatformNotifierProvider) == 1 ||
        ref.watch(flatformNotifierProvider) == 2;

    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.vintageIvory,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.bronzeBorder.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => handleSearch(),
                style: TextStyle(
                  fontFamily: 'serif',
                  color: AppColors.darkBrown,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm tên...',
                  hintStyle: TextStyle(
                    fontFamily: 'serif',
                    color: AppColors.lightText,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: AppColors.sepiaTone),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.sepiaTone, AppColors.bronzeBorder],
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
            child: ElevatedButton(
              onPressed: handleSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Tìm kiếm',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: AppColors.creamPaper,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng panel điều khiển nổi (zoom in/out, reset) với phong cách vintage
  ///
  /// Hiển thị ở góc dưới bên phải với các nút zoom và reset
  /// [rootMemberAsync] Async value của root member để biết khi nào có thể reset
  Widget _buildVintageControls(AsyncValue<FamilyMember?> rootMemberAsync) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamPaper.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldBorder.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVintageControlButton(Icons.add, _zoomIn, 'Phóng to'),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: 32,
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
          const SizedBox(height: 8),
          _buildVintageControlButton(Icons.remove, _zoomOut, 'Thu nhỏ'),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: 32,
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
          const SizedBox(height: 8),
          _buildVintageControlButton(Icons.home_outlined, () {
            if (rootMemberAsync.hasValue) {
              _zoomToNode(rootMemberAsync.value!.id);
            } else {
              _transformationController.value = Matrix4.identity();
            }
          }, 'Về đầu'),
        ],
      ),
    );
  }

  /// Xây dựng một nút điều khiển vintage (zoom/reset)
  ///
  /// [icon] Icon hiển thị trên nút
  /// [onPressed] Callback khi nút được bấm
  /// [tooltip] Chú thích hiển thị khi hover
  Widget _buildVintageControlButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sepiaTone, AppColors.bronzeBorder],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.creamPaper, size: 22),
          ),
        ),
      ),
    );
  }

  // Widget _buildZoomButton(
  //   IconData icon,
  //   VoidCallback onPressed,
  //   String tooltip,
  // ) {
  //   return Tooltip(
  //     message: tooltip,
  //     child: InkWell(
  //       onTap: onPressed,
  //       borderRadius: BorderRadius.circular(20),
  //       child: Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: AppColors.woodBrown,
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.2),
  //               blurRadius: 2,
  //               offset: const Offset(1, 1),
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, color: AppColors.ivoryWhite, size: 20),
  //       ),
  //     ),
  //   );
  // }

  /// Xây dựng cây gia phả từ một thành viên (recursive)
  ///
  /// Hiển thị thành viên và tất cả con cháu của họ dưới dạng cây
  /// [member] Thành viên gốc của cây con này
  /// [depth] Độ sâu hiện tại trong cây (bắt đầu từ 1)
  Widget _buildTree(FamilyMember member, {int depth = 1}) {
    return Column(
      children: [
        // Node thành viên
        _buildNodeCard(member, depth: depth),

        // Vẽ đường nối và con cái
        if (member.children.isNotEmpty) ...[
          CustomPaint(size: const Size(2, 20), painter: VerticalLinePainter()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                member.children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final count = member.children.length;
                  return _buildSubTree(child, index, count, depth + 1);
                }).toList(),
          ),
        ],
      ],
    );
  }

  /// Xây dựng một cây con với đường nối connector
  ///
  /// [member] Thành viên gốc của cây con
  /// [index] Vị trí của cây con này trong danh sách anh chị em
  /// [count] Tổng số anh chị em
  /// [depth] Độ sâu trong cây
  Widget _buildSubTree(FamilyMember member, int index, int count, int depth) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            size: const Size(0, 20),
            painter: ConnectorPainter(index: index, count: count),
          ),
          _buildTree(member, depth: depth),
        ],
      ),
    );
  }

  /// Xây dựng card thông tin cho một thành viên với phong cách vintage
  ///
  /// Hiển thị tên, vợ/chồng, năm sinh với style cổ điển
  /// Từ đời thứ 5 trở đi sẽ hiển thị dọc thay vì ngang
  /// [member] Thông tin thành viên cần hiển thị
  /// [depth] Độ sâu của thành viên trong cây (để xác định layout)
  Widget _buildNodeCard(FamilyMember member, {int depth = 1}) {
    // Kiểm tra nếu là đời thứ 5 trở đi
    final isVerticalNode = depth >= 5;

    // Kích thước node
    final double width = isVerticalNode ? 95.0 : 200.0;
    final double height = isVerticalNode ? 320.0 : 110.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: InkWell(
          key: GlobalObjectKey(member.id),
          onTap: () => _showActionMenu(context, member),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.creamPaper,
                  AppColors.vintageIvory,
                  AppColors.warmBeige.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.goldBorder, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sepiaTone.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(-1, -1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Vintage corner decorations
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                        right: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                        right: BorderSide(
                          color: AppColors.bronzeBorder,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      isVerticalNode
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Tên vợ/chồng (Xoay dọc)
                                  if (member.spouses.isNotEmpty) ...[
                                    RotatedBox(
                                      quarterTurns: 1,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 220,
                                        ),
                                        child: Text(
                                          member.spouses.join(', '),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.mutedText,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'serif',
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  // Tên thành viên (Xoay dọc 90 độ)
                                  RotatedBox(
                                    quarterTurns: 1,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 220,
                                      ),
                                      child: Text(
                                        member.name.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.darkBrown,
                                          fontFamily: 'serif',
                                          letterSpacing: 1.2,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Tên thành viên
                              Center(
                                child: Text(
                                  member.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.darkBrown,
                                    height: 1.3,
                                    fontFamily: 'serif',
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Tên vợ/chồng (nếu có)
                              if (member.spouses.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  height: 1,
                                  width: 40,
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
                                const SizedBox(height: 6),
                                Center(
                                  child: Text(
                                    member.spouses.join(' • '),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.mutedText,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'serif',
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              // Birth year if available
                              if (member.birthDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    member.birthDate,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.lightText,
                                      fontFamily: 'serif',
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hiển thị menu hành động khi click vào thẻ thành viên
  ///
  /// Menu hiển thị các tùy chọn:
  /// - Xem chi tiết (luôn hiển thị)
  /// - Thêm con, Thêm vợ/chồng, Sửa, Xóa (chỉ khi đăng nhập)
  /// [context] BuildContext của widget
  /// [member] Thành viên được chọn
  void _showActionMenu(BuildContext context, FamilyMember member) {
    final isLoggedIn = ref.read(authProvider).value ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.creamPaper, AppColors.warmBeige],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.goldBorder, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bronzeBorder.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!isLoggedIn)
                _buildVintageMenuItem(
                  Icons.visibility_outlined,
                  'Xem chi tiết',
                  () {
                    Navigator.pop(context);
                    _showViewDialog(member);
                  },
                )
              else ...[
                _buildVintageMenuItem(
                  Icons.person_add_outlined,
                  'Thêm đời sau',
                  () {
                    Navigator.pop(context);
                    _showAddChildDialog(member);
                  },
                ),
                _buildVintageMenuItem(
                  Icons.favorite_border,
                  'Thêm vợ/chồng',
                  () {
                    Navigator.pop(context);
                    _showAddSpouseDialog(member);
                  },
                ),
                _buildVintageMenuItem(Icons.edit_outlined, 'Sửa thông tin', () {
                  Navigator.pop(context);
                  _showEditDialog(member);
                }),
                _buildVintageMenuItem(
                  Icons.delete_outline,
                  'Xóa thành viên',
                  () {
                    Navigator.pop(context);
                    _confirmDelete(member);
                  },
                  isDestructive: true,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Xây dựng một item menu với phong cách vintage
  ///
  /// [icon] Icon hiển thị bên trái
  /// [title] Tiêu đề của menu item
  /// [onTap] Callback khi item được chọn
  /// [isDestructive] Có phải là hành động nguy hiểm (ví dụ: xóa) không
  Widget _buildVintageMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.vintageIvory.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isDestructive
                    ? AppColors.burgundyAccent.withOpacity(0.3)
                    : AppColors.bronzeBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isDestructive
                      ? AppColors.burgundyAccent
                      : AppColors.deepGreen,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                color:
                    isDestructive
                        ? AppColors.burgundyAccent
                        : AppColors.darkBrown,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog xem chi tiết thông tin thành viên (chỉ đọc)
  ///
  /// Hiển thị tất cả thông tin của thành viên theo phong cách vintage
  /// [member] Thành viên cần xem thông tin
  void _showViewDialog(FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
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
                  Text(
                    'THÔNG TIN CHI TIẾT',
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
                  _buildInfoRow('Họ và tên', member.name),
                  _buildInfoRow('Vai trò', member.role),
                  _buildInfoRow('Năm sinh', member.birthDate),
                  _buildInfoRow('Thứ tự', member.order.toString()),
                  _buildInfoRow('Vợ/Chồng', member.spouses.join(', ')),
                  _buildInfoRow('Giới tính', member.isMale ? 'Nam' : 'Nữ'),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.sepiaTone, AppColors.bronzeBorder],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: AppColors.creamPaper,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
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

  /// Xây dựng một dòng thông tin trong dialog xem chi tiết
  ///
  /// Hiển thị nhãn và giá trị theo phong cách vintage
  /// [label] Nhãn (ví dụ: "Họ và tên")
  /// [value] Giá trị cần hiển thị
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog chỉnh sửa thông tin thành viên
  ///
  /// Cho phép chỉnh sửa tên, vai trò, năm sinh, thứ tự, vợ/chồng và giới tính
  /// [member] Thành viên cần chỉnh sửa
  void _showEditDialog(FamilyMember member) {
    final nameController = TextEditingController(text: member.name);
    final roleController = TextEditingController(text: member.role);
    final birthDateController = TextEditingController(text: member.birthDate);
    final orderController = TextEditingController(
      text: member.order.toString(),
    );
    final spousesController = TextEditingController(
      text: member.spouses.join(', '),
    );
    showDialog(
      context: context,
      builder:
          (context) => Consumer(
            builder: (context, ref, child) {
              // Khởi tạo giá trị ban đầu
              ref.read(_editDialogGenderProvider.notifier).state =
                  member.isMale;
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 550),
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
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SỬA THÔNG TIN',
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
                            controller: nameController,
                            label: 'Họ và tên',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildVintageTextField(
                            controller: roleController,
                            label: 'Vai trò',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildVintageTextField(
                            controller: birthDateController,
                            label: 'Năm sinh',
                            icon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildVintageTextField(
                            controller: orderController,
                            label: 'Thứ tự (1, 2, 3...)',
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildVintageTextField(
                            controller: spousesController,
                            label: 'Vợ/Chồng (ngăn cách bởi dấu phẩy)',
                            icon: Icons.favorite_border,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.vintageIvory.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.bronzeBorder.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Giới tính:',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 15,
                                    color: AppColors.mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Radio<bool>(
                                  value: true,
                                  groupValue: ref.watch(
                                    _editDialogGenderProvider,
                                  ),
                                  onChanged:
                                      (val) =>
                                          ref
                                              .read(
                                                _editDialogGenderProvider
                                                    .notifier,
                                              )
                                              .state = val!,
                                  activeColor: AppColors.deepGreen,
                                ),
                                Text(
                                  'Nam',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 15,
                                    color: AppColors.darkBrown,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Radio<bool>(
                                  value: false,
                                  groupValue: ref.watch(
                                    _editDialogGenderProvider,
                                  ),
                                  onChanged:
                                      (val) =>
                                          ref
                                              .read(
                                                _editDialogGenderProvider
                                                    .notifier,
                                              )
                                              .state = val!,
                                  activeColor: AppColors.dustyRose,
                                ),
                                Text(
                                  'Nữ',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 15,
                                    color: AppColors.darkBrown,
                                  ),
                                ),
                              ],
                            ),
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
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Hủy',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        color: AppColors.darkBrown,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
                                        AppColors.sepiaTone,
                                        AppColors.bronzeBorder,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      final spouses =
                                          spousesController.text
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList();

                                      final updatedMember = member.copyWith(
                                        name: nameController.text,
                                        role: roleController.text,
                                        birthDate: birthDateController.text,
                                        isMale: ref.read(
                                          _editDialogGenderProvider,
                                        ),
                                        order:
                                            int.tryParse(
                                              orderController.text,
                                            ) ??
                                            1,
                                        spouses: spouses,
                                      );
                                      //lấy clan hiện tại
                                      final clan = ref.watch(
                                        clanNotifierProvider,
                                      );

                                      clan.when(
                                        data: (data) {
                                          ref
                                              .read(familyTreeProvider.notifier)
                                              .updateMember(
                                                data.first.id,
                                                updatedMember,
                                              );
                                        },
                                        error: (error, stackTrace) {
                                          ref
                                              .read(
                                                notificationProvider.notifier,
                                              )
                                              .show(
                                                'Lỗi khi cập nhật thành viên.',
                                                NotificationType.error,
                                              );
                                        },
                                        loading: () {},
                                      );

                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      'Lưu',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        color: AppColors.creamPaper,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
            },
          ),
    );
  }

  /// Hiển thị dialog xác nhận xóa thành viên
  ///
  /// Cảnh báo người dùng rằng việc xóa sẽ xóa luôn cả các đời sau
  /// [member] Thành viên cần xóa
  void _confirmDelete(FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.creamPaper, AppColors.warmBeige],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.burgundyAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: AppColors.burgundyAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'XÁC NHẬN XÓA',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.burgundyAccent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn có chắc muốn xóa ${member.name}?\n\nHành động này sẽ xóa cả các đời sau của người này và không thể hoàn tác.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      color: AppColors.darkBrown,
                      height: 1.5,
                    ),
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
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: AppColors.darkBrown,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.burgundyAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              //lấy clan hiện tại
                              final clan = ref.watch(clanNotifierProvider);

                              clan.when(
                                data: (data) {
                                  ref
                                      .read(familyTreeProvider.notifier)
                                      .deleteMember(data.first.id, member.id);
                                },
                                error: (error, stackTrace) {
                                  ref
                                      .read(notificationProvider.notifier)
                                      .show(
                                        'Lỗi khi cập nhật thành viên.',
                                        NotificationType.error,
                                      );
                                },
                                loading: () {},
                              );

                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Xóa',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: AppColors.creamPaper,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
    );
  }

  /// Hiển thị dialog thêm con (thành viên đời sau)
  ///
  /// Cho phép nhập thông tin thành viên mới: tên, vai trò, năm sinh, thứ tự, giới tính
  /// Thứ tự mặc định là số con hiện tại + 1
  /// [parent] Thành viên cha/mẹ của con mới
  void _showAddChildDialog(FamilyMember parent) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final birthDateController = TextEditingController();
    final orderController = TextEditingController(
      text: (parent.children.length + 1).toString(),
    );
    showDialog(
      context: context,
      builder:
          (context) => Consumer(
            builder: (context, ref, child) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 550),
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 48,
                          color: AppColors.deepGreen,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'THÊM ĐỜI SAU',
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
                          controller: nameController,
                          label: 'Họ và tên',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildVintageTextField(
                          controller: roleController,
                          label: 'Vai trò (VD: Trưởng nam)',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildVintageTextField(
                          controller: birthDateController,
                          label: 'Năm sinh (VD: 1990)',
                          icon: Icons.calendar_today_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildVintageTextField(
                          controller: orderController,
                          label: 'Thứ tự (1, 2, 3...)',
                          icon: Icons.format_list_numbered,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.vintageIvory.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.bronzeBorder.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Giới tính:',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 15,
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Radio<bool>(
                                value: true,
                                groupValue: ref.watch(
                                  _addChildDialogGenderProvider,
                                ),
                                onChanged:
                                    (val) =>
                                        ref
                                            .read(
                                              _addChildDialogGenderProvider
                                                  .notifier,
                                            )
                                            .state = val!,
                                activeColor: AppColors.deepGreen,
                              ),
                              Text(
                                'Nam',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 15,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Radio<bool>(
                                value: false,
                                groupValue: ref.watch(
                                  _addChildDialogGenderProvider,
                                ),
                                onChanged:
                                    (val) =>
                                        ref
                                            .read(
                                              _addChildDialogGenderProvider
                                                  .notifier,
                                            )
                                            .state = val!,
                                activeColor: AppColors.dustyRose,
                              ),
                              Text(
                                'Nữ',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 15,
                                  color: AppColors.darkBrown,
                                ),
                              ),
                            ],
                          ),
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
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      color: AppColors.darkBrown,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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
                                      AppColors.sepiaTone,
                                      AppColors.bronzeBorder,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty) {
                                      final newChild = FamilyMember(
                                        id:
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                        name: nameController.text,
                                        role: roleController.text,
                                        birthDate: birthDateController.text,
                                        isMale: ref.read(
                                          _addChildDialogGenderProvider,
                                        ),
                                        order:
                                            int.tryParse(
                                              orderController.text,
                                            ) ??
                                            1,
                                      );
                                      //lấy clan hiện tại
                                      final clan = ref.watch(
                                        clanNotifierProvider,
                                      );
                                      clan.when(
                                        data:
                                            (data) => ref
                                                .read(
                                                  familyTreeProvider.notifier,
                                                )
                                                .addChild(
                                                  data.first.id,
                                                  parent.id,
                                                  newChild,
                                                ),
                                        error:
                                            (error, stackTrace) =>
                                                debugPrint(error.toString()),
                                        loading: () {},
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Thêm',
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      color: AppColors.creamPaper,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
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
              );
            },
          ),
    );
  }

  /// Hiển thị dialog thêm vợ/chồng cho thành viên
  ///
  /// Chỉ cần nhập tên vợ/chồng mới
  /// [member] Thành viên cần thêm vợ/chồng
  void _showAddSpouseDialog(FamilyMember member) {
    final nameController = TextEditingController();

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
                      Icons.favorite_border,
                      size: 48,
                      color: AppColors.dustyRose,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'THÊM VỢ/CHỒNG',
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
                      controller: nameController,
                      label: 'Họ và tên',
                      icon: Icons.person_outline,
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
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  color: AppColors.darkBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
                                  AppColors.sepiaTone,
                                  AppColors.bronzeBorder,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (nameController.text.isNotEmpty) {
                                  //lấy clan hiện tại
                                  final clan = ref.watch(clanNotifierProvider);
                                  clan.when(
                                    data:
                                        (data) => ref
                                            .read(familyTreeProvider.notifier)
                                            .addSpouse(
                                              data.first.id,
                                              member.id,
                                              nameController.text,
                                            ),
                                    error:
                                        (error, stackTrace) =>
                                            debugPrint(error.toString()),
                                    loading: () {},
                                  );

                                  Navigator.pop(context);
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                'Thêm',
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  color: AppColors.creamPaper,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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

  /// Xây dựng một text field với phong cách vintage
  ///
  /// Sử dụng trong các dialog nhập liệu với style đồng nhất
  /// [controller] Controller cho text field
  /// [label] Nhãn hiển thị
  /// [icon] Icon hiển thị bên trái
  /// [keyboardType] Loại bàn phím (ví dụ: number cho số)
  Widget _buildVintageTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
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
}

/// CustomPainter để vẽ đường thẳng đứng từ node cha xuống các node con
///
/// Vẽ với phong cách vintage: màu bronze, có bóng mờ
class VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.bronzeBorder.withOpacity(0.7)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    // Main line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Add subtle shadow effect
    final shadowPaint =
        Paint()
          ..color = AppColors.sepiaTone.withOpacity(0.3)
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(
      Offset(size.width / 2 + 1, 1),
      Offset(size.width / 2 + 1, size.height + 1),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter để vẽ đường nối giữa node và anh chị em của nó
///
/// Vẽ các loại đường nối khác nhau tùy theo vị trí:
/// - Con đầu tiên: nối từ bên phải
/// - Con cuối cùng: nối từ bên trái
/// - Con giữa: nối ngang qua
class ConnectorPainter extends CustomPainter {
  /// Vị trí của node hiện tại trong danh sách anh chị em (0-based)
  final int index;

  /// Tổng số anh chị em
  final int count;

  ConnectorPainter({required this.index, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.bronzeBorder.withOpacity(0.7)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final shadowPaint =
        Paint()
          ..color = AppColors.sepiaTone.withOpacity(0.3)
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final centerX = size.width / 2;
    final bottomY = size.height;
    final path = Path();
    final shadowPath = Path();

    if (count == 1) {
      // Chỉ có 1 con: vẽ đường thẳng từ trên xuống
      path.moveTo(centerX, 0);
      path.lineTo(centerX, bottomY);
      shadowPath.moveTo(centerX + 1, 1);
      shadowPath.lineTo(centerX + 1, bottomY + 1);
    } else {
      if (index == 0) {
        // Con đầu: vẽ từ phải sang, vuông góc xuống
        path.moveTo(size.width, 0);
        path.lineTo(centerX, 0);
        path.lineTo(centerX, bottomY);
        shadowPath.moveTo(size.width + 1, 1);
        shadowPath.lineTo(centerX + 1, 1);
        shadowPath.lineTo(centerX + 1, bottomY + 1);
      } else if (index == count - 1) {
        // Con cuối: vẽ từ trái sang, vuông góc xuống
        path.moveTo(0, 0);
        path.lineTo(centerX, 0);
        path.lineTo(centerX, bottomY);
        shadowPath.moveTo(1, 1);
        shadowPath.lineTo(centerX + 1, 1);
        shadowPath.lineTo(centerX + 1, bottomY + 1);
      } else {
        // Con giữa: vẽ đường ngang qua và đường dọc xuống
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.moveTo(centerX, 0);
        path.lineTo(centerX, bottomY);
        shadowPath.moveTo(1, 1);
        shadowPath.lineTo(size.width + 1, 1);
        shadowPath.moveTo(centerX + 1, 1);
        shadowPath.lineTo(centerX + 1, bottomY + 1);
      }
    }

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
