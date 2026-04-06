import 'dart:math';
import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final _amountController = TextEditingController(text: '100000');
  final _rateController = TextEditingController(text: '5.0');
  final _monthsController = TextEditingController(text: '36');

  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 0;

    if (amount <= 0 || annualRate <= 0 || months <= 0) {
      setState(() { _monthlyPayment = _totalPayment = _totalInterest = null; });
      return;
    }

    final monthlyRate = annualRate / 100 / 12;
    final factor = pow(1 + monthlyRate, months);
    final monthly = amount * (monthlyRate * factor) / (factor - 1);
    final total = monthly * months;
    final interest = total - amount;

    setState(() {
      _monthlyPayment = monthly;
      _totalPayment = total;
      _totalInterest = interest;
    });
    AdService().onCalculationPerformed();
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de préstamos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(_amountController, 'Monto del préstamo', '\$', '100000'),
            const SizedBox(height: 16),
            _buildField(_rateController, 'Tasa de interés anual', '%', '5.0'),
            const SizedBox(height: 16),
            _buildField(_monthsController, 'Plazo', 'meses', '36'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _calculate,
              child: const Text('Calcular', style: TextStyle(fontSize: 16)),
            ),
            if (_monthlyPayment != null) ...[
              const SizedBox(height: 32),
              _ResultCard(label: 'Cuota mensual', value: '\$${_formatNumber(_monthlyPayment!)}', color: Colors.blue),
              const SizedBox(height: 12),
              _ResultCard(label: 'Total a pagar', value: '\$${_formatNumber(_totalPayment!)}', color: Colors.orange),
              const SizedBox(height: 12),
              _ResultCard(label: 'Intereses totales', value: '\$${_formatNumber(_totalInterest!)}', color: Colors.red),
            ],
            const SizedBox(height: 24),
            const AdBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, String suffix, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String _formatNumber(double n) => n.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
