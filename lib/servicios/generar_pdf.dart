import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;


const List<String> tiposComida = ['Desayuno', 'Comida', 'Cena'];

String _fechaClave(DateTime fecha) {
  final year = fecha.year.toString();
  final month = fecha.month.toString().padLeft(2, '0');
  final day = fecha.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _fechaBonita(DateTime fecha) {
  const dias = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  const meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]} del ${fecha.year}';
}

DateTime _soloFecha(DateTime fecha) {
  return DateTime(fecha.year, fecha.month, fecha.day);
}

Map<String, Map<String, dynamic>> _agruparAlimentos(List<dynamic> mealData) {
  final Map<String, Map<String, dynamic>> agrupados = {};

  for (final item in mealData) {
    if (item is Map) {
      final nombre = item['name']?.toString() ?? 'Sin nombre';
      final categoria = item['category']?.toString() ?? 'Sin categoría';
      final clave = '$categoria|$nombre';

      if (!agrupados.containsKey(clave)) {
        agrupados[clave] = {
          'nombre': nombre,
          'categoria': categoria,
          'cantidad': 1,
        };
      } else {
        agrupados[clave]!['cantidad'] =
            (agrupados[clave]!['cantidad'] as int) + 1;
      }
    }
  }

  return agrupados;
}

pw.Widget _seccionComida({
  required String tipoComida,
  required dynamic datosComida,
}) {
  if (datosComida == null || datosComida is! List || datosComida.isEmpty) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        '$tipoComida: Sin registrar',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  final agrupados = _agruparAlimentos(datosComida);

  final rows = agrupados.values.map((item) {
    return [
      item['cantidad'].toString(),
      item['categoria'].toString(),
      item['nombre'].toString(),
    ];
  }).toList();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        tipoComida,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Table.fromTextArray(
        headers: const ['Cant.', 'Categoría', 'Alimento'],
        data: rows,
        border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey500),
        headerStyle: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: const pw.BoxDecoration(
          color: PdfColors.grey300,
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(40),
          1: const pw.FixedColumnWidth(95),
          2: const pw.FlexColumnWidth(),
        },
      ),
      pw.SizedBox(height: 10),
    ],
  );
}

pw.Widget _seccionDia({
  required DateTime fecha,
  required Box mealBox,
}) {
  final claveFecha = _fechaClave(fecha);

  final comidasDelDia = tiposComida.map((tipo) {
    return mealBox.get('$claveFecha|$tipo');
  }).toList();

  final bool diaTieneDatos = comidasDelDia.any(
    (datos) => datos is List && datos.isNotEmpty,
  );

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.7),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          _fechaBonita(fecha),
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        if (!diaTieneDatos)
          pw.Text(
            'Sin comidas registradas este día.',
            style: const pw.TextStyle(fontSize: 10),
          )
        else
          ...tiposComida.map((tipo) {
            final datos = mealBox.get('$claveFecha|$tipo');

            return _seccionComida(
              tipoComida: tipo,
              datosComida: datos,
            );
          }),
      ],
    ),
  );
}

Future<Uint8List> construirPDF({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final pdf = pw.Document();

  final settingsBox = Hive.box('settings');
  final mealBox = Hive.box('meal_reports');

  final user = settingsBox.get('user') ?? {};

  pw.MemoryImage? logoImage;

  try {
    final logo = await rootBundle.load('assets/hic/logoBlanco.png');
    logoImage = pw.MemoryImage(logo.buffer.asUint8List());
  } catch (_) {
    logoImage = null;
  }

  final inicio = _soloFecha(fechaInicio);
  final fin = _soloFecha(fechaFin);

  final fechas = <DateTime>[];
  var actual = inicio;

  while (!actual.isAfter(fin)) {
    fechas.add(actual);
    actual = actual.add(const Duration(days: 1));
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) {
        return [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            color: PdfColors.black,
            child: pw.Center(
              child: logoImage != null
                  ? pw.Image(logoImage, height: 38)
                  : pw.Text(
                      'HIC',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
            ),
          ),

          pw.SizedBox(height: 16),

          pw.Text(
            'MEAL-HIC',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Reporte nutricional',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Periodo: ${_fechaBonita(inicio)} - ${_fechaBonita(fin)}',
            style: const pw.TextStyle(fontSize: 11),
          ),

          pw.SizedBox(height: 14),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Datos del paciente',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Expediente: ${user['expediente'] ?? 'N/A'}'),
                pw.Text('Nombre: ${user['nombre'] ?? 'N/A'}'),
                pw.Text('Tutor: ${user['tutor'] ?? 'N/A'}'),
                pw.Text('Correo: ${user['correo'] ?? 'N/A'}'),
                pw.Text('Teléfono: ${user['telefono'] ?? 'N/A'}'),
              ],
            ),
          ),

          pw.SizedBox(height: 18),

          pw.Text(
            'Registro de alimentos',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          ...fechas.map((fecha) {
            return _seccionDia(
              fecha: fecha,
              mealBox: mealBox,
            );
          }),
        ];
      },
    ),
  );

  return await pdf.save();
}

Future<void> compartirPDF({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final bytes = await construirPDF(
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
  );

  await Printing.sharePdf(
    bytes: bytes,
    filename:
        'reporte_nutricional_${_fechaClave(fechaInicio)}_${_fechaClave(fechaFin)}.pdf',
  );
}

Future<void> imprimirPDF({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final bytes = await construirPDF(
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
  );

  await Printing.layoutPdf(
    onLayout: (_) async => bytes,
  );
}

Future<void> verPDF({
  required DateTime fechaInicio,
  required DateTime fechaFin,
}) async {
  final bytes = await construirPDF(
    fechaInicio: fechaInicio,
    fechaFin: fechaFin,
  );

  if (kIsWeb) {
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'reporte_nutricional_${_fechaClave(fechaInicio)}_${_fechaClave(fechaFin)}.pdf',
    );
  } else {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
    );
  }
}