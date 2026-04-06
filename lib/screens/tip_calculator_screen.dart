import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final _billController = TextEditingController(text: '50');
  double _tipPercent = 15;
  int _splitPeople = 1;
  double get _tipAmount => (double.tryParse(_billController.text) ?? 0) * _tipPercent / 100;
  double get _total => (double.tryParse(_billController.text) ?? 0) + _tipAmount;
  double get _perPerson => _splitPeople > 0 ? _total / _splitPeople.toDouble() : _total;

  void _notify() => AdService().onCalculationPerformed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de propinas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _billController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Total de la cuenta', border: OutlineInputBorder(), prefixText: '\$'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('Propina: $_tipPercent%', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _tipPercent.toDouble(),
              min: 0,
              max: 50,
              divisions: 50,
              label: '$_tipPercent%',
              onChanged: (v) => setState(() => _tipPercent = v.roundToDouble()),
              onChangeEnd: (_) => _notify(),
            ),
            Wrap(
              spacing: 8,
              children: [10, 15, 18, 20, 25].map((p) {
                final selected = _tipPercent == p;
                return ChoiceChip(
                  label: Text('$p%'),
                  selected: selected,
                  onSelected: (_) => setState(() { _tipPercent = p.toDouble(); _notify(); }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Dividir entre:', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.remove), onPressed: _splitPeople > 1 ? () => setState(() => _splitPeople--) : null),
                Text('$_splitPeople', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _splitPeople++)),
              ],
            ),
            const SizedBox(height: 24),
            _ResultRow(label: 'Propina', value: '\$${_tipAmount.toStringAsFixed(2)}'),
            const Divider(),
            _ResultRow(label: 'Total', value: '\$${_total.toStringAsFixed(2)}', bold: true),
            const Divider(),
            if (_splitPeople > 1)
              _ResultRow(label: 'Cada persona', value: '\$${_perPerson.toStringAsFixed(2)}', bold: true),
            const SizedBox(height: 24),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _ResultRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 18 : 15, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: bold ? 20 : 16, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
