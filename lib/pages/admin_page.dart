import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/providers/auth_provider.dart';
import 'package:website_gia_pha/models/clan.dart';
import 'package:intl/intl.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/providers/notification_provider.dart';

// Provider cho dark mode
final _isDarkModeProvider = StateProvider<bool>((ref) => true);

// Provider cho menu index
final _selectedMenuIndexProvider = StateProvider<int>((ref) => 0);

// Provider cho menu expanded state
final _isMenuExpandedProvider = StateProvider<bool>((ref) => true);

// Provider cho redirect flag
final _hasRedirectedProvider = StateProvider<bool>((ref) => false);

enum ClanAction { add, edit, delete }

// Menu items constant
const List<AdminMenuItem> _menuItems = [
  AdminMenuItem(
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    title: 'Quản lý User',
    subtitle: 'Người dùng',
  ),
  AdminMenuItem(
    icon: Icons.family_restroom_outlined,
    selectedIcon: Icons.family_restroom,
    title: 'Quản lý Clan',
    subtitle: 'Dòng họ',
  ),
];

/// Admin Page - Quản lý hệ thống gia phả
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDarkMode = ref.watch(_isDarkModeProvider);
    final hasRedirected = ref.watch(_hasRedirectedProvider);

    return authState.when(
      loading: () => _buildLoading(isDarkMode),
      error:
          (error, stack) => _buildError(error.toString(), isDarkMode, context),
      data: (isLoggedIn) {
        if (!isLoggedIn && !hasRedirected) {
          ref.read(_hasRedirectedProvider.notifier).state = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return _buildLoading(isDarkMode);
        }

        return _buildMainContent(isDarkMode, ref, context);
      },
    );
  }

  Widget _buildLoading(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1D29) : Colors.grey[100],
      body: Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.blue : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildError(String error, bool isDark, BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1D29) : Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isDark, WidgetRef ref, BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final isMenuExpanded = ref.watch(_isMenuExpandedProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1D29) : Colors.grey[100],
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar - ẩn trên mobile hoặc khi collapsed
              if (!isMobile || isMenuExpanded)
                _buildSidebar(isDark, isMobile, ref),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(isDark, isMobile, ref),
                    Expanded(child: _buildContentArea(isDark, ref, context)),
                  ],
                ),
              ),
            ],
          ),
          // Overlay khi menu mở trên mobile
          if (isMobile && isMenuExpanded)
            GestureDetector(
              onTap: () {
                ref.read(_isMenuExpandedProvider.notifier).state = false;
              },
              child: Container(
                color: Colors.black54,
                margin: const EdgeInsets.only(left: 260),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark, bool isMobile, WidgetRef ref) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242837) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        boxShadow:
            isMobile
                ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ]
                : null,
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gia Phả System',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final selectedMenuIndex = ref.watch(_selectedMenuIndexProvider);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = selectedMenuIndex == index;
                    return _buildMenuItem(item, index, isSelected, isDark, ref);
                  },
                );
              },
            ),
          ),

          // Theme Toggle
          _buildThemeToggle(isDark, ref),

          // Logout
          _buildLogoutButton(isDark, ref),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    AdminMenuItem item,
    int index,
    bool isSelected,
    bool isDark,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            ref.read(_selectedMenuIndexProvider.notifier).state = index;
            // Đóng menu trên mobile sau khi chọn
            final platform = ref.read(flatformNotifierProvider);
            if (platform == 1) {
              ref.read(_isMenuExpandedProvider.notifier).state = false;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? (isDark
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.blue[50])
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color:
                      isSelected
                          ? Colors.blue
                          : (isDark ? Colors.white60 : Colors.black54),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.blue
                                  : (isDark ? Colors.white : Colors.black87),
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 11,
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

  Widget _buildThemeToggle(bool isDark, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.white60 : Colors.black54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isDark ? 'Dark Mode' : 'Light Mode',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Switch(
            value: isDark,
            onChanged: (value) {
              ref.read(_isDarkModeProvider.notifier).state = value;
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Builder(
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  Widget _buildTopBar(bool isDark, bool isMobile, WidgetRef ref) {
    final selectedMenuIndex = ref.watch(_selectedMenuIndexProvider);
    final isMenuExpanded = ref.watch(_isMenuExpandedProvider);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242837) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger menu button (chỉ hiện trên mobile)
          if (isMobile)
            IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                ref.read(_isMenuExpandedProvider.notifier).state =
                    !isMenuExpanded;
              },
            ),
          if (isMobile) const SizedBox(width: 8),
          Text(
            _menuItems[selectedMenuIndex].title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: isMobile ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Admin badge
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentArea(bool isDark, WidgetRef ref, BuildContext context) {
    final _selectedMenuIndex = ref.watch(_selectedMenuIndexProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      child: _getContentForMenu(_selectedMenuIndex, isDark, context, ref),
    );
  }

  Widget _getContentForMenu(
    int index,
    bool isDark,
    BuildContext context,
    WidgetRef ref,
  ) {
    switch (index) {
      case 0:
        return _buildUserManagement(isDark);
      case 1:
        return _buildClanManagement(isDark, context, ref);
      default:
        return _buildUserManagement(isDark);
    }
  }

  Widget buildDashboard(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Tổng số User',
                  value: '156',
                  icon: Icons.people,
                  color: Colors.blue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Dòng họ',
                  value: '12',
                  icon: Icons.family_restroom,
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Active Sessions',
                  value: '45',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Uptime',
                  value: '99.9%',
                  icon: Icons.check_circle,
                  color: Colors.teal,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity
          _buildSectionTitle('Hoạt động gần đây', isDark),
          const SizedBox(height: 16),
          _buildActivityList(isDark),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242837) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(bool isDark) {
    final activities = [
      {
        'icon': Icons.login,
        'title': 'User đăng nhập',
        'subtitle': 'admin@giapha.site - 5 phút trước',
        'color': Colors.blue,
      },
      {
        'icon': Icons.person_add,
        'title': 'Thêm user mới',
        'subtitle': 'Nguyễn Văn A - 1 giờ trước',
        'color': Colors.green,
      },
      {
        'icon': Icons.edit,
        'title': 'Cập nhật clan',
        'subtitle': 'Chi nhánh 5 - 2 giờ trước',
        'color': Colors.orange,
      },
      {
        'icon': Icons.security,
        'title': 'System backup',
        'subtitle': 'Hoàn thành - 3 giờ trước',
        'color': Colors.purple,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242837) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children:
            activities
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (activity['color'] as Color).withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: activity['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity['subtitle'] as String,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildUserManagement(bool isDark) {
    return _buildPlaceholder('Quản lý user', isDark);
  }

  Widget _buildClanManagement(
    bool isDark,
    BuildContext context,
    WidgetRef ref,
  ) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add button
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _showClanDialog(context, isDark, null, ClanAction.add, ref);
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Thêm Dòng Họ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242837) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          'STT',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isMobile)
                        Expanded(
                          child: Text(
                            'Tên Dòng Họ',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!isMobile)
                        SizedBox(
                          width: 250,
                          child: Text(
                            'Tên Dòng Họ',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!isMobile)
                        SizedBox(
                          width: 120,
                          child: Text(
                            'Chi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!isMobile)
                        SizedBox(
                          width: 280,
                          child: Text(
                            'Subdomain',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!isMobile)
                        SizedBox(
                          width: 140,
                          child: Text(
                            'Ngày tạo',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (!isMobile)
                        SizedBox(
                          width: 120,
                          child: Text(
                            'Thao tác',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Table Body
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final clans = ref.watch(clanNotifierProvider);

                      return clans.when(
                        data: (data) {
                          if (data.isEmpty) {
                            return const Center(
                              child: Text('Không có dữ liệu'),
                            );
                          }
                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final clan = data.elementAt(index);
                              return InkWell(
                                onTap:
                                    isMobile
                                        ? () {
                                          _showClanDetailDialog(
                                            context,
                                            isDark,
                                            clan,
                                            ref,
                                          );
                                        }
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color:
                                            isDark
                                                ? Colors.white10
                                                : Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color:
                                                isDark
                                                    ? Colors.white60
                                                    : Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (isMobile)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  clan.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    color:
                                                        isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color:
                                                    isDark
                                                        ? Colors.white38
                                                        : Colors.black38,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isMobile)
                                        SizedBox(
                                          width: 250,
                                          child: Text(
                                            clan.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      if (!isMobile)
                                        SizedBox(
                                          width: 120,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.blue
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                clan.chi,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (!isMobile)
                                        SizedBox(
                                          width: 280,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.link,
                                                size: 16,
                                                color:
                                                    isDark
                                                        ? Colors.white38
                                                        : Colors.black38,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${clan.subNameUrl}.giapha.site',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color:
                                                        isDark
                                                            ? Colors.white60
                                                            : Colors.black54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (!isMobile)
                                        SizedBox(
                                          width: 140,
                                          child: Text(
                                            DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(clan.createdAt),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  isDark
                                                      ? Colors.white60
                                                      : Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      if (!isMobile)
                                        SizedBox(
                                          width: 120,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                                iconSize: 20,
                                                color: Colors.blue,
                                                onPressed: () {
                                                  _showClanDialog(
                                                    context,
                                                    isDark,
                                                    clan,
                                                    ClanAction.edit,
                                                    ref,
                                                  );
                                                },
                                                tooltip: 'Sửa',
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                iconSize: 20,
                                                color: Colors.red,
                                                onPressed: () {
                                                  _showDeleteDialog(
                                                    context,
                                                    isDark,
                                                    clan,
                                                    ref,
                                                  );
                                                },
                                                tooltip: 'Xóa',
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Center(
                            child: Text(
                              'Đã có lỗi xảy ra: $error',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Dialog for Create/Edit Clan
  void _showClanDialog(
    BuildContext context,
    bool isDark,
    Clan? clan,
    ClanAction action,
    WidgetRef ref,
  ) {
    final isEdit = clan != null;
    final nameController = TextEditingController(text: clan?.name ?? '');
    final chiController = TextEditingController(text: clan?.chi ?? '');
    final subdomainController = TextEditingController(
      text: clan?.subNameUrl ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF242837) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(
                  isEdit ? Icons.edit : Icons.add_circle_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Chỉnh sửa Dòng Họ' : 'Thêm Dòng Họ Mới',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  Text(
                    'Tên Dòng Họ *',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Họ Nguyễn Đình',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chi field
                  Text(
                    'Chi *',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: chiController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Chi 1',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subdomain field
                  Text(
                    'Subdomain *',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subdomainController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: nguyendinh',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      suffixText: '.giapha.site',
                      suffixStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chỉ sử dụng chữ thường, số và dấu gạch ngang',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      chiController.text.trim().isEmpty ||
                      subdomainController.text.trim().isEmpty) {
                    // Show error
                    ref
                        .read(notificationProvider.notifier)
                        .show('Không đủ thông tin.', NotificationType.info);
                    return;
                  }
                  switch (action) {
                    case ClanAction.add:
                      Clan newClan = Clan.create(
                        name: nameController.text.trim(),
                        chi: chiController.text.trim(),
                        subNameUrl: subdomainController.text.trim(),
                      );
                      final success = await ref
                          .read(clanNotifierProvider.notifier)
                          .addClan(newClan);
                      if (success) {
                        Navigator.of(context).pop();
                        ref
                            .read(notificationProvider.notifier)
                            .show(
                              'Thêm Dòng Họ thành công.',
                              NotificationType.success,
                            );
                      } else {
                        ref
                            .read(notificationProvider.notifier)
                            .show(
                              'Thêm Dòng Họ thất bại. Vui lòng thử lại.',
                              NotificationType.error,
                            );
                      }
                      break;
                    case ClanAction.edit:
                      Clan updatedClan = Clan(
                        id: clan!.id,
                        name: nameController.text.trim(),
                        chi: chiController.text.trim(),
                        subNameUrl: subdomainController.text.trim(),
                        createdAt: clan.createdAt,
                      );
                      final success = await ref
                          .read(clanNotifierProvider.notifier)
                          .updateClan(clan.id, updatedClan);
                      if (success) {
                        Navigator.of(context).pop();
                        ref
                            .read(notificationProvider.notifier)
                            .show(
                              'Cập nhật Dòng Họ thành công.',
                              NotificationType.success,
                            );
                      } else {
                        Navigator.of(context).pop();
                        ref
                            .read(notificationProvider.notifier)
                            .show(
                              'Cập nhật Dòng Họ thất bại. Vui lòng thử lại.',
                              NotificationType.error,
                            );
                      }
                      break;
                    default:
                      break;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
              ),
            ],
          ),
    );
  }

  // Dialog for Clan Detail (Mobile)
  void _showClanDetailDialog(
    BuildContext context,
    bool isDark,
    Clan clan,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF242837) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.family_restroom, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chi tiết Dòng Họ',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _buildDetailRow(
                    icon: Icons.badge,
                    label: 'Tên Dòng Họ',
                    value: clan.name,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Chi
                  _buildDetailRow(
                    icon: Icons.local_offer,
                    label: 'Chi',
                    value: clan.chi,
                    isDark: isDark,
                    valueColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  // Subdomain
                  _buildDetailRow(
                    icon: Icons.link,
                    label: 'Subdomain',
                    value: '${clan.subNameUrl}.giapha.site',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Created date
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Ngày tạo',
                    value: DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(clan.createdAt),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showClanDialog(
                              context,
                              isDark,
                              clan,
                              ClanAction.edit,
                              ref,
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Chỉnh sửa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showDeleteDialog(context, isDark, clan, ref);
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Xóa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Đóng',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white60 : Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dialog for Delete Confirmation
  void _showDeleteDialog(
    BuildContext context,
    bool isDark,
    Clan clan,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF242837) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Xác nhận xóa',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có chắc chắn muốn xóa dòng họ này?',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red[300],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin dòng họ:',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tên: ${clan.name}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Chi: ${clan.chi}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Subdomain: ${clan.subNameUrl}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '⚠️ Lưu ý: Hành động này không thể hoàn tác!',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await ref
                      .read(clanNotifierProvider.notifier)
                      .deleteClan(clan);
                  if (success) {
                    Navigator.of(context).pop();
                    ref
                        .read(notificationProvider.notifier)
                        .show('Xóa thành công.', NotificationType.success);
                  } else {
                    Navigator.of(context).pop();
                    ref
                        .read(notificationProvider.notifier)
                        .show('Xóa thất bại!', NotificationType.error);
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  Widget _buildPlaceholder(String title, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.orange, size: 64),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chức năng đang được phát triển...',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String subtitle;

  const AdminMenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.subtitle,
  });
}
