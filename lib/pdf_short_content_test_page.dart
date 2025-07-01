import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfShortContentTestPage extends StatefulWidget {
  const PdfShortContentTestPage({super.key});

  @override
  State<PdfShortContentTestPage> createState() => _PdfShortContentTestPageState();
}

class _PdfShortContentTestPageState extends State<PdfShortContentTestPage> {
  bool _isScrolledToEnd = false;
  DateTime? _scrolledToEndTime;
  bool _hasScrollableContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('短いコンテンツでのテスト'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: _isScrolledToEnd 
                ? Colors.green.shade100 
                : (_hasScrollableContent ? Colors.orange.shade100 : Colors.blue.shade100),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isScrolledToEnd 
                          ? Icons.check_circle 
                          : (_hasScrollableContent ? Icons.info : Icons.warning),
                      color: _isScrolledToEnd 
                          ? Colors.green 
                          : (_hasScrollableContent ? Colors.orange : Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isScrolledToEnd 
                            ? '最後までスクロールしました'
                            : (_hasScrollableContent 
                                ? 'PDFを最後までスクロールしてください'
                                : 'スクロールできないコンテンツです'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isScrolledToEnd 
                              ? Colors.green.shade800 
                              : (_hasScrollableContent ? Colors.orange.shade800 : Colors.blue.shade800),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_scrolledToEndTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '完了時刻: ${_scrolledToEndTime!.hour}:${_scrolledToEndTime!.minute.toString().padLeft(2, '0')}:${_scrolledToEndTime!.second.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                debugPrint('ScrollNotification: ${notification.runtimeType}');
                debugPrint('Pixels: ${notification.metrics.pixels}');
                debugPrint('MaxScrollExtent: ${notification.metrics.maxScrollExtent}');
                debugPrint('ViewportDimension: ${notification.metrics.viewportDimension}');
                debugPrint('OutOfRange: ${notification.metrics.outOfRange}');
                
                // スクロール可能なコンテンツがあるかチェック
                if (notification.metrics.maxScrollExtent > 0) {
                  if (!_hasScrollableContent) {
                    setState(() {
                      _hasScrollableContent = true;
                    });
                  }
                  
                  // スクロール位置が末尾に達したか判定
                  if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 10 &&
                      !notification.metrics.outOfRange) {
                    if (!_isScrolledToEnd) {
                      setState(() {
                        _isScrolledToEnd = true;
                        _scrolledToEndTime = DateTime.now();
                      });
                      debugPrint("PDFの最後までスクロールしました！ 時刻: $_scrolledToEndTime");
                    }
                  }
                } else {
                  // スクロールできない場合は即座に完了とみなす
                  if (!_isScrolledToEnd) {
                    setState(() {
                      _isScrolledToEnd = true;
                      _scrolledToEndTime = DateTime.now();
                      _hasScrollableContent = false;
                    });
                    debugPrint("スクロール不要なコンテンツ - 自動的に完了: $_scrolledToEndTime");
                  }
                }
                return false;
              },
              child: PdfPreview(
                build: (format) => _generateShortPdf(format),
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isScrolledToEnd = false;
                  _scrolledToEndTime = null;
                  _hasScrollableContent = false;
                });
              },
              child: const Text('リセット'),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generateShortPdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    // 短いコンテンツのPDFを生成
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: '短い利用規約'),
            pw.Paragraph(text: '最終更新日: 2024年1月1日'),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: '第1条 総則'),
            pw.Paragraph(
              text: '本利用規約は、当社が提供するサービスの利用条件を定めるものです。',
            ),
            pw.SizedBox(height: 10),
            pw.Header(level: 1, text: '第2条 利用登録'),
            pw.Paragraph(
              text: '登録希望者が当社の定める方法によって利用登録を申請し、当社がこれを承認することによって、利用登録が完了するものとします。',
            ),
            pw.SizedBox(height: 10),
            pw.Header(level: 1, text: '第3条 禁止事項'),
            pw.Paragraph(
              text: 'ユーザーは、本サービスの利用にあたり、法令に違反する行為をしてはなりません。',
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(
              text: '以上',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    
    return pdf.save();
  }
}