import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewFlutterScrollDetectionPage extends StatefulWidget {
  const WebViewFlutterScrollDetectionPage({super.key});

  @override
  State<WebViewFlutterScrollDetectionPage> createState() => _WebViewFlutterScrollDetectionPageState();
}

class _WebViewFlutterScrollDetectionPageState extends State<WebViewFlutterScrollDetectionPage> {
  late WebViewController _webViewController;
  bool _isScrolledToEnd = false;
  DateTime? _scrolledToEndTime;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final data = message.message.split(':');
          if (data.length == 2) {
            final type = data[0];
            final value = double.tryParse(data[1]) ?? 0.0;
            
            if (type == 'progress') {
              setState(() {
                _scrollProgress = value;
              });
            } else if (type == 'bottom' && value == 1.0) {
              if (!_isScrolledToEnd) {
                setState(() {
                  _isScrolledToEnd = true;
                  _scrolledToEndTime = DateTime.now();
                });
                debugPrint("WebViewの最後までスクロールしました！ 時刻: $_scrolledToEndTime");
              }
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // ページ読み込み完了後にJavaScriptを注入
            _webViewController.runJavaScript(_scrollDetectionJS);
          },
        ),
      )
      ..loadRequest(Uri.dataFromString(
        _generateSampleHTML(),
        mimeType: 'text/html',
        encoding: utf8,
      ));
  }

  // JavaScriptでスクロール位置を監視するコード
  final String _scrollDetectionJS = '''
    (function() {
      var checkScroll = function() {
        var scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        var scrollHeight = document.documentElement.scrollHeight;
        var clientHeight = window.innerHeight;
        var scrollProgress = (scrollTop + clientHeight) / scrollHeight * 100;
        
        // スクロール進捗を送信
        FlutterChannel.postMessage('progress:' + scrollProgress);
        
        // 最下部に到達したかチェック（95%以上を最下部とみなす）
        if (scrollProgress >= 95) {
          FlutterChannel.postMessage('bottom:1');
        }
      };
      
      // スクロールイベントにリスナーを追加
      window.addEventListener('scroll', checkScroll);
      // 初回チェック
      checkScroll();
    })();
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Flutter Scroll Detection'),
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
                      _isScrolledToEnd ? '最後までスクロールしました' : 'ページを最後までスクロールしてください',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isScrolledToEnd ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _scrollProgress / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isScrolledToEnd ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'スクロール進捗: ${_scrollProgress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
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
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }

  String _generateSampleHTML() {
    // 追加条項を生成
    String additionalSections = '';
    for (int i = 0; i < 20; i++) {
      additionalSections += '''
    <h2>第${i + 4}条 追加条項${i + 1}</h2>
    <p>これは追加の条項です。スクロールが必要になるように十分な長さのコンテンツを生成しています。ユーザーは本サービスを利用するにあたり、これらの条項すべてに同意する必要があります。各条項は重要な内容を含んでいますので、必ず最後までお読みください。</p>
    <p>本条項では、サービスの利用に関する詳細な規定を定めています。ユーザーは、これらの規定を遵守し、適切にサービスを利用するものとします。違反が発覚した場合、当社は適切な措置を講じる権利を有します。</p>
    ''';
    }

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>利用規約</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      margin: 0;
      padding: 20px;
      line-height: 1.6;
      color: #333;
      background-color: #f5f5f5;
    }
    .container {
      max-width: 800px;
      margin: 0 auto;
      background-color: white;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    h1 {
      color: #2c3e50;
      border-bottom: 2px solid #3498db;
      padding-bottom: 10px;
    }
    h2 {
      color: #34495e;
      margin-top: 30px;
    }
    .date {
      color: #7f8c8d;
      font-style: italic;
    }
    ul {
      padding-left: 30px;
    }
    li {
      margin-bottom: 8px;
    }
    .footer {
      margin-top: 50px;
      text-align: center;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>利用規約</h1>
    <p class="date">最終更新日: 2024年1月1日</p>
    
    <h2>第1条 総則</h2>
    <p>本利用規約（以下「本規約」といいます。）は、当社が提供するサービス（以下「本サービス」といいます。）の利用条件を定めるものです。ユーザーの皆さま（以下「ユーザー」といいます。）には、本規約に従って本サービスをご利用いただきます。</p>
    
    <h2>第2条 利用登録</h2>
    <p>登録希望者が当社の定める方法によって利用登録を申請し、当社がこれを承認することによって、利用登録が完了するものとします。</p>
    
    <h2>第3条 禁止事項</h2>
    <p>ユーザーは、本サービスの利用にあたり、以下の行為をしてはなりません。</p>
    <ul>
      <li>法令または公序良俗に違反する行為</li>
      <li>犯罪行為に関連する行為</li>
      <li>当社のサーバーまたはネットワークの機能を破壊したり、妨害したりする行為</li>
      <li>当社のサービスの運営を妨害するおそれのある行為</li>
      <li>他のユーザーに関する個人情報等を収集または蓄積する行為</li>
      <li>他のユーザーに成りすます行為</li>
    </ul>
    
    $additionalSections
    
    <h2>最終条項</h2>
    <p>本規約は日本法に準拠し、本サービスに関する一切の紛争については、東京地方裁判所を第一審の専属的合意管轄裁判所とします。</p>
    
    <div class="footer">
      <p>以上</p>
    </div>
  </div>
</body>
</html>
    ''';
  }
}