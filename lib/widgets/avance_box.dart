import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/styles.dart';
import '../theme/app_colors.dart';

class ProgresoDia extends StatelessWidget {
  const ProgresoDia({super.key});

  static const List<String> comidas = ['Desayuno', 'Comida', 'Cena'];

  String _fechaClave(DateTime fecha) {
    final year = fecha.year.toString();
    final month = fecha.month.toString().padLeft(2, '0');
    final day = fecha.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  EstadoComida _estadoComida(Box box, String comida) {
    final hoy = DateTime.now();
    final clave = '${_fechaClave(hoy)}|$comida';

    final datos = box.get(clave);

    if (datos == null || datos is! List || datos.isEmpty) {
      return EstadoComida.sinCompletar;
    }

    if (datos.length >= 11) {
      return EstadoComida.completo;
    }

    return EstadoComida.completo;
  }

  Color _colorEstado(EstadoComida estado) {
    switch (estado) {
      case EstadoComida.completo:
        return Colors.green;
      case EstadoComida.enProgreso:
        return Colors.amber;
      case EstadoComida.sinCompletar:
        return Colors.grey.shade300;
    }
  }

  IconData _iconoEstado(EstadoComida estado) {
    switch (estado) {
      case EstadoComida.completo:
        return Icons.check_circle;
      case EstadoComida.enProgreso:
        return Icons.radio_button_checked;
      case EstadoComida.sinCompletar:
        return Icons.circle_outlined;
    }
  }

  String _textoEstado(EstadoComida estado) {
    switch (estado) {
      case EstadoComida.completo:
        return 'Completo';
      case EstadoComida.enProgreso:
        return 'Progreso';
      case EstadoComida.sinCompletar:
        return 'Sin completar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconosComida = [
      Icons.free_breakfast,
      Icons.lunch_dining,
      Icons.dinner_dining,
    ];

    return ValueListenableBuilder(
      valueListenable: Hive.box('meal_reports').listenable(),
      builder: (context, Box box, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: AppColors.titulo2,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Progreso del Día',
                    style: AppTextStyles.titulo2,
                  ),
                ],
              ),

              const Divider(
                color: AppColors.titulo2,
                thickness: 1,
                indent: 5,
                endIndent: 5,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(comidas.length, (index) {
                  final comida = comidas[index];
                  final estado = _estadoComida(box, comida);
                  final color = _colorEstado(estado);

                  return Expanded(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                iconosComida[index],
                                color: estado == EstadoComida.sinCompletar
                                    ? Colors.black54
                                    : Colors.white,
                                size: 30,
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconoEstado(estado),
                                color: color,
                                size: 22,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          comida,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _textoEstado(estado),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: estado == EstadoComida.sinCompletar
                                ? Colors.grey.shade600
                                : color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum EstadoComida {
  sinCompletar,
  enProgreso,
  completo,
}