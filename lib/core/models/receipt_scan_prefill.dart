/// Parsed receipt data for auto-filling [AddTransactionBottomSheet].
class ReceiptScanPrefill {
  const ReceiptScanPrefill({
    this.amount,
    this.date,
    this.suggestedCategoryName,
    this.merchantHint,
    this.rawText,
  });

  final double? amount;
  final DateTime? date;
  final String? suggestedCategoryName;
  final String? merchantHint;
  final String? rawText;

  bool get hasData =>
      amount != null ||
      date != null ||
      (suggestedCategoryName != null && suggestedCategoryName!.isNotEmpty);
}
