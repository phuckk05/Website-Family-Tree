import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/family_member.dart';
import 'package:website_gia_pha/providers/family_tree_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
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

  Widget _buildNodeCard(FamilyMember member, {int depth = 1}) {
    // Màu nền vàng tươi (Yellow 400)
    final backgroundColor = const Color(0xFFFFEE58);
    // Màu chữ và viền đỏ đậm
    final mainColor = const Color(0xFFD50000);

    // Kiểm tra nếu là đời thứ 5 trở đi
    final isVerticalNode = depth >= 5;

    // Kích thước node
    final double width = isVerticalNode ? 90.0 : 180.0;
    final double height = isVerticalNode ? 300.0 : 90.0;

    return InkWell(
      key: GlobalObjectKey(member.id), // Key để tìm vị trí
      onTap: () => _showActionMenu(context, member),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: mainColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child:
            isVerticalNode
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tên vợ/chồng (Xoay dọc) - Hiển thị bên trái (Dưới theo quy tắc phải sang trái)
                        if (member.spouses.isNotEmpty) ...[
                          RotatedBox(
                            quarterTurns: 1,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                member.spouses.join(', '),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mainColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Tên thành viên (Xoay dọc 90 độ) - Hiển thị bên phải (Trên)
                        RotatedBox(
                          quarterTurns: 1,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 200,
                            ), // Giới hạn chiều dài text
                            child: Text(
                              member.name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: mainColor,
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
                    Text(
                      member.name.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: mainColor,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Tên vợ/chồng (nếu có)
                    if (member.spouses.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        member.spouses.join('\n'),
                        style: TextStyle(
                          fontSize: 13,
                          color: mainColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, FamilyMember member) {
    final isLoggedIn = ref.read(authProvider).value ?? false;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (!isLoggedIn) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Xem chi tiết'),
                onTap: () {
                  Navigator.pop(context);
                  _showViewDialog(member);
                },
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Thêm con'),
              onTap: () {
                Navigator.pop(context);
                _showAddChildDialog(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Thêm vợ/chồng'),
              onTap: () {
                Navigator.pop(context);
                _showAddSpouseDialog(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Sửa thông tin'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Xóa thành viên',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(member);
              },
            ),
          ],
        );
      },
    );
  }

  void _showViewDialog(FamilyMember member) {
    final nameController = TextEditingController(text: member.name);
    final roleController = TextEditingController(text: member.role);
    final birthDateController = TextEditingController(text: member.birthDate);
    final orderController = TextEditingController(
      text: member.order.toString(),
    );
    final spousesController = TextEditingController(
      text: member.spouses.join(', '),
    );
    bool isMale = member.isMale;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin chi tiết'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Họ và tên'),
                  ),
                  TextField(
                    controller: roleController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Vai trò'),
                  ),
                  TextField(
                    controller: birthDateController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Năm sinh'),
                  ),
                  TextField(
                    controller: orderController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Thứ tự'),
                  ),
                  TextField(
                    controller: spousesController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Vợ/Chồng'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Giới tính: '),
                      Text(
                        isMale ? 'Nam' : 'Nữ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

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
    bool isMale = member.isMale;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Sửa thông tin'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                        ),
                      ),
                      TextField(
                        controller: roleController,
                        decoration: const InputDecoration(labelText: 'Vai trò'),
                      ),
                      TextField(
                        controller: birthDateController,
                        decoration: const InputDecoration(
                          labelText: 'Năm sinh',
                        ),
                      ),
                      TextField(
                        controller: orderController,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự (1, 2, 3...)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: spousesController,
                        decoration: const InputDecoration(
                          labelText: 'Vợ/Chồng (ngăn cách bởi dấu phẩy)',
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
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
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
                        isMale: isMale,
                        order: int.tryParse(orderController.text) ?? 1,
                        spouses: spouses,
                      );

                      ref
                          .read(familyTreeProvider.notifier)
                          .updateMember(updatedMember);
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _confirmDelete(FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc muốn xóa ${member.name}? Hành động này sẽ xóa cả các đời sau của người này.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ref.read(familyTreeProvider.notifier).deleteMember(member.id);
                  Navigator.pop(context);
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  void _showAddChildDialog(FamilyMember parent) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final birthDateController = TextEditingController();
    final orderController = TextEditingController(
      text: (parent.children.length + 1).toString(),
    );
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
                    TextField(
                      controller: orderController,
                      decoration: const InputDecoration(
                        labelText: 'Thứ tự (1, 2, 3...)',
                      ),
                      keyboardType: TextInputType.number,
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
                          order: int.tryParse(orderController.text) ?? 1,
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
          ..color = const Color(0xFFD50000) // Red
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
          ..color = const Color(0xFFD50000) // Red
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
      if (index == 0) {
        // Con đầu: vẽ từ phải sang, vuông góc xuống
        path.moveTo(size.width, 0);
        path.lineTo(centerX, 0);
        path.lineTo(centerX, bottomY);
      } else if (index == count - 1) {
        // Con cuối: vẽ từ trái sang, vuông góc xuống
        path.moveTo(0, 0);
        path.lineTo(centerX, 0);
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
