import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfScrollIssueDemoPage extends StatefulWidget {
  const PdfScrollIssueDemoPage({super.key});

  @override
  State<PdfScrollIssueDemoPage> createState() => _PdfScrollIssueDemoPageState();
}

class _PdfScrollIssueDemoPageState extends State<PdfScrollIssueDemoPage> {
  bool _isScrolledToEnd = false;
  String _scrollStatus = '初期状態';
  final List<String> _scrollLog = [];
  bool _usePageMode = false;

  void _addLog(String message) {
    setState(() {
      _scrollLog.add(
        '${DateTime.now().toString().substring(11, 19)}: $message',
      );
      if (_scrollLog.length > 10) {
        _scrollLog.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PdfPreview スクロール問題デモ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PdfPreviewのスクロール検知の問題点：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. ページモードではスクロールイベントが発生しない'),
                const Text('2. 初期レンダリング中はmaxScrollExtentが不正確'),
                const Text('3. ズーム時にスクロール位置がリセットされる'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('ページモード: '),
                    Switch(
                      value: _usePageMode,
                      onChanged: (value) {
                        setState(() {
                          _usePageMode = value;
                          _isScrolledToEnd = false;
                          _scrollLog.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: _isScrolledToEnd
                ? Colors.green.shade100
                : Colors.orange.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isScrolledToEnd ? Icons.check_circle : Icons.info,
                      color: _isScrolledToEnd ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scrollStatus,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.all(8.0),
            color: Colors.black87,
            child: ListView.builder(
              itemCount: _scrollLog.length,
              itemBuilder: (context, index) {
                return Text(
                  _scrollLog[index],
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final type = notification.runtimeType.toString();
                final pixels = notification.metrics.pixels.toStringAsFixed(1);
                final max = notification.metrics.maxScrollExtent
                    .toStringAsFixed(1);

                _addLog('$type: pos=$pixels, max=$max');

                // スクロール可能かチェック
                if (notification.metrics.maxScrollExtent > 0) {
                  setState(() {
                    _scrollStatus = 'スクロール可能 (max: $max)';
                  });

                  // スクロール位置が末尾に達したか判定
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 10 &&
                      !notification.metrics.outOfRange) {
                    if (!_isScrolledToEnd) {
                      setState(() {
                        _isScrolledToEnd = true;
                        _scrollStatus = '最後までスクロールしました！';
                      });
                      _addLog('>>> スクロール完了検知！');
                    }
                  }
                } else {
                  setState(() {
                    _scrollStatus = 'スクロール不可 (max: 0)';
                  });
                }

                return false;
              },
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                useActions: false,
                scrollViewDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
                pdfPreviewPageDecoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // ページモードの切り替え
                pageFormats: _usePageMode
                    ? const <String, PdfPageFormat>{
                        'Page Mode': PdfPageFormat.a4,
                      }
                    : const <String, PdfPageFormat>{},
                onPageFormatChanged: (format) {
                  _addLog('ページフォーマット変更: ${format.width}x${format.height}');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // 複数ページのPDFを生成
    for (int page = 0; page < 3; page++) {
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'ページ ${page + 1}/3 - スクロール検知テスト'),
              pw.SizedBox(height: 20),
              ...List.generate(
                15,
                (index) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Header(level: 1, text: '第${page * 15 + index + 1}条'),
                    pw.Paragraph(
                      text:
                          'これはテスト用の長い文章です。PdfPreviewウィジェットのスクロール検知の動作を確認するために、'
                          '十分な長さのコンテンツを生成しています。ページ${page + 1}の第${index + 1}項目です。'
                          'スクロールイベントが正しく発生するか、maxScrollExtentが正しく計算されるかを確認してください。',
                    ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),
              if (page == 2)
                pw.Column(
                  children: [
                    pw.SizedBox(height: 30),
                    pw.Paragraph(
                      text: '--- 文書の終わり ---',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
