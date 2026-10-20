import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/models.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.accountName,
    this.onTap,
  });

  final Transaction transaction;
  final Category? category;
  final String? accountName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    final color = isTransfer
        ? AppTheme.transfer
        : isExpense
            ? AppTheme.expense
            : AppTheme.income;
    final iconKey = isTransfer
        ? 'arrow-left-right'
        : category?.icon;
    final title = isTransfer
        ? 'Transfer'
        : (category?.name ?? transaction.note ?? 'Transaksi');
    final note = transaction.note;
    final subtitle = [
      ?accountName,
      if (note != null && note.isNotEmpty && !isTransfer) note,
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: (category != null
                ? IconMapper.colorFromHex(category!.colorHex)
                : color)
            .withValues(alpha: 0.15),
        child: Icon(
          IconMapper.fromKey(iconKey),
          color: category != null
              ? IconMapper.colorFromHex(category!.colorHex)
              : color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Text(
        isTransfer
            ? CurrencyFormat.idr(transaction.amount)
            : CurrencyFormat.signed(
                transaction.amount,
                isExpense: isExpense,
              ),
        style: theme.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
