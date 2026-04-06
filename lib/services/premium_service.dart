import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static final PremiumService _instance = PremiumService._();
  factory PremiumService() => _instance;
  PremiumService._();

  bool _isPremium = false;
  static const String _premiumKey = 'is_premium';
  // TODO: Reemplazar con tu product ID de Google Play Console
  static const String _productId = 'calckit_premium_remove_ads';

  bool get isPremium => _isPremium;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    // Verificar purchase existente con Google Play
    final purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: () {},
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    await _restorePurchases();
    notifyListeners();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == _productId) {
          _setPremium(true);
        }
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  Future<bool> purchasePremium() async {
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) return false;

      final response = await InAppPurchase.instance.queryProductDetails({_productId});
      if (response.productDetails.isEmpty) return false;

      final purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      final success = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }
}
