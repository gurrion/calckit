import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final _weightController = TextEditingController(text: '70');
  final _heightController = TextEditingController(text: '170');
  double? _bmi;

  void _calculate() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final heightCm = double.tryParse(_heightController.text) ?? 0;
    if (weight <= 0 || heightCm <= 0) { setState(() => _bmi = null); return; }

    final heightM = heightCm / 100;
    setState(() => _bmi = weight / (heightM * heightM));
    AdService().onCalculationPerformed();
  }

  String get _category {
    if (_bmi == null) return '';
    if (_bmi! < 18.5) return 'Bajo peso';
    if (_bmi! < 25) return 'Normal';
    if (_bmi! < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color get _categoryColor {
    if (_bmi == null) return Colors.grey;
    if (_bmi! < 18.5) return Colors.blue;
    if (_bmi! < 25) return Colors.green;
    if (_bmi! < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() { super.initState(); _calculate(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de IMC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder(), suffixText: 'kg'),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Altura (cm)', border: OutlineInputBorder(), suffixText: 'cm'),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _calculate, child: const Text('Calcular', style: TextStyle(fontSize: 16))),
            if (_bmi != null) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text('Tu IMC', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _categoryColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_category, style: TextStyle(color: _categoryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildScale(),
            ],
            const SizedBox(height: 24),
            const AdBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scaleRow('Bajo peso', '< 18.5', Colors.blue),
        _scaleRow('Normal', '18.5 – 24.9', Colors.green),
        _scaleRow('Sobrepeso', '25.0 – 29.9', Colors.orange),
        _scaleRow('Obesidad', '≥ 30.0', Colors.red),
      ],
    );
  }

  Widget _scaleRow(String label, String range, Color color) {
    final isActive = _bmi != null && (
      (label == 'Bajo peso' && _bmi! < 18.5) ||
      (label == 'Normal' && _bmi! >= 18.5 && _bmi! < 25) ||
      (label == 'Sobrepeso' && _bmi! >= 25 && _bmi! < 30) ||
      (label == 'Obesidad' && _bmi! >= 30)
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isActive ? color : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          Text(range, style: TextStyle(color: isActive ? color : Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
