import 'package:flutter/material.dart';
import '../../services/ad_service.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final adService = AdService();
    if (!adService.isInitialized) return const SizedBox.shrink();

    return adService.isBannerLoaded
        ? Center(child: adService.bannerWidget)
        : const SizedBox.shrink();
  }
}
