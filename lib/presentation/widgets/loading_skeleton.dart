import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/theme/glass.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 10,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const GlassCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Saldo'),
                SizedBox(height: 8),
                Text('Rp 12.500.000'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Text('Pemasukan\nRp 2.000.000'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Text('Pengeluaran\nRp 800.000'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Dompet'),
          const SizedBox(height: 12),
          const GlassCard(
            child: ListTile(
              title: Text('Dompet Tunai'),
              subtitle: Text('Tunai'),
              trailing: Text('Rp 500.000'),
            ),
          ),
          const SizedBox(height: 10),
          const GlassCard(
            child: ListTile(
              title: Text('Transaksi terbaru'),
              subtitle: Text('Belanja harian'),
            ),
          ),
        ],
      ),
    );
  }
}
