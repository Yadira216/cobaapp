
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrientacionNotificaciones {
  static const String _url =
      'http://10.35.16.16/saesc/android/android.php';

  static const String _canalId = 'orientacion_novedades';

  static final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;

  /// Inicializa las notificaciones locales.
  ///
  /// solicitarPermiso: solicita permisos cuando la app está
  /// en primer plano. En segundo plano no solicita permisos.
  static Future<void> inicializar({
    bool solicitarPermiso = true,
  }) async {
    if (!_inicializado) {
      const ajustes = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _notificaciones.initialize(
        settings: ajustes,
      );

      _inicializado = true;
    }

    if (!solicitarPermiso) return;

    // Permisos para Android.
    final android = _notificaciones
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();

    // Permisos para iOS.
    final ios = _notificaciones
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Consulta las actividades de Orientación del alumno.
  ///
  /// enSegundoPlano: true cuando Workmanager ejecuta la revisión.
  static Future<void> revisar(
    int idAlumno, {
    bool enSegundoPlano = false,
  }) async {
    if (idAlumno <= 0) {
      debugPrint('Orientación: idAlumno no válido.');
      return;
    }

    await inicializar(
      solicitarPermiso: !enSegundoPlano,
    );

    final respuesta = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'accion': 'orientacion',
            'id_alumno': idAlumno,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (respuesta.statusCode != 200) {
      throw Exception(
        'No fue posible consultar Orientación. '
        'Código HTTP: ${respuesta.statusCode}',
      );
    }

    final dynamic resultado = jsonDecode(
      utf8.decode(respuesta.bodyBytes),
    );

    if (resultado is! Map ||
        resultado['status'] != 'success' ||
        resultado['datos'] is! List) {
      throw Exception(
        'La respuesta de Orientación no tiene el formato esperado.',
      );
    }

    final List registros = resultado['datos'] as List;

    // Obtiene los identificadores de las actividades actuales.
    final Set<String> idsActuales = registros
        .whereType<Map>()
        .map(
          (registro) =>
              registro['id_prefec']?.toString() ?? '',
        )
        .where(
          (id) => id.isNotEmpty && id != '0',
        )
        .toSet();

    final preferencias = await SharedPreferences.getInstance();

    // Cada alumno conserva sus propios identificadores.
    final String clave = 'orientacion_ids_$idAlumno';

    final List<String>? guardados =
        preferencias.getStringList(clave);

    // Primera revisión: guarda lo existente sin notificar.
    if (guardados == null) {
      await preferencias.setStringList(
        clave,
        idsActuales.toList(),
      );

      debugPrint(
        'Orientación: se guardaron los registros iniciales.',
      );
      return;
    }

    final Set<String> idsAnteriores = guardados.toSet();

    // Identifica las actividades que no estaban antes.
    final Set<String> nuevos =
        idsActuales.difference(idsAnteriores);

    if (nuevos.isEmpty) {
      debugPrint('Orientación: no hay registros nuevos.');
      return;
    }

    final int cantidad = nuevos.length;

    final String titulo = 'Novedad en Orientación';

    final String mensaje = cantidad == 1
        ? 'Tienes una nueva actividad en Orientación.'
        : 'Tienes $cantidad nuevas actividades en Orientación.';

    final int idNotificacion = DateTime.now()
        .millisecondsSinceEpoch
        .remainder(2147483647);

    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        _canalId,
        'Novedades de Orientación',
        channelDescription:
            'Avisos de nuevas actividades en Orientación.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificaciones.show(
      id: idNotificacion,
      title: titulo,
      body: mensaje,
      notificationDetails: detalles,
    );

    // Guarda los identificadores después de mostrar el aviso.
    await preferencias.setStringList(
      clave,
      {...idsAnteriores, ...idsActuales}.toList(),
    );

    debugPrint(
      'Orientación: notificación mostrada. '
      'Registros nuevos: $cantidad',
    );
  }
}
