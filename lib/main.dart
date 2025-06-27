import 'package:flutter/material.dart';
import 'package:scroll_event/pdf_scroll_detection_page.dart';
import 'package:scroll_event/inappwebview_scroll_detection_page.dart';
import 'package:scroll_event/webview_flutter_scroll_detection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Detection Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スクロール検知デモ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'スクロール検知の実装方法比較',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '各パッケージでのスクロール検知実装を確認できます。',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildMenuCard(
              context,
              title: 'PDF Preview (printing)',
              description: 'printing パッケージのPdfPreviewウィジェットでのスクロール検知',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PdfScrollDetectionPage(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'flutter_inappwebview',
              description: 'flutter_inappwebview パッケージでのスクロール検知',
              icon: Icons.web,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InAppWebViewScrollDetectionPage(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'webview_flutter',
              description: 'webview_flutter パッケージでのスクロール検知',
              icon: Icons.web_outlined,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebViewFlutterScrollDetectionPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}