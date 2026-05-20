import 'package:flutter/material.dart';
import '../utils/styles.dart';
import '../theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/custom_navbar.dart';
import '../widgets/top_bar.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {

  final TextEditingController expedienteController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController tutorController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    var box = Hive.box('settings');
    var user = box.get('user');

    if (user != null) {
      expedienteController.text = user['expediente'] ?? '';
      nombreController.text = user['nombre'] ?? '';
      tutorController.text = user['tutor'] ?? '';
      correoController.text = user['correo'] ?? '';
      telefonoController.text = user['telefono'] ?? '';
    }
  }

  Future<void> guardarDatos() async {
    var box = Hive.box('settings');

    await box.put('user', {
      'expediente': expedienteController.text,
      'nombre': nombreController.text,
      'tutor': tutorController.text,
      'correo': correoController.text,
      'telefono': telefonoController.text,
    });
  }

  @override
  void dispose() {
    expedienteController.dispose();
    nombreController.dispose();
    tutorController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Topbar(),
      ),

      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500, 
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [

                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        // 🔹 Título
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Flexible(
                              child: Text(
                                '¡Bienvenido a MEAL-HIC!',
                                style: AppTextStyles.titulo1,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Registra tu alimentación diaria y lleva\nel control de tu nutrición de forma fácil',
                          style: AppTextStyles.titulo3,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        Image.asset(
                          'assets/hic/mascota.png',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'Ingresa tu información',
                          style: AppTextStyles.titulo2,
                        ),

                        const Divider(),

                        Row(
                          children: const [
                            Icon(Icons.person, color: AppColors.titulo2),
                            SizedBox(width: 8),
                            Text(
                              'Información personal',
                              style: AppTextStyles.titulo3,
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: expedienteController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Número de expediente',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: tutorController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre tutor',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: correoController,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: telefonoController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Número de teléfono',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),

                            onPressed: () async {

                              if (expedienteController.text.trim().isEmpty ||
                                  nombreController.text.trim().isEmpty) {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ingresa número de expediente y nombre',
                                    ),
                                  ),
                                );

                                return;
                              }

                              await guardarDatos();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomNavbar(),
                                ),
                              );
                            },

                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(
                              'Continuar',
                              style: AppTextStyles.boton,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}