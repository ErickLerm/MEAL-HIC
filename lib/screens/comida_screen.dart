import 'dart:math' as math;
import 'package:app_pvvc/servicios/servicio_platillos.dart';
import 'package:app_pvvc/widgets/widgets_comida/dialogo_infantil.dart';
import 'package:app_pvvc/widgets/widgets_comida/acciones_comida.dart';
import 'package:app_pvvc/widgets/widgets_comida/controles_superiores_comida.dart';
import 'package:app_pvvc/widgets/widgets_comida/lista_categorias_comida.dart';
import 'package:app_pvvc/widgets/widgets_comida/lista_alimentos_comida.dart';
import 'package:app_pvvc/widgets/widgets_comida/panel_lateral_comida.dart';
import 'package:app_pvvc/widgets/widgets_comida/tarjeta_plato_bebida.dart';
import 'package:flutter/material.dart';
import 'package:app_pvvc/modelos/alimento.dart';
import 'package:app_pvvc/modelos/item_platillo.dart';
import 'package:app_pvvc/modelos/categoria.dart';
import 'package:app_pvvc/datos/bd_alimentos.dart';
import 'package:app_pvvc/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ComidaScreen extends StatefulWidget {
  const ComidaScreen({super.key});

  @override
  State<ComidaScreen> createState() => _ComidaScreenState();
}

class _ComidaScreenState extends State<ComidaScreen> {
  final List<String> diasSemana = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final List<String> tiposComida = const ['Desayuno', 'Comida', 'Cena'];

  static const int maximoAlimentosEnPlatillo = 11;

  static const Color colorTema = AppColors.primary;
  static const Color colorTemaOscuro = Color(0xFFE06267);

  final GlobalKey clavePlato = GlobalKey();

  bool mostrarPanelLateral = false;
  String? nombreCategoriaSeleccionada;

  DateTime fechaSeleccionada = DateTime.now();
  String tipoComidaSeleccionado = 'Desayuno';

  List<ItemPlatillo> platilloActual = [];
  final Map<String, List<ItemPlatillo>> platillosGuardados = {};

  int? indiceItemArrastrandose;
  bool seArrastraFueraDelPlato = false;
  bool seArrastraBebidaFuera = false;

  double tamanoActualItemArrastre = 84.0;

  String get clavePlatillo {
    return ServicioPlatillos.crearClave(
      fecha: fechaSeleccionada,
      tipoComida: tipoComidaSeleccionado,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shortestSide = MediaQuery.of(context).size.shortestSide;
      final bool esCelular = shortestSide < 600;

      if (esCelular) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      }
    });

    _cargarPlatilloActual();
  }

  String _nombreDia(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    return dias[fecha.weekday - 1];
  }

  String _nombreMes(DateTime fecha) {
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

    return meses[fecha.month - 1];
  }

  Future<void> _cambiarFecha(DateTime nuevaFecha) async {
    await _guardadoAutomatico();

    setState(() {
      fechaSeleccionada = DateTime(
        nuevaFecha.year,
        nuevaFecha.month,
        nuevaFecha.day,
      );
      nombreCategoriaSeleccionada = null;
      mostrarPanelLateral = false;
    });

    _cargarPlatilloActual();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return;

    await _cambiarFecha(fecha);
  }

  void _cambiarTipoComida(String tipoComida) {
    _guardadoAutomatico();
    setState(() {
      tipoComidaSeleccionado = tipoComida;
      nombreCategoriaSeleccionada = null;
      mostrarPanelLateral = false;
    });
    _cargarPlatilloActual();
  }

  Future<void> _guardadoAutomatico() async {
    await ServicioPlatillos.guardarPlatillo(
      fecha: fechaSeleccionada,
      tipoComida: tipoComidaSeleccionado,
      platillo: platilloActual,
      platillosGuardados: platillosGuardados,
    );
  }

  void _cargarPlatilloActual() {
    final platilloCargado = ServicioPlatillos.cargarPlatillo(
      fecha: fechaSeleccionada,
      tipoComida: tipoComidaSeleccionado,
      platillosGuardados: platillosGuardados,
    );

    setState(() {
      platilloActual = platilloCargado;
    });
  }

  void _abrirPanel() {
    setState(() {
      mostrarPanelLateral = true;
      nombreCategoriaSeleccionada = null;
    });
  }

  void _cerrarPanel() {
    setState(() {
      mostrarPanelLateral = false;
      nombreCategoriaSeleccionada = null;
    });
  }

  Categoria? _buscarCategoria(String nombre) {
    try {
      return categorias.firstWhere((categoria) => categoria.nombre == nombre);
    } catch (_) {
      return null;
    }
  }

  String _nombreBonitoCategoria(String categoria) {
    if (categoria.isEmpty) return categoria;
    return categoria[0].toUpperCase() + categoria.substring(1);
  }

  int _cantidadSeleccionadaPorCategoria(
    String nombreCategoria, [
    List<ItemPlatillo>? platillo,
  ]) {
    final origen = platillo ?? platilloActual;
    return origen
        .where((item) => item.alimento.categoria == nombreCategoria)
        .length;
  }

  bool _puedeAgregarAlimento(Alimento alimento) {
    final categoria = _buscarCategoria(alimento.categoria);
    if (categoria == null) return true;
    return _cantidadSeleccionadaPorCategoria(alimento.categoria) <
        categoria.maximoSeleccion;
  }

  bool _platilloCompleto(List<ItemPlatillo> platillo) {
    if (platillo.length < maximoAlimentosEnPlatillo) return false;

    for (final categoria in categorias) {
      if (_cantidadSeleccionadaPorCategoria(categoria.nombre, platillo) <
          categoria.maximoSeleccion) {
        return false;
      }
    }
    return true;
  }

  List<ItemPlatillo> _platilloPorTipoComida(String tipoComida) {
    if (tipoComida == tipoComidaSeleccionado) return platilloActual;

    final clave = ServicioPlatillos.crearClave(
      fecha: fechaSeleccionada,
      tipoComida: tipoComida,
    );

    final guardado = platillosGuardados[clave];

    if (guardado != null) return guardado;

    return ServicioPlatillos.cargarPlatillo(
      fecha: fechaSeleccionada,
      tipoComida: tipoComida,
      platillosGuardados: platillosGuardados,
    );
  }

  EstadoVisualComida _estadoComida(String tipoComida) {
    final platillo = _platilloPorTipoComida(tipoComida);

    if (platillo.isEmpty) return EstadoVisualComida.vacio;
    if (_platilloCompleto(platillo)) return EstadoVisualComida.completo;
    return EstadoVisualComida.enProgreso;
  }

  void _agregarAlimento(Alimento alimento, {Offset? posicionInicial}) {
    if (platilloActual.length >= maximoAlimentosEnPlatillo) {
      mostrarDialogoInfantil(
        context: context,
        titulo: '¡Platillo completo! 🥳',
        mensaje: 'Ya agregaste todas las porciones de este platillo.',
        icono: Icons.emoji_events_rounded,
        color: Colors.orange,
      );
      return;
    }

    if (!_puedeAgregarAlimento(alimento)) {
      final categoria = _buscarCategoria(alimento.categoria);
      final maximoSeleccion = categoria?.maximoSeleccion ?? 0;

      mostrarDialogoInfantil(
        context: context,
        titulo: '¡Esa categoría ya está lista! ✨',
        mensaje:
            'Ya agregaste $maximoSeleccion ${maximoSeleccion == 1 ? 'porción' : 'porciones'} de ${_nombreBonitoCategoria(alimento.categoria)}.',
        icono: Icons.lock_rounded,
        color: Colors.redAccent,
      );
      return;
    }

    setState(() {
      if (alimento.categoria == 'Bebidas') {
        final indiceBebidaAnterior = platilloActual.indexWhere(
          (item) => item.alimento.categoria == 'Bebidas',
        );
        if (indiceBebidaAnterior != -1) {
          platilloActual.removeAt(indiceBebidaAnterior);
        }
      }

      platilloActual.add(
        ItemPlatillo(
          alimento: alimento,
          posicion:
              posicionInicial ??
              (alimento.categoria == 'Bebidas'
                  ? const Offset(0.25, 0.5)
                  : const Offset(0.5, 0.5)),
        ),
      );

      mostrarPanelLateral = false;
      nombreCategoriaSeleccionada = null;
    });
  }

  void _eliminarBebida() {
    final indiceBebida = platilloActual.indexWhere(
      (item) => item.alimento.categoria == 'Bebidas',
    );

    if (indiceBebida == -1) return;

    setState(() {
      platilloActual.removeAt(indiceBebida);
      seArrastraBebidaFuera = false;
    });
  }

  bool _categoriaCompleta(Categoria categoria) {
    return _cantidadSeleccionadaPorCategoria(categoria.nombre) >=
        categoria.maximoSeleccion;
  }

  Color _colorEstado(bool completado) {
    return completado ? Colors.green : Colors.amber;
  }

  ItemPlatillo? _bebidaSeleccionada() {
    try {
      return platilloActual.firstWhere(
        (item) => item.alimento.categoria == 'Bebidas',
      );
    } catch (_) {
      return null;
    }
  }

  List<ItemPlatillo> _alimentosSoloDelPlatillo() {
    return platilloActual
        .where((item) => item.alimento.categoria != 'Bebidas')
        .toList();
  }

  Widget _assetSeguro({
    required String ruta,
    double? ancho,
    double? alto,
    BoxFit ajuste = BoxFit.contain,
  }) {
    return Image.asset(
      ruta,
      width: ancho,
      height: alto,
      fit: ajuste,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/placeholder.png',
          width: ancho,
          height: alto,
          fit: ajuste,
        );
      },
    );
  }

  bool _estaFueraDelPlato({
    required Offset posicion,
    required double tamanoPlato,
    required double tamanoItem,
  }) {
    const centro = Offset(0.5, 0.5);
    final vector = Offset(posicion.dx - centro.dx, posicion.dy - centro.dy);
    final distancia = vector.distance;
    final radioItem = (tamanoItem / 2) / tamanoPlato;
    const radioPlato = 0.5;
    return distancia > (radioPlato - radioItem * 0.35);
  }

  bool _estaFueraDeZonaBebida({
    required Offset posicion,
    required double anchoZona,
    required double altoZona,
    required double tamanoItem,
  }) {
    final mitadAncho = (tamanoItem / 2) / anchoZona;
    final mitadAlto = (tamanoItem / 2) / altoZona;

    return posicion.dx < mitadAncho ||
        posicion.dx > (1 - mitadAncho) ||
        posicion.dy < mitadAlto ||
        posicion.dy > (1 - mitadAlto);
  }

  Offset _obtenerPosicionRelativaLibre({
    required Offset posicionLocal,
    required double tamano,
  }) {
    return Offset(posicionLocal.dx / tamano, posicionLocal.dy / tamano);
  }

  void _actualizarPosicionItemPlatilloLibre({
    required int indice,
    required DragUpdateDetails detalles,
    required double tamanoPlato,
  }) {
    final item = platilloActual[indice];
    final nuevoDx = item.posicion.dx + (detalles.delta.dx / tamanoPlato);
    final nuevoDy = item.posicion.dy + (detalles.delta.dy / tamanoPlato);
    final nuevaPosicion = Offset(nuevoDx, nuevoDy);

    final fuera = _estaFueraDelPlato(
      posicion: nuevaPosicion,
      tamanoPlato: tamanoPlato,
      tamanoItem: tamanoActualItemArrastre,
    );

    setState(() {
      item.posicion = nuevaPosicion;
      indiceItemArrastrandose = indice;
      seArrastraFueraDelPlato = fuera;
    });
  }

  void _actualizarPosicionBebida({
    required ItemPlatillo itemBebida,
    required DragUpdateDetails detalles,
    required double anchoZona,
    required double altoZona,
    required double tamanoItem,
  }) {
    final nuevoDx = itemBebida.posicion.dx + (detalles.delta.dx / anchoZona);
    final nuevoDy = itemBebida.posicion.dy + (detalles.delta.dy / altoZona);
    final nuevaPosicion = Offset(nuevoDx, nuevoDy);

    final fuera = _estaFueraDeZonaBebida(
      posicion: nuevaPosicion,
      anchoZona: anchoZona,
      altoZona: altoZona,
      tamanoItem: tamanoItem,
    );

    setState(() {
      itemBebida.posicion = nuevaPosicion;
      seArrastraBebidaFuera = fuera;
    });
  }

  Future<void> _limpiarPlatilloActual() async {
    setState(() {
      platilloActual.clear();
      indiceItemArrastrandose = null;
      seArrastraFueraDelPlato = false;
      seArrastraBebidaFuera = false;
      mostrarPanelLateral = false;
      nombreCategoriaSeleccionada = null;
    });

    await _guardadoAutomatico();

    if (!mounted) return;

    mostrarSnackBarEliminado(context);
  }

  bool _esHoy(DateTime fecha) {
    final hoy = DateTime.now();

    return fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;
  }

  String _mesCorto(DateTime fecha) {
    final mes = _nombreMes(fecha).substring(0, 3);
    return mes[0].toUpperCase() + mes.substring(1);
  }

  Widget _buildControlesPorFecha({required bool compacto}) {
    final double fontFecha = compacto ? 11.0 : 14.0;
    final double fontBoton = compacto ? 11.0 : 14.0;
    final double paddingXBoton = compacto ? 8.0 : 18.0;
    final double paddingYBoton = compacto ? 6.0 : 10.0;
    final double espacioWrap = compacto ? 6.0 : 10.0;
    final double iconSize = compacto ? 16.0 : 22.0;
    final double spacerunning = compacto ? 4.0 : 8.0;

    return Column(
      children: [
        Center(
          child: TextButton.icon(
            onPressed: _seleccionarFecha,
            icon: Icon(Icons.calendar_month_rounded, size: iconSize),
            label: Text(
              _esHoy(fechaSeleccionada)
                  ? 'Hoy: ${_nombreDia(fechaSeleccionada)} ${fechaSeleccionada.day} ${_mesCorto(fechaSeleccionada)}'
                  : '${_nombreDia(fechaSeleccionada)} ${fechaSeleccionada.day} ${_mesCorto(fechaSeleccionada)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: fontFecha,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: paddingXBoton,
                vertical: paddingYBoton,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),

        SizedBox(height: espacioWrap),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: espacioWrap,
          runSpacing: spacerunning,
          children: tiposComida.map((tipoComida) {
            final estado = _estadoComida(tipoComida);
            final seleccionado = tipoComidaSeleccionado == tipoComida;

            final color = estado == EstadoVisualComida.completo
                ? Colors.green
                : estado == EstadoVisualComida.enProgreso
                ? Colors.amber.shade700
                : Colors.blue;

            return GestureDetector(
              onTap: () => _cambiarTipoComida(tipoComida),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingXBoton,
                  vertical: paddingYBoton,
                ),
                decoration: BoxDecoration(
                  color: seleccionado
                      ? color.withOpacity(0.18)
                      : AppColors.g4.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: seleccionado ? color : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Text(
                  tipoComida,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: fontBoton,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tamanoPantalla = MediaQuery.of(context).size;
    final bool esTablet = tamanoPantalla.width >= 700;
    final double anchoPanel = esTablet ? 450.0 : tamanoPantalla.width * 0.82;
    final bool celularCompacto =
        tamanoPantalla.shortestSide < 390 || tamanoPantalla.height < 700;
    final double paddingHorizontalPantalla = celularCompacto ? 4.0 : 10.0;
    final double paddingVerticalPantalla = celularCompacto ? 4.0 : 12.0;
    final double espacioControlesPlato = celularCompacto ? 4.0 : 8.0;
    final double espacioPlatoAcciones = celularCompacto ? 3.0 : 8.0;
    print('WIDTH: ${tamanoPantalla.width}');
    print('HEIGHT: ${tamanoPantalla.height}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _cerrarPanel,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  paddingHorizontalPantalla,
                  paddingVerticalPantalla,
                  paddingHorizontalPantalla,
                  paddingVerticalPantalla,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        _buildControlesPorFecha(compacto: celularCompacto),
                        SizedBox(height: espacioControlesPlato),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final plataforma = defaultTargetPlatform;

                              final bool esWebEnEscritorio =
                                  kIsWeb &&
                                  (plataforma == TargetPlatform.windows ||
                                      plataforma == TargetPlatform.macOS ||
                                      plataforma == TargetPlatform.linux);

                              final double anchoMaximoTarjeta =
                                  constraints.maxWidth;
                              final double altoDisponible =
                                  constraints.maxHeight;

                              final bool pantallaHorizontal =
                                  anchoMaximoTarjeta >= 720 &&
                                  anchoMaximoTarjeta > altoDisponible;

                              final double factorBebida = celularCompacto
                                  ? 0.24
                                  : (altoDisponible < 650 ? 0.28 : 0.20);

                              final double tamanoZonaBebida = pantallaHorizontal
                                  ? math.min(altoDisponible * 0.85, 260.0)
                                  : altoDisponible * factorBebida;

                              final double espacioEntrePlatoYBebida =
                                  pantallaHorizontal ? 0.0 : 6.0;

                              final double margenSeguridad = 8.0;

                              final double altoDisponibleParaPlato =
                                  pantallaHorizontal
                                  ? altoDisponible - margenSeguridad
                                  : altoDisponible -
                                        tamanoZonaBebida -
                                        espacioEntrePlatoYBebida -
                                        margenSeguridad;

                              final double anchoDisponibleParaPlato =
                                  pantallaHorizontal
                                  ? anchoMaximoTarjeta * 0.62
                                  : anchoMaximoTarjeta * 0.94;

                              final double tamanoPlatoBase = math.min(
                                anchoDisponibleParaPlato,
                                altoDisponibleParaPlato,
                              );

                              final double tamanoMinimoPlato = celularCompacto
                                  ? altoDisponible * 0.68
                                  : 230.0;

                              final double tamanoPlato = tamanoPlatoBase.clamp(
                                tamanoMinimoPlato,
                                esTablet ? 600.0 : 480.0,
                              );

                              final double altoNecesario = pantallaHorizontal
                                  ? tamanoPlato + margenSeguridad
                                  : tamanoPlato +
                                        tamanoZonaBebida +
                                        espacioEntrePlatoYBebida +
                                        margenSeguridad;

                              final bool mostrarAjustaPantalla =
                                  esWebEnEscritorio &&
                                  altoDisponible < altoNecesario;

                              if (mostrarAjustaPantalla) {
                                return Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 18,
                                    ),
                                    child: const Text(
                                      'Ajusta tu pantalla',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return TarjetaPlatoBebida(
                                tamanoPlato: tamanoPlato,
                                tamanoZonaBebida: tamanoZonaBebida,
                                esTablet: esTablet,
                                alimentosDelPlatillo:
                                    _alimentosSoloDelPlatillo(),
                                itemBebida: _bebidaSeleccionada(),
                                platilloActual: platilloActual,
                                indiceItemArrastrandose:
                                    indiceItemArrastrandose,
                                seArrastraFueraDelPlato:
                                    seArrastraFueraDelPlato,
                                seArrastraBebidaFuera: seArrastraBebidaFuera,
                                colorTema: colorTema,
                                colorTemaOscuro: colorTemaOscuro,
                                clavePlato: clavePlato,
                                puedeAgregarAlimento: _puedeAgregarAlimento,
                                estaFueraDelPlato: _estaFueraDelPlato,
                                estaFueraDeZonaBebida: _estaFueraDeZonaBebida,
                                obtenerPosicionRelativaLibre:
                                    _obtenerPosicionRelativaLibre,
                                agregarAlimento: _agregarAlimento,
                                iniciarArrastreAlimento: (indiceReal) {
                                  setState(() {
                                    indiceItemArrastrandose = indiceReal;
                                    seArrastraFueraDelPlato = false;
                                  });
                                },
                                actualizarPosicionItemPlatilloLibre:
                                    _actualizarPosicionItemPlatilloLibre,
                                finalizarArrastreAlimento:
                                    (indiceReal, debeEliminarse) {
                                      setState(() {
                                        if (debeEliminarse) {
                                          platilloActual.removeAt(indiceReal);
                                        }
                                        indiceItemArrastrandose = null;
                                        seArrastraFueraDelPlato = false;
                                      });
                                    },
                                cancelarArrastreAlimento: () {
                                  setState(() {
                                    indiceItemArrastrandose = null;
                                    seArrastraFueraDelPlato = false;
                                  });
                                },
                                iniciarArrastreBebida: () {
                                  setState(() {
                                    seArrastraBebidaFuera = false;
                                  });
                                },
                                actualizarPosicionBebida:
                                    _actualizarPosicionBebida,
                                finalizarArrastreBebida: (debeEliminarse) {
                                  if (debeEliminarse) {
                                    _eliminarBebida();
                                  }
                                  setState(() {
                                    seArrastraBebidaFuera = false;
                                  });
                                },
                                cancelarArrastreBebida: () {
                                  setState(() {
                                    seArrastraBebidaFuera = false;
                                  });
                                },
                                construirAlimentoEnPlato: _buildAlimentoEnPlato,
                                construirVisualBebida: _buildVisualBebida,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: espacioPlatoAcciones),
                        AccionesComida(
                          compacto: celularCompacto,
                          alAgregarAlimento: _abrirPanel,
                          alEliminarAlimento: _limpiarPlatilloActual,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (mostrarPanelLateral)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _cerrarPanel,
                  child: Container(color: Colors.black.withOpacity(0.18)),
                ),
              ),
            PanelLateralComida(
              mostrarPanel: mostrarPanelLateral,
              anchoPanel: anchoPanel,
              nombreCategoriaSeleccionada: nombreCategoriaSeleccionada,
              alCerrarPanel: _cerrarPanel,
              alRegresarCategorias: () {
                setState(() {
                  nombreCategoriaSeleccionada = null;
                });
              },
              listaCategorias: ListaCategoriasComida(
                categorias: categorias,
                obtenerCantidadCategoria: _cantidadSeleccionadaPorCategoria,
                categoriaCompleta: _categoriaCompleta,
                obtenerColorEstado: _colorEstado,
                alSeleccionarCategoria: (nombreCategoria) {
                  setState(() {
                    nombreCategoriaSeleccionada = nombreCategoria;
                  });
                },
                construirAssetSeguro: _assetSeguro,
              ),
              listaAlimentos: nombreCategoriaSeleccionada == null
                  ? const SizedBox.shrink()
                  : ListaAlimentosComida(
                      alimentos: alimentos,
                      nombreCategoria: nombreCategoriaSeleccionada!,
                      puedeAgregarAlimento: _puedeAgregarAlimento,
                      alAgregarAlimento: _agregarAlimento,
                      alIniciarArrastre: () {
                        setState(() {
                          mostrarPanelLateral = false;
                          nombreCategoriaSeleccionada = null;
                        });
                      },
                      construirAssetSeguro: _assetSeguro,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlimentoEnPlato(Alimento alimento, bool esTablet) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: FittedBox(
        fit: BoxFit.contain,
        child: _assetSeguro(
          ruta: alimento.imagen,
          ancho: esTablet ? 130.0 : 100.0,
          alto: esTablet ? 130.0 : 100.0,
        ),
      ),
    );
  }

  Widget _buildVisualBebida(Alimento alimento, bool esTablet) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: FittedBox(
        fit: BoxFit.contain,
        child: _assetSeguro(
          ruta: alimento.imagen,
          ancho: esTablet ? 138.0 : 108.0,
          alto: esTablet ? 138.0 : 108.0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _guardadoAutomatico();

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }
}
