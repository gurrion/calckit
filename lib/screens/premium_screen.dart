import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/premium_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sin anuncios')),
      body: Consumer<PremiumService>(
        builder: (_, premium, __) {
          if (premium.isPremium) {
            return const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.verified, size: 64, color: Colors.amber),
                SizedBox(height: 16),
                Text('¡Ya eres Pro!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Disfruta sin anuncios'),
              ]),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text('Elimina los anuncios', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Una sola compra. Sin suscripción. Para siempre.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () async {
                  final success = await premium.purchasePremium();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? '¡Gracias! Activado.' : 'Error. Intenta de nuevo.')),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text('Comprar Pro — \$2.99'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await premium.restorePurchases();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compras restauradas')));
                },
                child: const Text('Restaurar compras'),
              ),
            ]),
          );
        },
      ),
    );
  }
}
