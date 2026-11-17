import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantelesService {
  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  static Future<Map<String, dynamic>> obtenerPlanteles(
    String zona,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accion': 'obtener_planteles',
          'zona': zona,
        }),
      );

      final datos = jsonDecode(response.body);

      if (datos is! Map) {
        throw Exception('La respuesta del servidor no es válida.');
      }

      final resultado = Map<String, dynamic>.from(datos);

      if (response.statusCode != 200 ||
          resultado['status'] != 'success') {
        throw Exception(
          resultado['mensaje'] ??
          'No fue posible obtener los planteles.',
        );
      }

      return resultado;
    } catch (e) {
      throw Exception('Error al consultar los planteles: $e');
    }
  }
}
