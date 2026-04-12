import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;

class AdService {
  // --- PRODUCTION AD IDs ---
  static const String bannerAdId = 'ca-app-pub-8332245407031327/3554644969';
  static const String interstitialAdId = 'ca-app-pub-8332245407031327/9437527037';

  // Toggle this to true for Production
  static const bool isProduction = true;

  // No longer using test IDs for this request
  static String get currentBannerId => bannerAdId;
  static String get currentInterstitialId => interstitialAdId;
}

class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.currentBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 50, // Standard banner height
      color: Colors.grey[100], // Visible placeholder
      child: _isLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : const Text('Loading Ad...', style: TextStyle(fontSize: 10, color: Colors.grey)),
    );
  }
}

class InterstitialAdManager {
  static final InterstitialAdManager _instance = InterstitialAdManager._internal();
  static InterstitialAdManager get instance => _instance;

  InterstitialAdManager._internal() {
    loadAd();
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdService.currentInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showAdWithLoading(BuildContext context, {required VoidCallback onComplete}) {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          loadAd(); // Preload next
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _isAdLoaded = false;
          _interstitialAd = null;
          loadAd();
          onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      // Ad is not ready. Do NOT freeze the app. Just proceed.
      print('Ad not ready. Proceeding instantly.');
      onComplete();
    }
  }

  @Deprecated('Use showAdWithLoading')
  Future<void> showAd({required VoidCallback onComplete}) async {
    onComplete();
  }
}
