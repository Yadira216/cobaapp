import 'package:flutter/material.dart';

class AlumnoHome extends StatelessWidget {
  final Map<String, dynamic> usuario;

  const AlumnoHome({
    super.key,
    required this.usuario,
  });

  static const Color vino = Color(0xFF7B1735);
  static const Color verde = Color(0xFF55A630);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppBar(
        backgroundColor: vino,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mi cuenta',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Encabezado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: vino,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      size: 35,
                      color: vino,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    usuario['matricula']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Datos del alumno',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _dato(
              icono: Icons.badge_outlined,
              titulo: 'Matrícula',
              valor: usuario['matricula']?.toString() ?? 'No disponible',
            ),

            _dato(
              icono: Icons.credit_card_outlined,
              titulo: 'CURP',
              valor: usuario['curp']?.toString() ?? 'No disponible',
            ),

            _dato(
              icono: Icons.lock_outline_rounded,
              titulo: 'Cambio de contraseña',
              valor: usuario['CambiarContrasena']?.toString() ?? 'No disponible',
            ),

            _dato(
              icono: Icons.check_circle_outline_rounded,
              titulo: 'Estado',
              valor: usuario['activo'] == 1 ? 'Activo' : 'Inactivo',
              colorValor: usuario['activo'] == 1 ? verde : Colors.red,
            ),

            const SizedBox(height: 20),

            // Opciones
            const Text(
              'Opciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _opcion(
                    icono: Icons.school_outlined,
                    texto: 'Historial académico',
                    onTap: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _opcion(
                    icono: Icons.description_outlined,
                    texto: 'Documentos',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato({
    required IconData icono,
    required String titulo,
    required String valor,
    Color? colorValor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: vino.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: vino,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: TextStyle(
                    color: colorValor ?? Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcion({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icono,
              color: vino,
              size: 30,
            ),

            Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

