import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPage extends StatefulWidget {
  final String titulo;
  final String url;

  const WebPage({
    super.key,
    required this.titulo,
    required this.url,
  });

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  WebViewController? controller;
  bool cargando = true;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)

        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              setState(() {
                cargando = true;
              });
            },

            onPageFinished: (_) async {
              setState(() {
                cargando = false;
              });

              // Hacemos que los enlaces que intentan abrir
              // una ventana nueva se queden dentro del WebView.
              await controller?.runJavaScript('''
                document.querySelectorAll('a[target="_blank"]').forEach(function(link) {
                  link.setAttribute('target', '_self');
                });
              ''');
            },

            onNavigationRequest: (NavigationRequest request) {
              // Todos los enlaces permanecen dentro de COBAapp.
              return NavigationDecision.navigate;
            },
          ),
        )

        ..loadRequest(
          Uri.parse(widget.url),
        );
    } else {
      // En Flutter Web se abre en una nueva pestaña.
      launchUrl(
        Uri.parse(widget.url),
        webOnlyWindowName: '_blank',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Flutter Web
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
        ),
        body: const Center(
          child: Text(
            'Se abrió en una nueva pestaña',
          ),
        ),
      );
    }

    // Android / iOS
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFF7B1735),
        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          WebViewWidget(
            controller: controller!,
          ),

          if (cargando)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}