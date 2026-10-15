
import 'package:workmanager/workmanager.dart';

import 'orientacion_notificaciones.dart';

const String tareaOrientacion = 'revisarOrientacion';

const String nombreUnicoTarea =
    'com.example.cobaapp.orientacion';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != tareaOrientacion) {
      return true;
    }

    final int idAlumno = int.tryParse(
          inputData?['id_alumno']?.toString() ?? '',
        ) ??
        0;

    if (idAlumno <= 0) {
      return true;
    }

    try {
      await OrientacionNotificaciones.revisar(
        idAlumno,
        enSegundoPlano: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  });
}

class OrientacionTareasFondo {
  static Future<void> programar(int idAlumno) async {
    if (idAlumno <= 0) return;

    await Workmanager().registerPeriodicTask(
      nombreUnicoTarea,
      tareaOrientacion,
      frequency: const Duration(minutes: 15),
      inputData: {
        'id_alumno': idAlumno,
      },
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  static Future<void> cancelar() async {
    await Workmanager().cancelByUniqueName(
      nombreUnicoTarea,
    );
  }
}
