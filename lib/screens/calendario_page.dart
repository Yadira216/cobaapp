import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../globales.dart' as globales;

class CalendarioPage extends StatelessWidget {
  const CalendarioPage({super.key});

  static const Color vino = Color(0xFF7B1735);
  static const Color fondo = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
  backgroundColor: vino,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text('Calendario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
  centerTitle: true,
),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _WebViewSeccion(
              url: '${globales.urlApi}/android/calendario.html',
              altura: 820,
            ),
            const SizedBox(height: 4),
            _WebViewSeccion(
              url: '${globales.urlApi}/android/base_calendario.html',
              altura: 200,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebViewSeccion extends StatefulWidget {
  final String url;
  final double altura;

  const _WebViewSeccion({required this.url, required this.altura});

  @override
  State<_WebViewSeccion> createState() => _WebViewSeccionState();
}

class _WebViewSeccionState extends State<_WebViewSeccion> {
  late final WebViewController controller;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => cargando = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.altura,
      child: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (cargando) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}