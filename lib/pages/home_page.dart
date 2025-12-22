import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:website_gia_pha/core/router/custom_router.dart';
import 'package:website_gia_pha/core/size/flatform.dart';
import 'package:website_gia_pha/models/clan.dart';
import 'package:website_gia_pha/providers/clan_provider.dart';
import 'package:website_gia_pha/themes/app_colors.dart';
import 'package:website_gia_pha/widgets/main_layout.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      index: 1,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.warmBeige),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildHeroSection(context),
              _buildIntroductionSection(context),
              _buildFamilyTreePreview(context),
              _buildGenerationsTimeline(context),
              _buildAncestralStories(context),
              _buildPhotoGallery(context),
            ],
          ),
        ),
      ),
    );
  }

  // 1. HERO SECTION - Family Heritage Banner
  Widget _buildHeroSection(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final parallaxOffset = _scrollOffset * 0.3;
    final clan = ref.watch(clanNotifierProvider);

    return Container(
      height: isMobile ? 600 : 700,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.lightBrown.withOpacity(0.3), AppColors.warmBeige],
        ),
      ),
      child: Stack(
        children: [
          // Background ancestral photo frame
          Positioned(
            top: -parallaxOffset,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: 1.0 + (_scrollOffset * 0.0001),
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/background-pc.png',
                  fit: BoxFit.cover,
                  height: 800,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 800,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppColors.sepiaTone.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),

          // Decorative vintage frame border
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.all(isMobile ? 10 : 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.sepiaTone.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 60,
                  vertical: 40,
                ),
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decorative top line
                    _buildDecorativeLine(),
                    const SizedBox(height: 30),

                    // Family crest or icon
                    Container(
                      width: isMobile ? 80 : 100,
                      height: isMobile ? 80 : 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.sepiaTone,
                          width: 2,
                        ),
                        color: AppColors.creamPaper,
                      ),
                      child: Icon(
                        Icons.temple_buddhist,
                        size: isMobile ? 40 : 50,
                        color: AppColors.deepGreen,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Family name title
                    clan.when(
                      data: (data) {
                        return Text(
                          data.first.name,
                          style: TextStyle(
                            fontSize: isMobile ? 36 : 56,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBrown,
                            fontFamily: 'PlayfairDisplay',
                            letterSpacing: 3,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                      error: (error, stackTrace) {
                        return const CircularProgressIndicator();
                      },
                      loading: () {
                        return const CircularProgressIndicator();
                      },
                    ),

                    const SizedBox(height: 15),
                    clan.when(
                      error: (error, stackTrace) {
                        return const CircularProgressIndicator();
                      },
                      loading: () {
                        return const CircularProgressIndicator();
                      },
                      data: (data) {
                        return Text(
                          data.first.chi,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 28,
                            fontWeight: FontWeight.w500,
                            color: AppColors.sepiaTone,
                            letterSpacing: 8,
                          ),
                        );
                      },
                    ),

                    // Subtitle
                    const SizedBox(height: 40),

                    // Decorative divider
                    _buildDecorativeLine(),

                    const SizedBox(height: 35),

                    clan.when(
                      data: (data) {
                        return Text(
                          data.first.slogan!,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mutedText,
                            height: 1.8,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                      error: (error, stackTrace) {
                        return const CircularProgressIndicator();
                      },
                      loading: () {
                        return const CircularProgressIndicator();
                      },
                    ),

                    // Tagline
                    const SizedBox(height: 50),

                    // CTA Button
                    _buildVintageButton(
                      text: 'Khám Phá Gia Phả',
                      onPressed: () {
                        AppRouter.go(context, AppRouter.familyTree);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. INTRODUCTION SECTION
  Widget _buildIntroductionSection(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 10 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              _buildSectionHeader('Cội Nguồn  Gia Tộc'),
              const SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    isMobile
                        ? [
                          Expanded(
                            child: Column(
                              children: [
                                _buildVintagePhotoFrame(),
                                const SizedBox(height: 40),
                                _buildIntroText(),
                              ],
                            ),
                          ),
                        ]
                        : [
                          Expanded(flex: 5, child: _buildIntroText()),
                          const SizedBox(width: 60),
                          Expanded(flex: 4, child: _buildVintagePhotoFrame()),
                        ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    final clan = ref.watch(clanNotifierProvider);
    return clan.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.first.soucreSolgan!,
              style: TextStyle(
                fontSize: 17,
                color: AppColors.mutedText,
                height: 2.0,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.creamPaper,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.lightBrown, width: 1),
              ),
              child: const Text(
                '"Cây có cội, nước có nguồn.\nCon người có tổ có tông."',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.deepGreen,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        return const CircularProgressIndicator();
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildVintagePhotoFrame() {
    final clan = ref.watch(clanNotifierProvider);
    return clan.when(
      data: (data) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.creamPaper,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.lightBrown, width: 8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBrown.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child:
                  data.first.soucreUrl == 'Chưa có ảnh'
                      ? Center(
                        child: Text(
                          'Chưa có ảnh',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.mutedText,
                            height: 2.0,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      )
                      : Image.network(
                        '${data.first.soucreUrl}',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: AppColors.lightBrown.withOpacity(0.3),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    size: 60,
                                    color: AppColors.mutedText,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Ảnh Gia Tộc',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.mutedText,
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
      error: (error, stackTrace) {
        return const CircularProgressIndicator();
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }

  // 3. FAMILY TREE PREVIEW
  Widget _buildFamilyTreePreview(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 10 : 40,
      ),
      color: AppColors.creamPaper,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildSectionHeader('Sơ Đồ Gia Phả'),
              const SizedBox(height: 20),
              const Text(
                'Dòng họ 25 thế hệ, hơn 600 thành viên',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedText,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 60),
              _buildFamilyTreeIllustration(isMobile),
              const SizedBox(height: 50),
              _buildVintageButton(
                text: 'Xem Cây Gia Phả Đầy Đủ',
                onPressed: () {
                  AppRouter.go(context, AppRouter.familyTree);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyTreeIllustration(bool isMobile) {
    return Container(
      height: isMobile ? 300 : 400,
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.sepiaTone.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple tree visualization
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildTreeNode('Tổ Tiên')],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTreeNode('Đời 2'),
                _buildTreeNode('Đời 2'),
                _buildTreeNode('Đời 2'),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                isMobile ? 4 : 6,
                (index) => _buildTreeNode('Đời 3'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '... và nhiều thế hệ khác',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeNode(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sepiaTone, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 4. GENERATIONS TIMELINE
  Widget _buildGenerationsTimeline(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final clan = ref.watch(clanNotifierProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 10 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              _buildSectionHeader('Các Thế Hệ'),
              const SizedBox(height: 60),
              clan.when(
                error: (error, stackTrace) {
                  return const CircularProgressIndicator();
                },
                loading: () {
                  return const CircularProgressIndicator();
                },
                data: (data) {
                  return Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children:
                        data.first.generations!
                            .map(
                              (generation) => _buildGenerationCard(generation),
                            )
                            .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationCard(Generation generations) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
        );
      },
      child: Container(
        width: 220,
        height: 260,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.creamPaper,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBrown, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBrown.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sepiaTone, width: 2),
                color: AppColors.warmBeige,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 30,
                color: AppColors.deepGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              generations.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
                fontFamily: 'PlayfairDisplay',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              generations.name,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.sepiaTone,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightBrown.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                generations.year,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. ANCESTRAL STORIES
  Widget _buildAncestralStories(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;
    final clan = ref.watch(clanNotifierProvider);

    return clan.when(
      data:
          (data) => Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 60 : 100,
              horizontal: isMobile ? 10 : 40,
            ),
            color: AppColors.creamPaper,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildSectionHeader('Câu Chuyện Tổ Tiên'),
                    const SizedBox(height: 30),
                    Column(
                      children:
                          data.first.stories!
                              .map((story) => _buildStoryCard(story))
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      error: (error, stackTrace) => const CircularProgressIndicator(),
      loading: () => const CircularProgressIndicator(),
    );
  }

  Widget _buildStoryCard(Story story) {
    return Column(
      children: [
        SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.warmBeige,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.lightBrown, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sepiaTone.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      story.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.deepGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                story.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 15),
              Text(
                story.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mutedText,
                  height: 1.8,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. PHOTO GALLERY PREVIEW
  Widget _buildPhotoGallery(BuildContext context) {
    final platform = ref.watch(flatformNotifierProvider);
    final isMobile = platform == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 10 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildSectionHeader('Thư Viện Ảnh'),
              const SizedBox(height: 20),
              const Text(
                'Những khoảnh khắc đáng nhớ của gia tộc',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedText,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 60),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 2 : 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: List.generate(8, (index) => _buildPhotoCard(index)),
              ),
              const SizedBox(height: 50),
              _buildVintageButton(text: 'Xem Thêm Ảnh', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.creamPaper,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.lightBrown, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.asset(
              'assets/images/image.png',
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: AppColors.lightBrown.withOpacity(0.2),
                    child: const Icon(
                      Icons.photo,
                      size: 40,
                      color: AppColors.mutedText,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrown,
            fontFamily: 'PlayfairDisplay',
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        _buildDecorativeLine(),
      ],
    );
  }

  Widget _buildDecorativeLine() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 40, height: 1.5, color: AppColors.sepiaTone),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sepiaTone,
          ),
        ),
        const SizedBox(width: 10),
        Container(width: 40, height: 1.5, color: AppColors.sepiaTone),
      ],
    );
  }

  Widget _buildVintageButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.creamPaper,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.deepGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.deepGreen,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
