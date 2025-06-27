import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfScrollDetectionPage extends StatefulWidget {
  const PdfScrollDetectionPage({super.key});

  @override
  State<PdfScrollDetectionPage> createState() => _PdfScrollDetectionPageState();
}

class _PdfScrollDetectionPageState extends State<PdfScrollDetectionPage> {
  bool _isScrolledToEnd = false;
  DateTime? _scrolledToEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Scroll Detection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: _isScrolledToEnd ? Colors.green.shade100 : Colors.orange.shade100,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isScrolledToEnd ? Icons.check_circle : Icons.info,
                      color: _isScrolledToEnd ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isScrolledToEnd ? '最後までスクロールしました' : 'PDFを最後までスクロールしてください',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isScrolledToEnd ? Colors.green.shade800 : Colors.orange.shade800,
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
                return false;
              },
              child: PdfPreview(
                build: (format) => _generateSamplePdf(format),
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generateSamplePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    
    // 利用規約のサンプルPDFを生成
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Header(level: 0, text: '利用規約'),
          pw.Paragraph(text: '最終更新日: 2024年1月1日'),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: '第1条 総則'),
          pw.Paragraph(
            text: '本利用規約（以下「本規約」といいます。）は、当社が提供するサービス（以下「本サービス」といいます。）の利用条件を定めるものです。ユーザーの皆さま（以下「ユーザー」といいます。）には、本規約に従って本サービスをご利用いただきます。',
          ),
          pw.SizedBox(height: 10),
          pw.Header(level: 1, text: '第2条 利用登録'),
          pw.Paragraph(
            text: '登録希望者が当社の定める方法によって利用登録を申請し、当社がこれを承認することによって、利用登録が完了するものとします。',
          ),
          pw.SizedBox(height: 10),
          pw.Header(level: 1, text: '第3条 禁止事項'),
          pw.Paragraph(
            text: 'ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。',
          ),
          pw.Bullet(text: '法令または公序良俗に違反する行為'),
          pw.Bullet(text: '犯罪行為に関連する行為'),
          pw.Bullet(text: '当社のサーバーまたはネットワークの機能を破壊したり、妨害したりする行為'),
          pw.Bullet(text: '当社のサービスの運営を妨害するおそれのある行為'),
          pw.Bullet(text: '他のユーザーに関する個人情報等を収集または蓄積する行為'),
          pw.Bullet(text: '他のユーザーに成りすます行為'),
          pw.SizedBox(height: 10),
          // 長いコンテンツを追加してスクロールが必要になるようにする
          ...List.generate(20, (index) => pw.Column(
            children: [
              pw.Header(level: 1, text: '第${index + 4}条 追加条項${index + 1}'),
              pw.Paragraph(
                text: 'これは追加の条項です。スクロールが必要になるように十分な長さのコンテンツを生成しています。'
                    'ユーザーは本サービスを利用するにあたり、これらの条項すべてに同意する必要があります。'
                    '各条項は重要な内容を含んでいますので、必ず最後までお読みください。',
              ),
              pw.SizedBox(height: 10),
            ],
          )),
          pw.Header(level: 1, text: '最終条項'),
          pw.Paragraph(
            text: '本規約は日本法に準拠し、本サービスに関する一切の紛争については、東京地方裁判所を第一審の専属的合意管轄裁判所とします。',
          ),
          pw.SizedBox(height: 20),
          pw.Paragraph(
            text: '以上',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
    
    return pdf.save();
  }
}