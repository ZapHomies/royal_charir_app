import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sales_report_model.dart';
import '../data/repositories/report_repository.dart';

/// Report Repository Provider
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

/// Sales Report Provider
final salesReportProvider = FutureProvider.family<SalesReportModel, DateRange>(
  (ref, dateRange) async {
    final repository = ref.read(reportRepositoryProvider);
    return await repository.getSalesReport(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  },
);

/// Stock Report Provider
final stockReportProvider = FutureProvider<StockReportModel>((ref) async {
  final repository = ref.read(reportRepositoryProvider);
  return await repository.getStockReport();
});

/// Date Range for Reports
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
