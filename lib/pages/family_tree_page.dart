import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/family_member.dart';
import 'package:website_gia_pha/providers/family_tree_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

class FamilyTreePage extends ConsumerStatefulWidget {
  const FamilyTreePage({super.key});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends ConsumerState<FamilyTreePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _treeContentKey = GlobalKey();
  late AnimationController _animationController;
  bool _hasInitialFocused = false;

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
                type: NotificationType.success,
              );
        } else {
          ref
              .read(notificationProvider.notifier)
              .show(
                'Không tìm thấy thành viên "$value"!',
                type: NotificationType.error,
              );
        }
      }
    }

    return MainLayout(
      enableScroll: false,
      child: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 30,
              width: double.infinity,
              child: Row(
                children: [
                  ref.watch(flatformNotifierProvider) == 1 ||
                          ref.watch(flatformNotifierProvider) == 2
                      ? Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => handleSearch(),
                          decoration: InputDecoration(
                            hintText: 'Tìm Tên...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      )
                      : Container(
                        height: 50,
                        width: 600,
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (_) => handleSearch(),
                          decoration: InputDecoration(
                            hintText: 'Tìm Tên...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),

                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.woodBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tìm'),
                  ),
                ],
              ),
            ),
          ),
          // Tree View
          Expanded(
            child: Stack(
              children: [
                Container(
                  // color: const Color(0xFFEFEBE9), // Màu giấy cũ
                  child: rootMemberAsync.when(
                    data:
                        (rootMember) => InteractiveViewer(
                          transformationController: _transformationController,
                          boundaryMargin: const EdgeInsets.all(
                            5000,
                          ), // Tăng kích thước map
                          minScale: 0.01,
                          maxScale: 5.0,
                          constrained: false,
                          child: Padding(
                            key: _treeContentKey, // Key để xác định vị trí gốc
                            padding: const EdgeInsets.all(500.0),
                            child: _buildTree(rootMember),
                          ),
                        ),
                    error:
                        (err, stack) =>
                            Center(child: Text('Lỗi: ${err.toString()}')),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                  ),
                ),
                // Floating Controls (Nút nổi chuyên nghiệp)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF5E6).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.woodBrown, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildZoomButton(Icons.add, _zoomIn, 'Phóng to'),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          width: 20,
                          color: AppColors.woodBrown.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.remove, _zoomOut, 'Thu nhỏ'),
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          width: 20,
                          color: AppColors.woodBrown.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.refresh, () {
                          if (rootMemberAsync.hasValue) {
                            _zoomToNode(rootMemberAsync.value!.id);
                          } else {
                            _transformationController.value =
                                Matrix4.identity();
                          }
                        }, 'Mặc định'),
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

  Widget _buildZoomButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.woodBrown,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.ivoryWhite, size: 20),
        ),
      ),
    );
  }

  Widget _buildTree(FamilyMember member) {
    return Column(
      children: [
        // Node thành viên
        _buildNodeCard(member),

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
                  return _buildSubTree(child, index, count);
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubTree(FamilyMember member, int index, int count) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPaint(
            size: const Size(0, 20),
            painter: ConnectorPainter(index: index, count: count),
          ),
          _buildTree(member),
        ],
      ),
    );
  }

  Widget _buildNodeCard(FamilyMember member) {
    final color =
        member.isMale ? const Color(0xFF2C3E50) : const Color(0xFF8B1E23);

    return InkWell(
      key: GlobalObjectKey(member.id), // Key để tìm vị trí
      onTap: () {
        // Show details dialog
      },
      child: Container(
        width: 220, // Tăng chiều rộng một chút cho khung
        margin: const EdgeInsets.symmetric(horizontal: 8),
        // Outer Frame (Khung gỗ bên ngoài)
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037), // Màu gỗ đậm
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(3, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFF3E2723), width: 1),
        ),
        padding: const EdgeInsets.all(6), // Độ dày của khung gỗ
        child: Container(
          // Inner Paper (Giấy bên trong)
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF5E6), // Màu giấy cũ (OldLace)
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: const Color(0xFF8D6E63), // Viền mỏng bên trong
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tên thành viên
              Text(
                member.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.woodBrown,
                  fontFamily: 'Serif', // Font có chân
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Tên vợ/chồng (nếu có)
              if (member.spouses.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  height: 1,
                  width: 100,
                  color: AppColors.woodBrown.withOpacity(0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  '(${member.spouses.join(', ')})',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Serif',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    member.role,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    member.birthDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontFamily: 'Serif',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.person_add,
                    tooltip: 'Thêm con',
                    onTap: () => _showAddChildDialog(member),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.favorite,
                    tooltip: 'Thêm vợ/chồng',
                    onTap: () => _showAddSpouseDialog(member),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.woodBrown.withOpacity(0.5)),
          ),
          child: Icon(icon, size: 14, color: AppColors.woodBrown),
        ),
      ),
    );
  }

  void _showAddChildDialog(FamilyMember parent) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final birthDateController = TextEditingController();
    bool isMale = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Thêm đời sau'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                    ),
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Vai trò (VD: Trưởng nam)',
                      ),
                    ),
                    TextField(
                      controller: birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Năm sinh (VD: 1990)',
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Giới tính: '),
                        Radio<bool>(
                          value: true,
                          groupValue: isMale,
                          onChanged: (val) => setState(() => isMale = val!),
                        ),
                        const Text('Nam'),
                        Radio<bool>(
                          value: false,
                          groupValue: isMale,
                          onChanged: (val) => setState(() => isMale = val!),
                        ),
                        const Text('Nữ'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final newChild = FamilyMember(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          role: roleController.text,
                          birthDate: birthDateController.text,
                          isMale: isMale,
                        );
                        ref
                            .read(familyTreeProvider.notifier)
                            .addChild(parent.id, newChild);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Thêm'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showAddSpouseDialog(FamilyMember member) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm vợ/chồng'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    ref
                        .read(familyTreeProvider.notifier)
                        .addSpouse(member.id, nameController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }
}

// Painter vẽ đường dọc từ cha xuống
class VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.woodBrown
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter vẽ đường nối phía trên con
class ConnectorPainter extends CustomPainter {
  final int index;
  final int count;

  ConnectorPainter({required this.index, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.woodBrown
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final bottomY = size.height;
    final path = Path();

    if (count == 1) {
      // Chỉ có 1 con: vẽ đường thẳng từ trên xuống
      path.moveTo(centerX, 0);
      path.lineTo(centerX, bottomY);
    } else {
      const double radius = 10.0;

      if (index == 0) {
        // Con đầu: vẽ từ phải sang, bo góc xuống dưới
        path.moveTo(size.width, 0);
        path.lineTo(centerX + radius, 0);
        path.quadraticBezierTo(centerX, 0, centerX, radius);
        path.lineTo(centerX, bottomY);
      } else if (index == count - 1) {
        // Con cuối: vẽ từ trái sang, bo góc xuống dưới
        path.moveTo(0, 0);
        path.lineTo(centerX - radius, 0);
        path.quadraticBezierTo(centerX, 0, centerX, radius);
        path.lineTo(centerX, bottomY);
      } else {
        // Con giữa: vẽ đường ngang qua và đường dọc xuống
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.moveTo(centerX, 0);
        path.lineTo(centerX, bottomY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
