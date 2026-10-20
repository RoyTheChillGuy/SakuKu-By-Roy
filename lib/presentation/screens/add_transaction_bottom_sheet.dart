import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/models/receipt_scan_prefill.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/form_menu_theme.dart';
import '../../core/theme/glass.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/date_labels.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/models.dart';
import '../../data/services/receipt_storage.dart';
import '../providers/providers.dart';

Future<void> showAddTransactionSheet(
  BuildContext context, {
  Transaction? existing,
  XFile? initialReceipt,
  ReceiptScanPrefill? scanPrefill,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    isDismissible: true,
    enableDrag: true,
    builder: (ctx) => Theme(
      data: formMenusTheme(ctx),
      child: AddTransactionBottomSheet(
        existing: existing,
        initialReceipt: initialReceipt,
        scanPrefill: scanPrefill,
      ),
    ),
  );
}

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({
    super.key,
    this.existing,
    this.initialReceipt,
    this.scanPrefill,
  });

  final Transaction? existing;
  final XFile? initialReceipt;
  final ReceiptScanPrefill? scanPrefill;

  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  late TransactionType _type;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _tagsCtrl;
  late DateTime _date;
  int? _accountId;
  int? _targetAccountId;
  int? _categoryId;
  bool _saving = false;
  XFile? _receiptFile;
  String? _receiptPath;
  bool _categoryFromScanApplied = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? TransactionType.expense;
    _date = existing?.date ?? DateTime.now();
    _accountId = existing?.accountId;
    _targetAccountId = existing?.targetAccountId;
    _categoryId = existing?.categoryId;
    _receiptPath = existing?.imagePath;
    _receiptFile = widget.initialReceipt;
    _amountCtrl = TextEditingController(
      text: existing == null
          ? ''
          : CurrencyFormat.formatInputDigits(existing.amount.round().toString()),
    );
    _noteCtrl = TextEditingController(text: existing?.note ?? '');
    _tagsCtrl = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    if (existing == null && widget.scanPrefill != null) {
      _applyScanPrefill(widget.scanPrefill!);
    }
  }

  void _applyScanPrefill(ReceiptScanPrefill prefill) {
    if (prefill.amount != null && prefill.amount! > 0) {
      _amountCtrl.text = CurrencyFormat.formatInputDigits(
        prefill.amount!.round().toString(),
      );
    }
    if (prefill.date != null) {
      _date = prefill.date!;
    }
    if (prefill.merchantHint != null && prefill.merchantHint!.isNotEmpty) {
      _noteCtrl.text = prefill.merchantHint!;
    }
    if (prefill.suggestedCategoryName == 'Salary') {
      _type = TransactionType.income;
    } else if (prefill.suggestedCategoryName != null) {
      _type = TransactionType.expense;
    }
  }

  Category? _matchCategoryByName(List<Category> categories, String name) {
    for (final c in categories) {
      if (c.name.toLowerCase() == name.toLowerCase()) return c;
    }
    final token = name.split(' ').first.toLowerCase();
    for (final c in categories) {
      if (c.name.toLowerCase().contains(token)) return c;
    }
    return null;
  }

  void _scheduleCategoryFromScan(List<Category> categories) {
    if (_categoryFromScanApplied || widget.scanPrefill == null) return;
    final name = widget.scanPrefill!.suggestedCategoryName;
    if (name == null || name.isEmpty) return;
    final match = _matchCategoryByName(categories, name);
    if (match == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _categoryFromScanApplied) return;
      setState(() {
        _categoryId = match.id;
        _categoryFromScanApplied = true;
      });
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accounts = ref.watch(accountListProvider);
    final categoryType = _type == TransactionType.income
        ? CategoryType.income
        : CategoryType.expense;
    final categories = _type == TransactionType.transfer
        ? const AsyncData(<Category>[])
        : ref.watch(categoriesByTypeProvider(categoryType));

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return GlassSheetShell(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text(
                  _isEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
                  style: theme.textTheme.titleLarge,
                ),
                if (widget.scanPrefill?.hasData == true) ...[
                  const SizedBox(height: 10),
                  Material(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.scanLine,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Diisi otomatis dari scan struk — cek nominal & kategori.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Keluar'),
                      icon: Icon(LucideIcons.arrowUpRight, size: 16),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Masuk'),
                      icon: Icon(LucideIcons.arrowDownLeft, size: 16),
                    ),
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text('Transfer'),
                      icon: Icon(LucideIcons.arrowLeftRight, size: 16),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) {
                    setState(() {
                      _type = value.first;
                      _categoryId = null;
                      if (_type != TransactionType.transfer) {
                        _targetAccountId = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text('Jumlah', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _type == TransactionType.income
                        ? AppTheme.income
                        : _type == TransactionType.expense
                            ? AppTheme.expense
                            : AppTheme.transfer,
                  ),
                  decoration: const InputDecoration(
                    prefixText: 'Rp ',
                    hintText: '0',
                  ),
                  onChanged: (value) {
                    final formatted = CurrencyFormat.formatInputDigits(value);
                    if (formatted != value) {
                      _amountCtrl.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                accounts.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Text('Belum ada akun. Tambahkan akun dulu.');
                    }
                    _accountId ??= list.first.id;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _type == TransactionType.transfer
                              ? 'Dari akun'
                              : 'Akun',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          dropdownColor: Glass.modalSurface(context),
                          key: ValueKey('from-$_accountId-$_type'),
                          initialValue: list.any((a) => a.id == _accountId)
                              ? _accountId
                              : list.first.id,
                          items: list
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _accountId = v),
                        ),
                        if (_type == TransactionType.transfer) ...[
                          const SizedBox(height: 16),
                          Text('Ke akun', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            dropdownColor: Glass.modalSurface(context),
                            key: ValueKey('to-$_targetAccountId-$_accountId'),
                            initialValue: _targetAccountId != null &&
                                    list.any((a) => a.id == _targetAccountId)
                                ? _targetAccountId
                                : null,
                            hint: const Text('Pilih akun tujuan'),
                            items: list
                                .where((a) => a.id != _accountId)
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _targetAccountId = v),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal memuat akun: $e'),
                ),
                if (_type != TransactionType.transfer) ...[
                  const SizedBox(height: 20),
                  Text('Kategori', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  categories.when(
                  data: (cats) {
                    if (cats.isEmpty) {
                      return const Text('Belum ada kategori.');
                    }
                    _scheduleCategoryFromScan(cats);
                    return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cats.map((cat) {
                          final selected = _categoryId == cat.id;
                          final color = IconMapper.colorFromHex(cat.colorHex);
                          return ChoiceChip(
                            selected: selected,
                            avatar: Icon(
                              IconMapper.fromKey(cat.icon),
                              size: 16,
                              color: selected ? Colors.white : color,
                            ),
                            label: Text(cat.name),
                            selectedColor: color,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) =>
                                setState(() => _categoryId = cat.id),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Gagal memuat kategori: $e'),
                  ),
                ],
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.calendar),
                  title: Text(DateLabels.shortDate(_date)),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Catatan',
                    hintText: 'Opsional',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tag',
                    hintText: 'pisahkan dengan koma',
                  ),
                ),
                const SizedBox(height: 20),
                Text('Struk / foto', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _ReceiptSection(
                  receiptFile: _receiptFile,
                  savedPath: _receiptPath,
                  onPick: _pickReceipt,
                  onRemove: () => setState(() {
                    _receiptFile = null;
                    _receiptPath = null;
                  }),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file != null && mounted) {
      setState(() {
        _receiptFile = file;
        _receiptPath = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _date.hour,
          _date.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final amount = CurrencyFormat.parseInput(_amountCtrl.text);
    if (amount <= 0) {
      _toast('Masukkan jumlah yang valid');
      return;
    }
    if (_accountId == null) {
      _toast('Pilih akun sumber');
      return;
    }
    if (_type != TransactionType.transfer && _categoryId == null) {
      _toast('Pilih kategori');
      return;
    }
    if (_type == TransactionType.transfer && _targetAccountId == null) {
      _toast('Pilih akun tujuan');
      return;
    }

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    String? imagePath = _receiptPath;
    if (_receiptFile != null) {
      imagePath = await ReceiptStorage.persistReceipt(_receiptFile!);
    }

    final tx = widget.existing ?? Transaction();
    tx
      ..amount = amount
      ..date = _date
      ..type = _type
      ..accountId = _accountId!
      ..targetAccountId =
          _type == TransactionType.transfer ? _targetAccountId : null
      ..categoryId =
          _type == TransactionType.transfer ? null : _categoryId
      ..note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()
      ..tags = tags
      ..imagePath = imagePath;

    setState(() => _saving = true);
    try {
      final notifier = ref.read(transactionListProvider.notifier);
      if (_isEdit) {
        await notifier.updateTransaction(tx);
      } else {
        await notifier.add(tx);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _toast('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({
    required this.receiptFile,
    required this.savedPath,
    required this.onPick,
    required this.onRemove,
  });

  final XFile? receiptFile;
  final String? savedPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        receiptFile != null || (savedPath != null && savedPath!.isNotEmpty);

    if (!hasImage) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(LucideIcons.imagePlus, size: 18),
        label: const Text('Lampirkan struk'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: _ReceiptPreview(file: receiptFile, path: savedPath),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Ganti'),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: Icon(
                LucideIcons.trash2,
                size: 16,
                color: theme.colorScheme.error,
              ),
              label: Text(
                'Hapus',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({this.file, this.path});

  final XFile? file;
  final String? path;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return FutureBuilder<Uint8List>(
        future: file!.readAsBytes(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Image.memory(
            snap.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(context),
          );
        },
      );
    }
    if (path != null && path!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          path!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(context),
        );
      }
      return Image.file(
        File(path!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(LucideIcons.receipt)),
    );
  }
}
