
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'alumno_home.dart';
import 'personal_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color vino = Color(0xFF7B1735);

  final usuarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool ocultarPassword = true;
  bool cargando = false;
  String? mensajeError;

  static const String endpoint =
      'http://10.35.16.16/saesc/android/android.php';

  // GUARDAR LA SESIÓN DEL USUARIO
  Future<void> _guardarSesion(
    String tipo,
    Map<String, dynamic> usuario,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('sesion_activa', true);
    await prefs.setString('tipo_usuario', tipo);
    await prefs.setString(
      'usuario_sesion',
      jsonEncode(usuario),
    );
  }

  // INICIAR SESIÓN
  Future<void> _iniciarSesion() async {
    final usuario = usuarioCtrl.text.trim();
    final password = passwordCtrl.text;

    if (usuario.isEmpty || password.isEmpty) {
      setState(() {
        mensajeError =
            'Por favor ingresa tu usuario y contraseña.';
      });
      return;
    }

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
          'usuario': usuario,
          'password': password,
        }),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          mensajeError =
              'No fue posible comunicarse con el servidor.';
        });
        return;
      }

      final datos = jsonDecode(response.body);

      // LOGIN CORRECTO
      if (datos['status'] == 'success') {
        final tipo = datos['tipo'];
        final usuarioDatos = datos['usuario'];

        if (usuarioDatos == null || usuarioDatos is! Map) {
          setState(() {
            mensajeError =
                'El servidor no devolvió los datos del usuario.';
          });
          return;
        }

        final Map<String, dynamic> usuarioMap =
            Map<String, dynamic>.from(usuarioDatos);

        // ALUMNO
        if (tipo == 'alumno') {
          await _guardarSesion('alumno', usuarioMap);

          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => AlumnoHome(
                usuario: usuarioMap,
              ),
            ),
            (route) => false,
          );

          return;
        }

        // PERSONAL
        if (tipo == 'personal') {
          await _guardarSesion('personal', usuarioMap);

          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => PersonalHome(
                usuario: usuarioMap,
              ),
            ),
            (route) => false,
          );

          return;
        }

        setState(() {
          mensajeError = 'Tipo de usuario no reconocido.';
        });
        return;
      }

      // CUENTA INACTIVA
      if (datos['status'] == 'cuenta_inactiva') {
        setState(() {
          mensajeError = 'Tu cuenta no está activa.';
        });
        return;
      }

      // CREDENCIALES INCORRECTAS
      if (datos['status'] == 'credenciales_invalidas') {
        setState(() {
          mensajeError = 'Usuario o contraseña incorrectos.';
        });
        return;
      }

      // OTROS ERRORES DEL SERVIDOR
      setState(() {
        mensajeError =
            datos['mensaje'] ??
            datos['message'] ??
            'Ocurrió un error al iniciar sesión.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensajeError =
            'No fue posible conectarse con el servidor.';
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGOS INSTITUCIONALES
              Row(
                children: [
                  Image.asset(
                    'assets/logoedu.png',
                    height: 48,
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/cobalogo.png',
                    height: 40,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Icon(
                Icons.lock_person_rounded,
                color: vino,
                size: 52,
              ),

              const SizedBox(height: 18),

              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Ingresa tus datos para continuar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 34),

              // USUARIO 
              TextField(
                controller: usuarioCtrl,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Número de cuenta o username',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CONTRASEÑA
              TextField(
                controller: passwordCtrl,
                obscureText: ocultarPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!cargando) {
                    _iniciarSesion();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                  ),
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

              // MENSAJE DE ERROR
              if (mensajeError != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mensajeError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // BOTÓN INGRESAR
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vino,
                    disabledBackgroundColor:
                        vino.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: cargando ? null : _iniciarSesion,
                  child: cargando
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ingresar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
