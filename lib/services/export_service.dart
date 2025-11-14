import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';

class ExportService {
  /// Export transactions to CSV
  static Future<String> exportToCSV(
    List<Transaction> transactions,
    String fileName,
  ) async {
    try {
      final List<List<dynamic>> rows = [
        ['Date', 'Description', 'Category', 'Type', 'Amount', 'Account']
      ];

      for (var transaction in transactions) {
        rows.add([
          transaction.date.toString().split(' ')[0],
          transaction.description,
          transaction.category,
          transaction.type.toString().split('.').last.toUpperCase(),
          transaction.amount.toStringAsFixed(2),
          transaction.accountId,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName.csv';
      final file = File(path);

      await file.writeAsString(csv);
      print('✓ CSV exported to: $path');
      return path;
    } catch (e) {
      print('✗ Error exporting to CSV: $e');
      rethrow;
    }
  }

  /// Export transactions to PDF
  static Future<String> exportToPDF(
    List<Transaction> transactions,
    String fileName,
    String month,
  ) async {
    try {
      final pdf = pw.Document();

      final totalIncome = transactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Build table rows
      final List<pw.TableRow> rows = [
        pw.TableRow(
          children: [
            pw.Text('Date',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Description',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Category',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Type',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Amount',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ],
        )
      ];

      for (var transaction in transactions) {
        rows.add(
          pw.TableRow(
            children: [
              pw.Text(
                transaction.date.toString().split(' ')[0],
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                transaction.description,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                transaction.category,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                transaction.type.toString().split('.').last.toUpperCase(),
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '₱${transaction.amount.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        );
      }

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'WalletWise - Monthly Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Month: $month',
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Income',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('₱${totalIncome.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Expense',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('₱${totalExpense.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Net Savings',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(
                            '₱${(totalIncome - totalExpense).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Transaction Details',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: rows,
                ),
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$fileName.pdf';
      final file = File(path);

      await file.writeAsBytes(await pdf.save());
      print('✓ PDF exported to: $path');
      return path;
    } catch (e) {
      print('✗ Error exporting to PDF: $e');
      rethrow;
    }
  }
}
