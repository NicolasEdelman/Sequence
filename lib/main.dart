import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'Tablero.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'La primer App del Ticu', subtitle: 'Hola verano',),

    );
  }
}

class MyAppState extends ChangeNotifier{
  Color? J1selectedColor;
  Color? J2selectedColor;
  int selectedSequence = 1;
  String name = '';
  double? timer = 60;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool isPlaying = false;
  Color? J1selectedColor = Colors.blue;
  Color? J2selectedColor = Colors.green;
  int selectedSequence = 1;
  String name = '';
  double timer = 60;

  void handleNameChanged(String newName) {
    setState(() {
      name = newName;
    });
  }
  void handleColorChanged(Color? color1, Color? color2){
    setState(() {
      J1selectedColor = color1;
      J2selectedColor = color2;
    });
  }
  void handleCantSequencesChanged(int cant){
    setState(() {
      selectedSequence = cant;
    });
  }
  void handleTimerChanged(double time){
    setState(() {
      timer = time;
    });
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      selectedIndex = 1;
    });
  }



  void exitGame() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Salir del juego?'),
          content: Text('Si sales del juego, perderás todo tu progreso.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                setState(() {
                  isPlaying = false;
                  selectedIndex = 0;
                });
              },
              child: Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage(
          onStartGame: startGame,
          onNameChanged: handleNameChanged,
          onColorChanged: handleColorChanged,
          onCantSequencesChanged: handleCantSequencesChanged,
          onTimerChanged: handleTimerChanged,
        );
        break;
      case 1:
        page = TableroPage(
          J1selectedColor: J1selectedColor,
          J2selectedColor: J2selectedColor,
          selectedSequence: selectedSequence,
          name: name,
          timer: timer,
        );
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }


    return Scaffold(
      appBar: AppBar(
        actions: isPlaying
            ? [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Salir del juego',
            onPressed: exitGame,
          )
        ]
            : [
          IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: null,
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: Container(child: page,)),
        ]
        ),
    );
  }

}


class GeneratorPage extends StatefulWidget {
  final VoidCallback onStartGame;
  final Function(String) onNameChanged;
  final Function(Color?, Color?) onColorChanged;
  final Function(int) onCantSequencesChanged;
  final Function(double) onTimerChanged;

  const GeneratorPage({Key? key, required this.onStartGame, required this.onNameChanged, required this.onColorChanged, required this.onCantSequencesChanged, required this.onTimerChanged}) : super(key: key);

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  TextEditingController _nameController = TextEditingController();
  int selectedSequence = 1;
  bool nombreVacio = false;
  double _currentSliderValue = 60;



  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text("EL SEQUENCITO", style: TextStyle(fontSize: 40, color: Colors.lightBlue, fontWeight: FontWeight.bold,)),
            Text(
              "EL SEQUENCITO",
              style: TextStyle(
                fontSize: 40,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Cambia la fuente a una más atractiva
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ingrese su nombre', // Texto de sugerencia
                labelText: 'Nombre', // Etiqueta del TextField
                border: OutlineInputBorder(), // Estilo del borde
              ),
              onChanged: (value){
                widget.onNameChanged(value);
              },
            ),
            if(nombreVacio) Text("El nombre no puede estar vacio", style: TextStyle(color: Colors.red) ,),
            SizedBox(height: 20),
            ColorSelector(
              onColorsSelected: (Color? color1, Color? color2){
                widget.onColorChanged(color1, color2);
              },
            ),
            SizedBox(height: 20), // Espacio entre la caja de texto y el botón
            Text("Turn time:"),
            Slider(
              value: _currentSliderValue,
              max: 120,
              divisions: 12,
              label: "${_currentSliderValue.round().toString()}s",
              onChanged: (double value) {
                widget.onTimerChanged(value);
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 1,
                  groupValue: selectedSequence,
                  onChanged: (int? value) {
                    selectedSequence = value!;
                    widget.onCantSequencesChanged(1);
                  },
                ),
                Text('1 Secuencia'),
                Radio(
                  value: 2,
                  groupValue: selectedSequence,
                  onChanged: (int? value) {
                    setState(() {
                      selectedSequence = value!;
                      widget.onCantSequencesChanged(2);
                    });
                  },
                ),
                Text('2 Secuencias'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text.trim(); // Obtener el nombre ingresado y eliminar espacios en blanco al inicio y al final
                if (name.isNotEmpty) { // Verificar que el nombre no esté vacío
                  widget.onStartGame();
                } else {
                  setState(() {
                    nombreVacio = true;
                  });
                }
              },
              child: const Text("Play"),
            ),
          ],
        ),
      ),
    );
  }
}



class ColorSelector extends StatefulWidget {
  final Function(Color?, Color?) onColorsSelected;
  ColorSelector({required this.onColorsSelected});

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  Color? J1selectedColor = Colors.blue;
  Color? J2selectedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("J1:"),
              for (Color color in colors)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      J1selectedColor = color;
                      widget.onColorsSelected(J1selectedColor, J2selectedColor);
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: J1selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("J2:"),
              for (Color color in colors)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      J2selectedColor = color;
                      widget.onColorsSelected(J1selectedColor, J2selectedColor);
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: J2selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),

        ]
    )
    );
  }
}


class SliderApp extends StatelessWidget {
  const SliderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SliderExample(),
    );
  }
}

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider')),
      body: Slider(
        value: _currentSliderValue,
        max: 100,
        divisions: 5,
        label: _currentSliderValue.round().toString(),
        onChanged: (double value) {
          setState(() {
            _currentSliderValue = value;
          });
        },
      ),
    );
  }
}

