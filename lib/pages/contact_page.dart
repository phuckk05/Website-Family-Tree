import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

// StateProvider cho trạng thái gửi
final _isSendingProvider = StateProvider.autoDispose<bool>((ref) => false);

// StateProvider cho loại yêu cầu
final _selectedRequestTypeProvider = StateProvider.autoDispose<String>(
  (ref) => 'Yêu cầu cấp tài khoản',
);

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _contentController = TextEditingController();

  final List<String> _requestTypes = [
    'Yêu cầu cấp tài khoản',
    'Yêu cầu đổi thông tin',
    'Góp ý / Báo lỗi',
    'Khác',
  ];

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(_isSendingProvider.notifier).state = true;

    try {
      // Lưu vào Firestore vì Web không hỗ trợ gửi mail trực tiếp qua SMTP (Socket Exception)
      await FirebaseFirestore.instance.collection('contact_requests').add({
        'type': ref.read(_selectedRequestTypeProvider),
        'name': _nameController.text,
        'contact': _contactController.text,
        'content': _contentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'new', // Trạng thái: mới, đã xem, đã xử lý
      });

      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show(
              'Đã gửi yêu cầu thành công! Ban quản trị sẽ liên hệ sớm nhất.',
              NotificationType.success,
            );
        // Reset form sau khi gửi thành công
        _nameController.clear();
        _contactController.clear();
        _contentController.clear();
        ref.read(_selectedRequestTypeProvider.notifier).state =
            _requestTypes[0];
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Gửi thất bại $e', NotificationType.error);
      }
    } finally {
      if (mounted) {
        ref.read(_isSendingProvider.notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      index: 6,
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

              // Content
              Builder(
                builder: (context) {
                  final platform = ref.watch(flatformNotifierProvider);
                  final isMobile = platform == 1;
                  return Padding(
                    padding: EdgeInsets.all(isMobile ? 10 : 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            // Contact Info Cards
                            _buildContactInfoCards(),
                            const SizedBox(height: 48),

                            // Form Section Header
                            _buildFormHeader(),
                            const SizedBox(height: 24),

                            // Form Section
                            _buildVintageForm(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
      decoration: BoxDecoration(
        // color: AppColors.creamPaper.withOpacity(0.9),
        // border: Border(
        //   bottom: BorderSide(
        //     color: AppColors.bronzeBorder.withOpacity(0.3),
        //     width: 2,
        //   ),
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.softShadow,
        //     blurRadius: 12,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        children: [
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
          Text(
            'LIÊN HỆ & GÓP Ý',
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
          Text(
            'Hãy để lại thông tin, chúng tôi sẽ liên hệ lại với bạn sớm nhất',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              color: AppColors.mutedText,
              letterSpacing: 1,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
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

  /// Xây dựng các card thông tin liên hệ
  Widget _buildContactInfoCards() {
    final clan = ref.watch(clanNotifierProvider);
    return clan.when(
      data: (data) {
        return Column(
          children: [
            _buildContactCard(
              icon: Icons.location_on_outlined,
              title: 'Địa chỉ nhà thờ',
              content: data.first.address ?? '',
              color: AppColors.deepGreen,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Số điện thoại ban liên lạc',
              content: data.first.phone ?? '',
              color: AppColors.mutedBlue,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email hỗ trợ',
              content: data.first.email ?? '',
              color: AppColors.burgundyAccent,
            ),
          ],
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Xây dựng một card thông tin liên hệ
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.creamPaper, AppColors.vintageIvory],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldBorder.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sepiaTone.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng header cho form
  Widget _buildFormHeader() {
    return Column(
      children: [
        Container(
          height: 1,
          width: double.infinity,
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
        const SizedBox(height: 24),
        Text(
          'GỬI YÊU CẦU TRỰC TUYẾN',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 1,
          width: double.infinity,
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
      ],
    );
  }

  /// Xây dựng form với phong cách vintage
  Widget _buildVintageForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.creamPaper, AppColors.warmBeige.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldBorder.withOpacity(0.6),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sepiaTone.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVintageDropdown(),
            const SizedBox(height: 20),
            _buildVintageTextField(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildVintageTextField(
              controller: _contactController,
              label: 'Email hoặc Số điện thoại',
              icon: Icons.contact_phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập thông tin liên hệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildVintageTextField(
              controller: _contentController,
              label: 'Nội dung chi tiết',
              icon: Icons.message_outlined,
              maxLines: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập nội dung';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng dropdown vintage
  Widget _buildVintageDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: ref.watch(_selectedRequestTypeProvider),
        decoration: InputDecoration(
          labelText: 'Loại yêu cầu',
          labelStyle: TextStyle(
            fontFamily: 'serif',
            color: AppColors.mutedText,
          ),
          prefixIcon: Icon(
            Icons.category_outlined,
            color: AppColors.sepiaTone,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: TextStyle(
          fontFamily: 'serif',
          fontSize: 15,
          color: AppColors.darkBrown,
        ),
        dropdownColor: AppColors.creamPaper,
        items:
            _requestTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(_selectedRequestTypeProvider.notifier).state = newValue;
          }
        },
      ),
    );
  }

  /// Xây dựng text field vintage
  Widget _buildVintageTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.vintageIvory.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.bronzeBorder.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
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
          prefixIcon:
              maxLines > 1
                  ? Padding(
                    padding: EdgeInsets.only(bottom: (maxLines - 1) * 20.0),
                    child: Icon(icon, color: AppColors.sepiaTone, size: 20),
                  )
                  : Icon(icon, color: AppColors.sepiaTone, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          alignLabelWithHint: maxLines > 1,
        ),
        validator: validator,
      ),
    );
  }

  /// Xây dựng nút submit
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.sepiaTone, AppColors.bronzeBorder],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: ref.watch(_isSendingProvider) ? null : _sendEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              ref.watch(_isSendingProvider)
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.creamPaper,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Đang gửi...',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          color: AppColors.creamPaper,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: AppColors.creamPaper, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'GỬI YÊU CẦU',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 16,
                          color: AppColors.creamPaper,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
