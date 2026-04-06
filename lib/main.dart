import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/ad_service.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().initialize();
  await PremiumService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PremiumService()),
      ],
      child: const CalcKitApp(),
    ),
  );
}
