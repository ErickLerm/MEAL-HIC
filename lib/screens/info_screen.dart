import 'package:flutter/material.dart';
import '../widgets/slide_item.dart'; // 👈 importa el otro archivo
import '../theme/app_colors.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {

final List<Map<String, dynamic>> secciones = [
  {
    "titulo": "🍽️ Plato del bien comer",
    "descripcion": "",
    "imagen": "assets/info/plato.png",
    "colorFondo":  Colors.white,
    "textoLargo": """
    El Plato del Bien Comer es una representación gráfica creada para orientar a las personas sobre cómo deben distribuir los alimentos en sus comidas diarias. Está pensado principalmente en la población mexicana.

    El Plato del Bien Comer actual se divide en cinco grupos principales:

    🍅 Frutas y Verduras.
    🍞 Granos y cereales. 
    🫘 Leguminosas.
    🥩 Origen animal. 
    🥑 Aceites y grasas saludables.

    El Plato del Bien Comer es de suma importancia porque nos permite llevar una dieta equilibrada y variada, lo que es esencial para mantener una buena salud. 
    """
      },

  {
    "titulo": "🍅 Frutas y Verduras",
    "descripcion": "Grupo1",
    "imagen": "assets/info/plato-frutas.png",
    "colorFondo":  AppColors.g1,
    "textoLargo": """
      Este grupo incluye: una gran variedad de verduras por ejemplo la acelga, apio, brócoli, espinacas, jícama, jitomate, lechuga, pepino, zanahoria y frutas tales como el arándano, fresa, kiwi, mandarina, manzana, mango, naranja, papaya, entre otras.

      🥦 Las verduras contienen fibra, vitaminas y minerales que contribuyen al buen funcionamiento del organismo.

      🍎 Las frutas contienen carbohidratos que nos brindan energía, fibra, vitaminas, minerales y antioxidantes.

      🥬 Elige consumir verduras y frutas en medida de lo posible con cáscara, por su alto contenido en fibra.

      🍒 En el desayuno, comida y cena incluye siempre verduras, y elige como postre una ración pequeña de fruta de temporada.

      🚫 Evite el consumo de jugos naturales o industrializado, licuados, aguas saborizadas y endulzadas, es mejor comer las frutas y verduras por pieza o trozo.
      """
  },
  {
    "titulo": "🍞 Cereales integrales",
    "descripcion": "Grupo 2",
    "imagen": "assets/info/plato-cereales.png",
    "colorFondo": AppColors.g2,
    "textoLargo": """
      El grupo 2 incluye a los granos enteros como el amaranto, arroz, avena, centeno, cebada, maíz, trigo o quinoa y sus derivados como la tortilla, pasta o pan. También incluye algunos tubérculos como el camote, papa o yuca.

      ⚡ Brindan carbohidratos y una pequeña cantidad de proteína vegetal. Son la principal fuente de energía para el organismo.

      🍞 Elige consumir granos enteros o cereales integrales debido a su contenido de fibra, esto contribuye a la salud intestinal.

      ❌ Evite el consumo de cereales refinados (pan dulce, galletas o cereal de caja, entre otros) con alto contenido de azucares y grasas.
 """
  },
  {
    "titulo": "🫘 Leguminosas",
    "descripcion": "Grupo 3",
    "imagen": "assets/info/plato-leguminosas.png",
    "colorFondo": AppColors.g3,
    "textoLargo": """
    En las leguminosas se encuentran los alubias, alverjones, frijoles, garbanzos, habas, lentejas entre otros.

    👋 Brindan energía, carbohidratos, fibra, proteína vegetal, vitamina B y minerales como el hierro, que previene la anemia.

    🍌 Son buena fuente de potasio, un nutrimento que contribuye al funcionamiento del corazón y contribuye en las funciones digestivas y musculares

    ✅ Al comer leguminosas agrega alimentos que contengan Vitamina C, ya que contribuye a la absorción del hierro.

    ☑️ Las leguminosas son bajas en grasas y no tienen colesterol, lo que contribuye a la salud cardiovascular.

    ⏲️ Consuma leguminosas diariamente y elige prepararlas en guisados o sopas con verduras, puede agregar gotitas de limón en su preparación.
 """
  },

    {
    "titulo": "🥩 Alimentos de origen animal",
    "descripcion": "Grupo 4",
    "imagen": "assets/info/plato-animal.png",
    "colorFondo": AppColors.g4,
    "textoLargo": """
    En este grupo se encuentran las carnes, huevo, pescado, leche, queso y yogur. Son indispensables para el adecuado crecimiento y desarrollo.

    💪 Brindan proteínas, grasas y vitaminas del complejo B, necesarios para formación de tejidos.

    🐟 Consume al menos una vez a la semana pescados o carnes blancas sin grasa.

🥩 Elige carnes rojas sin grasa (magras).

    💭 Prefiere quesos blancos y frescos, evita los quesos amarillos o añejos.

    🍼 Elige leche y yogur descremados, evita leches endulzadas o de sabor.

    🍲 Elige preparaciones caldosas, asadas o a la plancha y evita preparaciones fritas o empanizadas.
    """
  },

    {
    "titulo": "🥑 Aceites y grasas saludables",
    "descripcion": "Grupo 5",
    "imagen": "assets/info/plato-aceite.png",
    "colorFondo": AppColors.g5,
    "textoLargo": """
      Incluye aceites de maíz, cártamo, canola entre otros, y alimentos como el aguacate, ajonjolí, almendra, avellana, cacahuate, nuez, entre otros.

      🥛 Su principal nutrimento son los lípidos (grasas) que brindan energía, protegen a las células con una pared de lípidos y ayudan al transporte de vitaminas para el buen funcionamiento del organismo.

      ✔️ Elige aceites de maíz, canola o cártamo para cocinar y de oliva para ensaladas o preparaciones frías."""
  },
];


   late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: secciones.length * 1000, // empieza en la primera sección
    );
  }

  // 🔹 Índice circular
  int getRealIndex(int index) {
    final length = secciones.length;
    return ((index % length) + length) % length;
  }

  void siguiente() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void anterior() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600, // 👈 límite tablet/web
          ),

          child: Stack(
            children: [

              // 🔹 SLIDER
              PageView.builder(
                controller: _controller,
                itemBuilder: (context, index) {
                  final realIndex = getRealIndex(index);

                  return SlideItem(
                    titulo: secciones[realIndex]["titulo"]!,
                    descripcion: secciones[realIndex]["descripcion"]!,
                    imagen: secciones[realIndex]["imagen"]!,
                    colorFondo: secciones[realIndex]["colorFondo"] as Color,
                    textoLargo: secciones[realIndex]["textoLargo"]!,
                  );
                },
              ),

              // 🔹 FLECHA IZQUIERDA
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 40),
                  onPressed: anterior,
                ),
              ),

              // 🔹 FLECHA DERECHA
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 40),
                  onPressed: siguiente,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}