import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner.dart';

class BasicCalculatorScreen extends StatefulWidget {
  const BasicCalculatorScreen({super.key});

  @override
  State<BasicCalculatorScreen> createState() => _BasicCalculatorScreenState();
}

class _BasicCalculatorScreenState extends State<BasicCalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        _expression = _expression.isNotEmpty ? _expression.substring(0, _expression.length - 1) : '';
        _result = '0';
      } else if (value == '=') {
        try {
          final val = _eval(_expression);
          _result = _formatNum(val);
          _expression = _result;
          AdService().onCalculationPerformed();
        } catch (_) {
          _result = 'Error';
        }
      } else if (value == '±') {
        if (_expression.isNotEmpty && _expression != '0') {
          _expression = _expression.startsWith('-') ? _expression.substring(1) : '-$_expression';
        }
      } else if (value == '%') {
        try {
          final val = _eval(_expression) / 100;
          _result = _formatNum(val);
          _expression = _result;
          AdService().onCalculationPerformed();
        } catch (_) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  String _formatNum(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
  }

  double _eval(String expr) {
    String e = expr.replaceAll('×', '*').replaceAll('÷', '/');

    final tokens = <String>[];
    final buf = StringBuffer();
    for (int i = 0; i < e.length; i++) {
      final ch = e[i];
      if ('+-*/()'.contains(ch)) {
        if (buf.isNotEmpty) tokens.add(buf.toString());
        buf.clear();
        if (ch == '-' && (tokens.isEmpty || tokens.last == '(' || '+-*/'.contains(tokens.last))) {
          tokens.add('NEG');
        } else {
          tokens.add(ch);
        }
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) tokens.add(buf.toString());

    final output = <String>[];
    final ops = <String>[];
    const precedence = {'+': 1, '-': 1, '*': 2, '/': 2, 'NEG': 3};

    for (final t in tokens) {
      if (double.tryParse(t) != null) {
        output.add(t);
      } else if (t == '(') {
        ops.add(t);
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          output.add(ops.removeLast());
        }
        ops.removeLast();
      } else {
        while (ops.isNotEmpty && ops.last != '(' && (precedence[ops.last] ?? 0) >= (precedence[t] ?? 0)) {
          output.add(ops.removeLast());
        }
        ops.add(t);
      }
    }
    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }

    final stack = <double>[];
    for (final t in output) {
      if (double.tryParse(t) != null) {
        stack.add(double.parse(t));
      } else if (t == 'NEG') {
        stack.add(-stack.removeLast());
      } else {
        final b = stack.removeLast(), a = stack.removeLast();
        switch (t) {
          case '+':
            stack.add(a + b);
          case '-':
            stack.add(a - b);
          case '*':
            stack.add(a * b);
          case '/':
            stack.add(a / b);
        }
      }
    }
    return stack.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          _buildRow(['C', '±', '%', '÷']),
          _buildRow(['7', '8', '9', '×']),
          _buildRow(['4', '5', '6', '-']),
          _buildRow(['1', '2', '3', '+']),
          _buildRow(['0', '.', '⌫', '=']),
          const AdBanner(),
        ],
      ),
    );
  }

  Widget _buildButton(String b) {
    final isOp = ['÷', '×', '-', '+', '='].contains(b);
    final isAct = ['C', '±', '%', '⌫'].contains(b);
    Color? bg;
    Color? fg;
    if (b == '=') {
      bg = Theme.of(context).colorScheme.primary;
      fg = Theme.of(context).colorScheme.onPrimary;
    } else if (isOp) {
      bg = Theme.of(context).colorScheme.primaryContainer;
      fg = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if (isAct) {
      bg = Theme.of(context).colorScheme.surfaceContainerHigh;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onPressed(b),
            child: Container(
              alignment: Alignment.center,
              height: 64,
              child: Text(
                b,
                style: TextStyle(
                  fontSize: b == '0' ? 28 : 22,
                  fontWeight: isOp ? FontWeight.bold : FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(children: buttons.map(_buildButton).toList()),
    );
  }
}
