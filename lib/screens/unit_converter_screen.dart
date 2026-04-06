import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _category = 'Longitud';
  String _fromUnit = 'Metros';
  String _toUnit = 'Pies';
  final _inputController = TextEditingController(text: '1');
  String _result = '';

  static const Map<String, Map<String, Map<String, double>>> conversions = {
    'Longitud': {
      'Metros': {'Metros': 1, 'Pies': 3.28084, 'Pulgadas': 39.3701, 'Centímetros': 100, 'Kilómetros': 0.001},
      'Pies': {'Metros': 0.3048, 'Pies': 1, 'Pulgadas': 12, 'Centímetros': 30.48, 'Kilómetros': 0.0003048},
      'Pulgadas': {'Metros': 0.0254, 'Pies': 0.083333, 'Pulgadas': 1, 'Centímetros': 2.54, 'Kilómetros': 0.0000254},
      'Centímetros': {'Metros': 0.01, 'Pies': 0.0328084, 'Pulgadas': 0.393701, 'Centímetros': 1, 'Kilómetros': 0.00001},
      'Kilómetros': {'Metros': 1000, 'Pies': 3280.84, 'Pulgadas': 39370.1, 'Centímetros': 100000, 'Kilómetros': 1},
    },
    'Peso': {
      'Kilos': {'Kilos': 1, 'Libras': 2.20462, 'Onzas': 35.274, 'Gramos': 1000},
      'Libras': {'Kilos': 0.453592, 'Libras': 1, 'Onzas': 16, 'Gramos': 453.592},
      'Onzas': {'Kilos': 0.0283495, 'Libras': 0.0625, 'Onzas': 1, 'Gramos': 28.3495},
      'Gramos': {'Kilos': 0.001, 'Libras': 0.00220462, 'Onzas': 0.035274, 'Gramos': 1},
    },
    'Temperatura': {}, // handled specially
    'Volumen': {
      'Litros': {'Litros': 1, 'Galones': 0.264172, 'Mililitros': 1000, 'Onzas (fl)': 33.814},
      'Galones': {'Litros': 3.78541, 'Galones': 1, 'Mililitros': 3785.41, 'Onzas (fl)': 128},
      'Mililitros': {'Litros': 0.001, 'Galones': 0.000264172, 'Mililitros': 1, 'Onzas (fl)': 0.033814},
      'Onzas (fl)': {'Litros': 0.0295735, 'Galones': 0.0078125, 'Mililitros': 29.5735, 'Onzas (fl)': 1},
    },
  };

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) { setState(() => _result = ''); return; }

    double result;
    if (_category == 'Temperatura') {
      result = _convertTemp(input);
    } else {
      final fromRate = conversions[_category]?[_fromUnit]?[_toUnit];
      if (fromRate == null) { setState(() => _result = ''); return; }
      result = input * fromRate;
    }

    setState(() {
      _result = result == result.roundToDouble() ? result.toInt().toString() : result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    });
    AdService().onCalculationPerformed();
  }

  double _convertTemp(double value) {
    // Convert to Celsius first
    double celsius;
    if (_fromUnit == 'Celsius') celsius = value;
    else if (_fromUnit == 'Fahrenheit') celsius = (value - 32) * 5 / 9;
    else celsius = value - 273.15; // Kelvin

    // Convert from Celsius to target
    if (_toUnit == 'Celsius') return celsius;
    if (_toUnit == 'Fahrenheit') return celsius * 9 / 5 + 32;
    return celsius + 273.15; // Kelvin
  }

  List<String> get _categories => conversions.keys.toList();
  List<String> get _units {
    if (_category == 'Temperatura') return ['Celsius', 'Fahrenheit', 'Kelvin'];
    return conversions[_category]?.keys.toList() ?? [];
  }

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conversor de unidades')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _category = v;
                  _fromUnit = _units.first;
                  _toUnit = _units.length > 1 ? _units[1] : _units.first;
                });
                _convert();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _fromUnit,
              decoration: const InputDecoration(labelText: 'De', border: OutlineInputBorder()),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _fromUnit = v); _convert(); } },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _toUnit,
              decoration: const InputDecoration(labelText: 'A', border: OutlineInputBorder()),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _toUnit = v); _convert(); } },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('$_inputController.text $_fromUnit =', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(_toUnit, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}
