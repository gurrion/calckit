import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService with ChangeNotifier {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  bool _isInitialized = false;
  int _calcCount = 0;
  static const int _interstitialEvery = 4;

  // TODO: Reemplazar con tus AdMob IDs reales
  static String get bannerAdUnitId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/6300978111'; // test
    if (Platform.isAndroid) return 'ca-app-pub-XXXX/XXXX'; // reemplazar
    return 'ca-app-pub-XXXX/XXXX'; // iOS
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712'; // test
    if (Platform.isAndroid) return 'ca-app-pub-XXXX/XXXX'; // reemplazar
    return 'ca-app-pub-XXXX/XXXX'; // iOS
  }

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  bool get isInitialized => _isInitialized;
  bool get isBannerLoaded => _isBannerLoaded;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _isInitialized = true;
    _loadBanner();
    _loadInterstitial();
    notifyListeners();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          _isBannerLoaded = false;
        },
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialReady = false;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed: $error');
          _isInterstitialReady = false;
        },
      ),
    );
  }

  Widget get bannerWidget {
    if (!_isBannerLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  void onCalculationPerformed() {
    _calcCount++;
    if (_calcCount >= _interstitialEvery) {
      _calcCount = 0;
      showInterstitial();
    }
  }

  void showInterstitial() {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _isInterstitialReady = false;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
