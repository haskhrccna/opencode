import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

/// Service for generating and printing PDF reports
@singleton
class PdfService {
  /// Generate a PDF report from report data
  Future<Uint8List> generateReport({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<ReportSection> sections,
    List<ReportTable>? tables,
    List<ReportChart>? charts,
  }) async {
    final pdf = Document();

    // Add header with app branding
    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quran Tutor',
                        style: Theme.of(context)
                            .header0
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Report: $title',
                        style: Theme.of(context).header3,
                      ),
                    ],
                  ),
                  Text(
                    '${startDate.day}/${startDate.month}/${startDate.year} - '
                    '${endDate.day}/${endDate.month}/${endDate.year}',
                    style: Theme.of(context).defaultTextStyle,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),
              // Sections
              ...sections.map((section) => _buildSection(context, section)),
              // Tables
              if (tables != null) ...[
                SizedBox(height: 20),
                ...tables.map((table) => _buildTable(context, table)),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build a report section
  Widget _buildSection(Context context, ReportSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).header2.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 8),
        Text(section.content),
        SizedBox(height: 16),
      ],
    );
  }

  /// Build a data table
  Widget _buildTable(Context context, ReportTable table) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          table.title,
          style: Theme.of(context).header3,
        ),
        SizedBox(height: 8),
        TableHelper.fromTextArray(
          context: context,
          data: <List<String>>[
            table.headers,
            ...table.rows,
          ],
          headerStyle: Theme.of(context)
              .defaultTextStyle
              .copyWith(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(
            color: PdfColors.grey300,
          ),
          rowDecoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: PdfColors.grey300),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  /// Print the PDF
  Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  /// Share the PDF
  Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: fileName,
    );
  }

  /// Preview the PDF
  Future<void> previewPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }
}

/// Report section model
class ReportSection {
  final String title;
  final String content;

  ReportSection({
    required this.title,
    required this.content,
  });
}

/// Report table model
class ReportTable {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  ReportTable({
    required this.title,
    required this.headers,
    required this.rows,
  });
}

/// Report chart model
class ReportChart {
  final String title;
  final ChartType type;
  final Map<String, dynamic> data;

  ReportChart({
    required this.title,
    required this.type,
    required this.data,
  });
}

enum ChartType {
  bar,
  line,
  pie,
}
