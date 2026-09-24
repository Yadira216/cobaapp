import 'alumno_home.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final String tipoUsuario;

  const LoginPage({
    super.key,
    required this.tipoUsuario,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color vino = Color(0xFF7B1735);

  final matriculaCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;
  String? mensajeError;

  // URL correcta del servicio PHP
  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  Future<void> _iniciarSesion() async {
    setState(() {
      cargando = true;
      mensajeError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'accion': 'login',
          'matricula': matriculaCtrl.text.trim(),
          'password': passwordCtrl.text,
        }),
      );

      final datos = jsonDecode(response.body);

      if (datos['status'] == 'success') {
  final usuario = datos['usuario'];

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AlumnoHome(
          usuario: Map<String, dynamic>.from(usuario),
        ),
      ),
    );
  }
}
      else if (datos['status'] == 'credenciales_invalidas') {
        setState(() {
          mensajeError = 'Matrícula o contraseña incorrecta';
        });
      } else if (datos['status'] == 'cuenta_inactiva') {
        setState(() {
          mensajeError = 'Tu cuenta no está activa';
        });
      } else {
        setState(() {
          mensajeError =
              'Error: ${datos['message'] ?? 'desconocido'}';
        });
      }
    } catch (e) {
      setState(() {
        mensajeError = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: vino,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Icon(
              widget.tipoUsuario == 'Estudiante'
                  ? Icons.school_rounded
                  : Icons.badge_rounded,
              color: vino,
              size: 48,
            ),

            const SizedBox(height: 16),

            Text(
              'Acceso ${widget.tipoUsuario}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ingresa tus credenciales para continuar',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: matriculaCtrl,
              decoration: InputDecoration(
                labelText: 'Número de cuenta',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordCtrl,
              obscureText: ocultarPassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    ocultarPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarPassword = !ocultarPassword;
                    });
                  },
                ),
              ),
            ),

            if (mensajeError != null) ...[
              const SizedBox(height: 12),
              Text(
                mensajeError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: vino,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: cargando ? null : _iniciarSesion,
                child: cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

