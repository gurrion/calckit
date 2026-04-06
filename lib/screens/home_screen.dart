import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_service.dart';
import '../widgets/ad_banner.dart';
import 'basic_calculator_screen.dart';
import 'loan_calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'bmi_calculator_screen.dart';
import 'tip_calculator_screen.dart';
import 'discount_calculator_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CalcKit'),
        centerTitle: true,
        actions: [
          Consumer<PremiumService>(
            builder: (_, premium, __) {
              if (premium.isPremium) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Chip(
                    avatar: Icon(Icons.star, color: Colors.amber, size: 18),
                    label: Text('Pro', style: TextStyle(fontSize: 12)),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.workspace_premium),
                onPressed: () => _navigateTo(context, const PremiumScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildCategory('Cálculos básicos'),
            _buildCard(
              context,
              icon: Icons.calculate,
              title: 'Calculadora',
              subtitle: 'Operaciones básicas',
              color: Colors.deepPurple,
              onTap: () => _navigateTo(context, const BasicCalculatorScreen()),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.percent,
              title: 'Descuentos',
              subtitle: 'Calcula precio final',
              color: Colors.orange,
              onTap: () => _navigateTo(context, const DiscountCalculatorScreen()),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.attach_money,
              title: 'Propinas',
              subtitle: 'Divide la cuenta',
              color: Colors.green,
              onTap: () => _navigateTo(context, const TipCalculatorScreen()),
            ),
            const SizedBox(height: 24),
            _buildCategory('Finanzas'),
            _buildCard(
              context,
              icon: Icons.account_balance,
              title: 'Préstamos',
              subtitle: 'Cuota mensual, intereses',
              color: Colors.blue,
              onTap: () => _navigateTo(context, const LoanCalculatorScreen()),
            ),
            const SizedBox(height: 24),
            _buildCategory('Herramientas'),
            _buildCard(
              context,
              icon: Icons.swap_horiz,
              title: 'Conversor de unidades',
              subtitle: 'Longitud, peso, temperatura',
              color: Colors.teal,
              onTap: () => _navigateTo(context, const UnitConverterScreen()),
            ),
            const SizedBox(height: 12),
            _buildCard(
              context,
              icon: Icons.monitor_weight,
              title: 'IMC',
              subtitle: 'Índice de masa corporal',
              color: Colors.pink,
              onTap: () => _navigateTo(context, const BmiCalculatorScreen()),
            ),
            const SizedBox(height: 16),
            const AdBanner(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
