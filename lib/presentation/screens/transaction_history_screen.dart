import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/form_menu_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/async_value_x.dart';
import '../../core/utils/date_labels.dart';
import '../../data/models/models.dart';
import '../../data/repositories/transaction_repository.dart';
import '../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_bottom_sheet.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(transactionFilterProvider);
    final transactions = ref.watch(transactionListProvider);
    final categories = ref.watch(categoryListProvider);
    final accounts = ref.watch(accountListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: () => _openFilterSheet(context),
            icon: Badge(
              isLabelVisible: filter.accountId != null ||
                  filter.categoryId != null ||
                  filter.type != null,
              child: const Icon(LucideIcons.slidersHorizontal),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari catatan atau tag…',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          _FilterChips(filter: filter),
          Expanded(
            child: transactions.when(
              data: (list) {
                final cats = categories.dataOrNull ?? const <Category>[];
                final accs = accounts.dataOrNull ?? const <Account>[];
                final filtered = list.where((tx) {
                  if (_query.isEmpty) return true;
                  final note = tx.note?.toLowerCase() ?? '';
                  final tags = tx.tags.join(' ').toLowerCase();
                  final catName = cats
                          .where((c) => c.id == tx.categoryId)
                          .map((c) => c.name.toLowerCase())
                          .firstOrNull ??
                      '';
                  return note.contains(_query) ||
                      tags.contains(_query) ||
                      catName.contains(_query);
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    message: 'Belum ada transaksi bulan ini',
                    actionLabel: 'Tambah transaksi',
                    onAction: () => showAddTransactionSheet(context),
                  );
                }

                final groups = _groupByDate(filtered);
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(transactionListProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              group.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          ...group.items.map((tx) {
                            final cat = cats.cast<Category?>().firstWhere(
                                  (c) => c?.id == tx.categoryId,
                                  orElse: () => null,
                                );
                            final acc = accs.cast<Account?>().firstWhere(
                                  (a) => a?.id == tx.accountId,
                                  orElse: () => null,
                                );
                            return Dismissible(
                              key: ValueKey('tx-${tx.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: theme.colorScheme.error,
                                child: Icon(
                                  LucideIcons.trash2,
                                  color: theme.colorScheme.onError,
                                ),
                              ),
                              confirmDismiss: (_) => _confirmDelete(tx),
                              onDismissed: (_) async {
                                await ref
                                    .read(transactionListProvider.notifier)
                                    .remove(tx.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Transaksi dihapus'),
                                    ),
                                  );
                                }
                              },
                              child: TransactionTile(
                                transaction: tx,
                                category: cat,
                                accountName: acc?.name,
                                onTap: () => showAddTransactionSheet(
                                  context,
                                  existing: tx,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    LoadingSkeleton(height: 64),
                    SizedBox(height: 10),
                    LoadingSkeleton(height: 64),
                    SizedBox(height: 10),
                    LoadingSkeleton(height: 64),
                  ],
                ),
              ),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(Transaction tx) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text(
          'Saldo akun akan disesuaikan otomatis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Theme(
        data: formMenusTheme(ctx),
        child: const GlassSheetShell(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: _TransactionFilterSheet(),
        ),
      ),
    );
  }

  List<_TxGroup> _groupByDate(List<Transaction> list) {
    final map = <String, List<Transaction>>{};
    for (final tx in list) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day)
          .toIso8601String();
      map.putIfAbsent(key, () => []).add(tx);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        _TxGroup(
          label: DateLabels.sectionHeader(DateTime.parse(key)),
          items: map[key]!,
        ),
    ];
  }
}

class _TxGroup {
  const _TxGroup({required this.label, required this.items});
  final String label;
  final List<Transaction> items;
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filter});

  final TransactionFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = <Widget>[];
    if (filter.start != null) {
      chips.add(
        InputChip(
          label: Text(DateLabels.monthYear(filter.start!)),
          onDeleted: () {
            ref.read(transactionFilterProvider.notifier).clear();
            ref.read(transactionFilterProvider.notifier).resetToCurrentMonth();
          },
        ),
      );
    }
    if (filter.accountId != null) {
      final accounts = ref.watch(accountListProvider).dataOrNull ?? [];
      final name = accounts
          .where((a) => a.id == filter.accountId)
          .map((a) => a.name)
          .firstOrNull;
      chips.add(
        InputChip(
          label: Text(name ?? 'Akun'),
          onDeleted: () =>
              ref.read(transactionFilterProvider.notifier).setAccount(null),
        ),
      );
    }
    if (filter.categoryId != null) {
      final cats = ref.watch(categoryListProvider).dataOrNull ?? [];
      final name = cats
          .where((c) => c.id == filter.categoryId)
          .map((c) => c.name)
          .firstOrNull;
      chips.add(
        InputChip(
          label: Text(name ?? 'Kategori'),
          onDeleted: () =>
              ref.read(transactionFilterProvider.notifier).setCategory(null),
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _TransactionFilterSheet extends ConsumerWidget {
  const _TransactionFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterProvider);
    final accounts = ref.watch(accountListProvider).dataOrNull ?? [];
    final categories = ref.watch(categoryListProvider).dataOrNull ?? [];
    final month = filter.start ?? DateTime.now();

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(LucideIcons.calendar),
            title: Text(DateLabels.monthYear(month)),
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: month,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                helpText: 'Pilih bulan',
              );
              if (picked != null) {
                final start = DateTime(picked.year, picked.month, 1);
                final end =
                    DateTime(picked.year, picked.month + 1, 0, 23, 59, 59);
                ref
                    .read(transactionFilterProvider.notifier)
                    .setDateRange(start: start, end: end);
              }
            },
          ),
          DropdownButtonFormField<int?>(
            dropdownColor: Glass.modalSurface(context),
            key: ValueKey('filter-account-${filter.accountId}'),
            initialValue: filter.accountId,
            decoration: const InputDecoration(labelText: 'Akun'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua akun')),
              ...accounts.map(
                (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
              ),
            ],
            onChanged: (v) =>
                ref.read(transactionFilterProvider.notifier).setAccount(v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            dropdownColor: Glass.modalSurface(context),
            key: ValueKey('filter-category-${filter.categoryId}'),
            initialValue: filter.categoryId,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Semua kategori'),
              ),
              ...categories.map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (v) =>
                ref.read(transactionFilterProvider.notifier).setCategory(v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TransactionType?>(
            dropdownColor: Glass.modalSurface(context),
            key: ValueKey('filter-type-${filter.type}'),
            initialValue: filter.type,
            decoration: const InputDecoration(labelText: 'Tipe'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Semua tipe')),
              DropdownMenuItem(
                value: TransactionType.expense,
                child: Text('Pengeluaran'),
              ),
              DropdownMenuItem(
                value: TransactionType.income,
                child: Text('Pemasukan'),
              ),
              DropdownMenuItem(
                value: TransactionType.transfer,
                child: Text('Transfer'),
              ),
            ],
            onChanged: (v) =>
                ref.read(transactionFilterProvider.notifier).setType(v),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(transactionFilterProvider.notifier).clear();
                    ref
                        .read(transactionFilterProvider.notifier)
                        .resetToCurrentMonth();
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
    );
  }
}
