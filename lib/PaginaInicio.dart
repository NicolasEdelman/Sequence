import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

class GeneratorPage extends StatefulWidget {
  final VoidCallback onStartGame;
  final Function(String) onNameChanged;
  final Function(Color?, Color?) onColorChanged;
  final Function(int) onCantSequencesChanged;
  final Function(double) onLevelChanged;

  const GeneratorPage({Key? key, required this.onStartGame, required this.onNameChanged, required this.onColorChanged, required this.onCantSequencesChanged, required this.onLevelChanged}) : super(key: key);

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  TextEditingController _nameController = TextEditingController();
  int selectedSequence = 1;
  bool nombreVacio = false;
  double _currentSliderValue = 1;



  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Fondo1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SEQUENCE",
                  style: TextStyle(
                    fontSize: 65,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.white.withOpacity(0.5),
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese su nombre',
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.onNameChanged(value);
                  },
                ),
                if (nombreVacio)
                  Text(
                    "El nombre no puede estar vacio",
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 20),
                ColorSelector(
                  onColorsSelected: (Color? color1, Color? color2) {
                    widget.onColorChanged(color1, color2);
                  },
                ),
                SizedBox(height: 20),
                Text("Nivel:", style: TextStyle(color: Colors.white, fontSize: 20)),
                Slider(
                  value: _currentSliderValue,
                  max: 12,
                  divisions: 12,
                  label: _currentSliderValue.round() != 0
                      ? "${_currentSliderValue.round()}"
                      : "Reglas",
                  onChanged: (double value) {
                    widget.onLevelChanged(value);
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
                      activeColor: Colors.white,
                      onChanged: (int? value) {
                        selectedSequence = value!;
                        widget.onCantSequencesChanged(1);
                      },
                    ),
                    Text('1 Secuencia', style: TextStyle(color: Colors.white),),
                    Radio(
                      value: 2,
                      groupValue: selectedSequence,
                      activeColor: Colors.white,
                      onChanged: (int? value) {
                        setState(() {
                          selectedSequence = value!;
                          widget.onCantSequencesChanged(2);
                        });
                      },
                    ),
                    Text('2 Secuencias', style: TextStyle(color: Colors.white),),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String name = _nameController.text.trim();

                    if (name.isNotEmpty && _currentSliderValue.round() != 0) {
                      widget.onStartGame();
                    } else {
                      setState(() {
                        nombreVacio = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50), // Establecer el tamaño del botón
                  ),
                  child: const Text("Play", style: TextStyle(fontSize: 20),),
                ),
              ],
            ),
          ),
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
