import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/styles.dart';
import '../theme/app_colors.dart';

class AcercaDeScreen extends StatefulWidget {
  const AcercaDeScreen({super.key});

  @override
  State<AcercaDeScreen> createState() => _AcercaDeScreenState();
}

class _AcercaDeScreenState extends State<AcercaDeScreen> {
 

  final List<Map<String, String>> contactos = const [
    {
      'nombre': 'Lic. Sara Fajardo',
      'cargo': 'Médico Nutriólogo',
      'correo': 'Nutricion@hospitalinfantil.org',
    },
    {
      'nombre': 'Lic. Carolina González ',
      'cargo': 'Nutrióloga',
      'correo': 'Nutricion2@hospitalinfantil.org',
    },
    {
      'nombre': 'Lic. Rodrigo Morgado',
      'cargo': 'Médico Nutriólogo',
      'correo': 'Nutricionpp@hospitalinfantil.org',
    },
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // 🔹 CONTACTO
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.contacts, color: AppColors.titulo2, size: 20),
                            SizedBox(width: 8),
                            Text('Contacto', style: AppTextStyles.titulo2),
                          ],
                        ),
                        const Divider(
                          color: AppColors.titulo2,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                        ),
                        const SizedBox(height: 10),
                        ...contactos.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.person, color: AppColors.titulo2, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['nombre']!, style: AppTextStyles.titulo3),
                                    //Text(c['cargo']!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                    GestureDetector(
                                      onTap: () => launchUrl(Uri.parse('mailto:${c['correo']}')),
                                      child: Text(
                                        c['correo']!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 DIRECCIÓN Y COPYRIGHT
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: AppColors.titulo2, size: 20),
                            SizedBox(width: 8),
                            Text('Dirección', style: AppTextStyles.titulo2),
                          ],
                        ),
                        const Divider(
                          color: AppColors.titulo2,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Hospital Infantil de las Californias',
                            style: AppTextStyles.titulo2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Avenida Alejandro von Humboldt 11431 y Garita de Otay, 22430 Tijuana, Baja California, México',
                          style: AppTextStyles.titulo3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '© 2026 Hospital Infantil. v0.4',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            textAlign: TextAlign.center,
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