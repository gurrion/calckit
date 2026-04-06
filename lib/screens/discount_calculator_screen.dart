import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() => _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  final _priceController = TextEditingController(text: '100');
  final _discountController = TextEditingController(text: '20');

  double get _originalPrice => double.tryParse(_priceController.text) ?? 0;
  double get _discountPercent => double.tryParse(_discountController.text) ?? 0;
  double get _saved => _originalPrice * _discountPercent / 100;
  double get _finalPrice => _originalPrice - _saved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de descuentos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Precio original', border: OutlineInputBorder(), prefixText: '\$'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Descuento', border: OutlineInputBorder(), suffixText: '%'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => setState(() => AdService().onCalculationPerformed()),
              child: const Text('Calcular', style: TextStyle(fontSize: 16)),
            ),
            if (_originalPrice > 0 && _discountPercent > 0) ...[
              const SizedBox(height: 32),
              Card(
                color: Colors.red.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ahorras', style: TextStyle(color: Colors.red, fontSize: 13)),
                      Text('-\$${_saved.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.green.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Precio final', style: TextStyle(color: Colors.green, fontSize: 13)),
                      Text('\$${_finalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}
