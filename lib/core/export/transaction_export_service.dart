import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../data/models/models.dart';
import '../utils/currency_format.dart';

/// Builds CSV / PDF exports and opens the system share sheet.
class TransactionExportService {
  TransactionExportService({
    DateFormat? dateFormat,
  }) : _dateFormat = dateFormat ?? DateFormat('yyyy-MM-dd HH:mm');

  final DateFormat _dateFormat;

  Future<void> shareCsv({
    required List<Transaction> transactions,
    required Map<int, Account> accountsById,
    required Map<int, Category> categoriesById,
  }) async {
    final csv = buildCsv(
      transactions: transactions,
      accountsById: accountsById,
      categoriesById: categoriesById,
    );
    final bytes = utf8.encode('\uFEFF$csv');
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'text/csv',
          name: _fileName('csv'),
        ),
      ],
      subject: 'SakuKu — log transaksi',
      text: 'Export transaksi SakuKu',
    );
  }

  Future<void> sharePdf({
    required List<Transaction> transactions,
    required Map<int, Account> accountsById,
    required Map<int, Category> categoriesById,
  }) async {
    final doc = pw.Document();
    final generated = _dateFormat.format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SakuKu — Log Transaksi',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Diekspor: $generated · ${transactions.length} baris',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) {
          if (transactions.isEmpty) {
            return [
              pw.Text('Tidak ada transaksi untuk diekspor.'),
            ];
          }
          return [
            pw.TableHelper.fromTextArray(
              headers: const [
                'Tanggal',
                'Tipe',
                'Jumlah',
                'Akun',
                'Kategori',
                'Catatan',
                'Tag',
              ],
              data: [
                for (final tx in transactions)
                  [
                    _dateFormat.format(tx.date),
                    _typeLabel(tx.type),
                    CurrencyFormat.idr(tx.amount),
                    _accountLabel(tx, accountsById),
                    _categoryLabel(tx, categoriesById),
                    tx.note ?? '',
                    tx.tags.join('; '),
                  ],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          mimeType: 'application/pdf',
          name: _fileName('pdf'),
        ),
      ],
      subject: 'SakuKu — log transaksi',
    );
  }

  String buildCsv({
    required List<Transaction> transactions,
    required Map<int, Account> accountsById,
    required Map<int, Category> categoriesById,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Tanggal,Tipe,Jumlah,Akun,Kategori,Catatan,Tag',
    );
    for (final tx in transactions) {
      buffer.writeln([
        _escape(_dateFormat.format(tx.date)),
        _escape(_typeLabel(tx.type)),
        tx.amount.toStringAsFixed(0),
        _escape(_accountLabel(tx, accountsById)),
        _escape(_categoryLabel(tx, categoriesById)),
        _escape(tx.note ?? ''),
        _escape(tx.tags.join('; ')),
      ].join(','));
    }
    return buffer.toString();
  }

  String _fileName(String ext) {
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return 'sakuku_transaksi_$stamp.$ext';
  }

  String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Masuk';
      case TransactionType.expense:
        return 'Keluar';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String _accountLabel(Transaction tx, Map<int, Account> accountsById) {
    final from = accountsById[tx.accountId]?.name ?? 'Akun #${tx.accountId}';
    if (tx.type == TransactionType.transfer && tx.targetAccountId != null) {
      final to = accountsById[tx.targetAccountId!]?.name ??
          'Akun #${tx.targetAccountId}';
      return '$from → $to';
    }
    return from;
  }

  String _categoryLabel(Transaction tx, Map<int, Category> categoriesById) {
    if (tx.categoryId == null) return '';
    return categoriesById[tx.categoryId!]?.name ?? '#${tx.categoryId}';
  }
}
