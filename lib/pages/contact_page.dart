import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

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

  String _selectedRequestType = 'Yêu cầu cấp tài khoản';
  final List<String> _requestTypes = [
    'Yêu cầu cấp tài khoản',
    'Yêu cầu đổi thông tin',
    'Góp ý / Báo lỗi',
    'Khác',
  ];

  bool _isSending = false;

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      // Lưu vào Firestore vì Web không hỗ trợ gửi mail trực tiếp qua SMTP (Socket Exception)
      await FirebaseFirestore.instance.collection('contact_requests').add({
        'type': _selectedRequestType,
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
              type: NotificationType.success,
            );
        // Reset form sau khi gửi thành công
        _nameController.clear();
        _contactController.clear();
        _contentController.clear();
        setState(() {
          _selectedRequestType = _requestTypes[0];
        });
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .show('Gửi thất bại $e', type: NotificationType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Liên Hệ & Góp Ý',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.woodBrown,
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hãy để lại thông tin, chúng tôi sẽ liên hệ lại với bạn trong thời gian sớm nhất.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                // Thông tin liên hệ tĩnh
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.ivoryWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: const [
                      ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: AppColors.woodBrown,
                          size: 30,
                        ),
                        title: Text(
                          'Địa chỉ nhà thờ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Xã Bạch Hà, Tỉnh Nghệ An'),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: AppColors.woodBrown,
                          size: 30,
                        ),
                        title: Text(
                          'Số điện thoại ban liên lạc',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('0328262101'),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.email,
                          color: AppColors.woodBrown,
                          size: 30,
                        ),
                        title: Text(
                          'Email hỗ trợ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('phuckk2101@gmail.com'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  'Gửi Yêu Cầu Trực Tuyến',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.woodBrown,
                  ),
                ),
                const SizedBox(height: 20),

                // Form gửi tin nhắn
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Combobox Loại yêu cầu
                      DropdownButtonFormField<String>(
                        value: _selectedRequestType,
                        decoration: const InputDecoration(
                          labelText: 'Loại yêu cầu',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.category,
                            color: AppColors.woodBrown,
                          ),
                        ),
                        items:
                            _requestTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRequestType = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Họ và tên
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppColors.woodBrown,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email / SĐT
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Email hoặc Số điện thoại liên hệ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.contact_phone,
                            color: AppColors.woodBrown,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập thông tin liên hệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Nội dung
                      TextFormField(
                        controller: _contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Nội dung chi tiết',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 80),
                            child: Icon(
                              Icons.message,
                              color: AppColors.woodBrown,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập nội dung';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Nút gửi
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.woodBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isSending
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.woodBrown,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Đang gửi...'),
                                    ],
                                  )
                                  : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send),
                                      SizedBox(width: 10),
                                      Text(
                                        'GỬI YÊU CẦU',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
  }
}
