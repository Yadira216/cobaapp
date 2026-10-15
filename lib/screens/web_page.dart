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

static const String _facebookUrl =
'https://www.facebook.com/COBA.EDOMEX/';

@override
void initState() {
super.initState();

if (!kIsWeb) {
  controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (!mounted) return;

          setState(() {
            cargando = true;
          });
        },

        onPageFinished: (_) async {
          if (!mounted) return;

          setState(() {
            cargando = false;
          });

          try {
            await controller?.runJavaScript('''
              document.querySelectorAll('a[target="_blank"]')
                .forEach(function(link) {
                  link.setAttribute('target', '_self');
                });
            ''');
          } catch (_) {
            // Algunas páginas bloquean la ejecución de JavaScript.
          }
        },

        onNavigationRequest: (NavigationRequest request) async {
          final Uri? uri = Uri.tryParse(request.url);

          if (uri == null) {
            return NavigationDecision.prevent;
          }

          // Las páginas web normales permanecen dentro de COBAapp.
          if (uri.scheme == 'http' || uri.scheme == 'https') {
            return NavigationDecision.navigate;
          }

          // Facebook puede redirigir a una dirección fb://.
          // Intentamos abrirla fuera del WebView.
          if (uri.scheme == 'fb' || uri.scheme == 'intent') {
            try {
              final bool abierto = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );

              // Si no se pudo abrir Facebook, usamos su página web.
              if (!abierto) {
                await launchUrl(
                  Uri.parse(_facebookUrl),
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (_) {
              try {
                await launchUrl(
                  Uri.parse(_facebookUrl),
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {
                // Evitamos que la redirección cierre la aplicación.
              }
            }

            return NavigationDecision.prevent;
          }

          // No intentamos cargar esquemas desconocidos como páginas web.
          return NavigationDecision.prevent;
        },
      ),
    )
    ..loadRequest(Uri.parse(widget.url));
} else {
  // En Flutter Web se abre la dirección en otra pestaña.
  launchUrl(
    Uri.parse(widget.url),
    webOnlyWindowName: '_blank',
  );
}


}

@override
Widget build(BuildContext context) {
// Flutter Web.
if (kIsWeb) {
return Scaffold(
appBar: AppBar(
title: Text(widget.titulo),
),
body: const Center(
child: Text('Se abrió en una nueva pestaña'),
),
);
}


// Android / iOS.
return Scaffold(
  appBar: AppBar(
    title: Text(widget.titulo),
    backgroundColor: const Color(0xFF7B1735),
    foregroundColor: Colors.white,
  ),
  body: Stack(
    children: [
      if (controller != null)
        WebViewWidget(controller: controller!),

      if (cargando)
        const Center(
          child: CircularProgressIndicator(),
        ),
    ],
  ),
);

}
}
