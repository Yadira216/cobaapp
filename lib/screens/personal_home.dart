import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'escanear_qr_page.dart';

class PersonalHome extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PersonalHome({
    super.key,
    required this.usuario,
  });

  @override
  State<PersonalHome> createState() => _PersonalHomeState();
}

class _PersonalHomeState extends State<PersonalHome> {
  static const Color vino = Color(0xFF7B1735);
  static const Color verde = Color(0xFF55A630);
  static const Color fondo = Color(0xFFF7F7F9);
  static const Color texto = Color(0xFF29252A);
  static const Color gris = Color(0xFF85818A);

  Map<String, dynamic> get usuario => widget.usuario;

  String _texto(String campo) {
    final valor = usuario[campo];

    if (valor == null || valor.toString().trim().isEmpty) {
      return 'No disponible';
    }

    return valor.toString();
  }

  String get nombreCompleto {
    final nombre = _texto('nombre_completo');

    if (nombre != 'No disponible') {
      return nombre;
    }

    final partes = [
      usuario['nombre'],
      usuario['ape_pa'],
      usuario['ape_ma'],
    ]
        .where((parte) =>
            parte != null && parte.toString().trim().isNotEmpty)
        .map((parte) => parte.toString().trim())
        .toList();

    return partes.isEmpty ? 'Personal COBAEM' : partes.join(' ');
  }

  ImageProvider? _obtenerFoto() {
    final foto = usuario['foto'];

    if (foto == null) return null;

    final fotoTexto = foto.toString().trim();

    if (fotoTexto.isEmpty ||
        fotoTexto == 'null' ||
        fotoTexto == 'No disponible') {
      return null;
    }

    try {
      var base64Data = fotoTexto;

      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last;
      }

      return MemoryImage(base64Decode(base64Data));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foto = _obtenerFoto();

    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _encabezado(),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                 

                  const SizedBox(height: 0),


                  const SizedBox(height: 14),

                  _tarjetaEscaner(),

                  const SizedBox(height: 22),

                

                  const SizedBox(height: 1),

                  _tarjetaInformacion(
                    icono: Icons.badge_outlined,
                    titulo: 'Usuario',
                    valor: _texto('username'),
                    colorIcono: vino,
                  ),

                  _tarjetaInformacion(
                    icono: Icons.account_balance_outlined,
                    titulo: 'Plantel de adscripción',
                    valor: _texto('plantel'),
                    colorIcono: verde,
                  ),

                  _tarjetaInformacion(
                    icono: Icons.fingerprint_rounded,
                    titulo: 'CURP',
                    valor: _texto('curp'),
                    colorIcono: const Color(0xFF6B63B5),
                  ),

                  _tarjetaInformacion(
                    icono: Icons.assignment_ind_outlined,
                    titulo: 'RFC',
                    valor: _texto('rfc'),
                    colorIcono: const Color(0xFFCB8740),
                  ),

                  const SizedBox(height: 15),

                  _botonCerrarSesion(),

                  const SizedBox(height: 22),

                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'COBAapp',
                          style: TextStyle(
                            color: vino,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Colegio de Bachilleres del Estado de México',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: gris,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ENCABEZADO INSTITUCIONAL

 
Widget _encabezado() {
  final foto = _obtenerFoto();

  return Container(
    height: 190,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF68112D),
          vino,
          Color(0xFF922A49),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
    ),
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: -45,
          top: -65,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(23, 18, 23, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COBAapp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Personal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      backgroundImage: foto,
                      child: foto == null
                          ? const Icon(
                              Icons.person_rounded,
                              color: vino,
                              size: 38,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
  nombreCompleto,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.2,
  ),
),

const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // TITULOS DE SECCION

  Widget _tituloSeccion(String titulo, String subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: texto,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: const TextStyle(
            color: gris,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ACCESO AL ESCANER QR

  Widget _tarjetaEscaner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EscanearQrPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(23),
        child: Ink(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF74132F),
                vino,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(23),
            boxShadow: [
              BoxShadow(
                color: vino.withValues(alpha: 0.18),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear código QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Accede al lector de códigos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TARJETAS DE INFORMACION

  Widget _tarjetaInformacion({
    required IconData icono,
    required String titulo,
    required String valor,
    required Color colorIcono,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFEFECEF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorIcono.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icono,
              color: colorIcono,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: gris,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  valor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: texto,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CERRAR SESION

  Widget _botonCerrarSesion() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                icon: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: vino.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: vino,
                    size: 27,
                  ),
                ),
                title: const Text(
                  'Cerrar sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: texto,
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                content: const Text(
                  '¿Deseas salir de tu cuenta?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: gris,
                    fontSize: 14,
                  ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: gris,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: vino,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    
onPressed: () async {
  // Cerrar el cuadro de confirmación
  Navigator.of(dialogContext).pop();

  // Borrar la sesión guardada
  final preferencias = await SharedPreferences.getInstance();

  await preferencias.remove('sesion_activa');
  await preferencias.remove('tipo_usuario');
  await preferencias.remove('usuario_sesion');

  if (!context.mounted) return;

  // Regresar al menú principal de COBAapp
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const InicioPage(),
    ),
    (route) => false,
  );
},

                    child: const Text('Salir'),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: vino,
          side: BorderSide(
            color: vino.withValues(alpha: 0.25),
            width: 1.2,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

