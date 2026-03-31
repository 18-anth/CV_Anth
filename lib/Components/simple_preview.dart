import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SimplePreview extends StatefulWidget {
  final String link;

  const SimplePreview({super.key, required this.link});

  @override
  State<SimplePreview> createState() => _SimplePreviewState();
}

class _SimplePreviewState extends State<SimplePreview> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.link));
    }
  }

  Future<void> _openLink() async {
    final Uri url = Uri.parse(widget.link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = Container(
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCCCCCC),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildContent(),
    );

    return container;
  }

  Widget _buildContent() {
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.open_in_new,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Vista previa no disponible en web',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _openLink,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir Proyecto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF050A30),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(
          controller: _webViewController,
        ),
      );
    }
  }
}
