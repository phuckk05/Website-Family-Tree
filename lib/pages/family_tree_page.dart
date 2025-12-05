import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/models/family_member.dart';
import 'package:website_gia_pha/providers/family_tree_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

class FamilyTreePage extends ConsumerStatefulWidget {
  const FamilyTreePage({super.key});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends ConsumerState<FamilyTreePage> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    final rootMemberAsync = ref.watch(familyTreeProvider);

    return MainLayout(
      enableScroll: false,
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thành viên...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.zoom_in),
                  onPressed: () {
                    _transformationController.value *=
                        Matrix4.identity()..scale(1.2);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out),
                  onPressed: () {
                    _transformationController.value *=
                        Matrix4.identity()..scale(0.8);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _transformationController.value = Matrix4.identity();
                  },
                ),
              ],
            ),
          ),
          // Tree View
          Expanded(
            child: Container(
              color: const Color(0xFFEFEBE9), // Màu giấy cũ
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
                        padding: const EdgeInsets.all(500.0),
                        child: _buildTree(rootMember),
                      ),
                    ),
                error:
                    (err, stack) =>
                        Center(child: Text('Lỗi: ${err.toString()}')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
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
