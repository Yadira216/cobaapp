
import 'package:flutter/material.dart';
import 'planteles_service.dart';

class PruebaPlantelesPage extends StatefulWidget {
  const PruebaPlantelesPage({super.key});

  @override
  State<PruebaPlantelesPage> createState() =>
      _PruebaPlantelesPageState();
}

class _PruebaPlantelesPageState
    extends State<PruebaPlantelesPage> {

  String zona = 'valle_toluca';

  bool cargando = false;
  String resultado = 'Selecciona una zona para consultar.';
  List<dynamic> planteles = [];

  Future<void> consultar() async {
    setState(() {
      cargando = true;
      resultado = '';
      planteles = [];
    });

    try {
      final respuesta =
          await PlantelesService.obtenerPlanteles(zona);
          debugPrint('========== PLANTELES DE $zona ==========');

          for (final p in (respuesta['planteles'] as List)) {
            debugPrint(
              '${p['clave']} - ${p['plantel']}',
            );
          }

debugPrint('========================================');

      setState(() {
        planteles = respuesta['planteles'] ?? [];
        resultado =
            'Consulta correcta. Total: ${respuesta['total']}';
      });
    } catch (e) {
      setState(() {
        resultado = e.toString();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de planteles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: zona,
              decoration: const InputDecoration(
                labelText: 'Seleccionar zona',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'cemsad',
                  child: Text('CEMSAD'),
                ),
                DropdownMenuItem(
                  value: 'valle_mexico',
                  child: Text('Valle de México'),
                ),
                DropdownMenuItem(
                  value: 'valle_toluca',
                  child: Text('Valle de Toluca'),
                ),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    zona = valor;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: cargando ? null : consultar,
              child: const Text('Consultar planteles'),
            ),

            const SizedBox(height: 15),

            if (cargando)
              const CircularProgressIndicator(),

            Text(resultado),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: planteles.length,
                itemBuilder: (context, index) {
                  final p = planteles[index];

                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      p['plantel']?.toString() ?? '',
                    ),
                    subtitle: Text(
                    '${p['clave'] ?? ''} - ${p['municipio'] ?? ''}\n'
                    'craftx: ${p['craftx'] ?? 'Sin dato'} | '
                    'crafty: ${p['crafty'] ?? 'Sin dato'}\n'
                    'Latitud: ${p['latitud'] ?? 'Sin dato'} | '
                    'Longitud: ${p['longitud'] ?? 'Sin dato'}',
),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
