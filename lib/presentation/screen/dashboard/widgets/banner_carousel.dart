import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/offer/banner_model.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';

class BannerCarousel extends StatefulWidget {
  final List<OfferBanner> banners;
  const BannerCarousel({
    Key? key,
    required this.banners,
  }) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with FadeInAnimationMixin {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Reduced height from 150 to 100
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(context, widget.banners[index], index);
            },
          ),
        ),
        //const SizedBox(height: 8),
        //_buildIndicator(),
      ],
    );
  }

  Widget _buildBannerItem(BuildContext context, OfferBanner banner, int index) {
    return GestureDetector(
      onTap: () {
        if (banner.offer != null) {
          context.go('/dashboard/offers', extra: banner.offer);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: fadeIn(
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  banner.image,
                  width: double.infinity,
                  height: 100, // Reduced height from 150 to 100
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 100, // Reduced height from 150 to 100
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Theme.of(context).colorScheme.primary,
                        size: 48,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          delay: index * 100,
        ),
      ).animate().fadeIn(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: index * 100),
          ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) => Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
