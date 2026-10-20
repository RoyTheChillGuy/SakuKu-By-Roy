import 'package:flutter/material.dart';

import '../../core/theme/glass.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/models.dart';

class AccountChipCard extends StatelessWidget {
  const AccountChipCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = IconMapper.colorFromHex(account.colorHex);

    return SizedBox(
      width: 168,
      height: 128,
      child: GlassCard(
        tint: color.withValues(alpha: 0.12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.18),
              child: Icon(
                IconMapper.fromKey(account.icon),
                color: color,
                size: 18,
              ),
            ),
            const Spacer(),
            Text(
              account.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormat.idrCompact(account.currentBalance),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
