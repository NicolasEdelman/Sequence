import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratorPage extends StatefulWidget {
  final VoidCallback onStartGame;
  final Function(String) onNameChanged;
  final Function(Color?) onColorChanged;
  final Function(int) onCantSequencesChanged;
  final Function(double) onLevelChanged;
  final Function(int) onUniverseChanged;
  final Color mainColor;
  final int ultimoNivelDesbloqueado;
  final int universo;
  final int ultimoUniversoDesbloqueado;

  const GeneratorPage({Key? key, required this.onStartGame, required this.onNameChanged, required this.onColorChanged, required this.onCantSequencesChanged, required this.onLevelChanged, required this.onUniverseChanged, required this.mainColor, required this.ultimoNivelDesbloqueado, required this.universo, required this.ultimoUniversoDesbloqueado}) : super(key: key);

  @override
  State<GeneratorPage> createState() => _GeneratorPageState(
    mainColor: mainColor,
    ultimoNivelDesbloqueado: ultimoNivelDesbloqueado,
    universo: universo,
      ultimoUniversoDesbloqueado: ultimoUniversoDesbloqueado
  );
}

class _GeneratorPageState extends State<GeneratorPage> {

  TextEditingController _nameController = TextEditingController();
  int selectedSequence = 1;
  bool nombreVacio = false;
  double _currentSliderValue = 1;
  Color? mainColor;
  int ultimoNivelDesbloqueado;
  int ultimoNivelDisponible = 30;
  int universo;
  int ultimoUniversoDesbloqueado;

  _GeneratorPageState({
    required this.mainColor,
    required this.ultimoNivelDesbloqueado,
    required this.universo,
    required this.ultimoUniversoDesbloqueado
  }){
    //initSharedPreferences();
  }
  Future<void> initSharedPreferences() async {
    await leerDatos();
  }

  Future<void> leerDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ultimoNivelDesbloqueado = prefs.getInt('ultimoNivelDesbloqueado') ?? 1;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fondoPath = "";
    switch (universo){
      case 1:
        fondoPath = "assets/images/Fondo1.png";
      case 2:
        fondoPath = "assets/images/FondoVerde.png";
      case 3:
        fondoPath = "assets/images/FondoNegro.png";
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(fondoPath),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SEQUENCE",
                    style: TextStyle(
                      fontSize: 65,
                      color: mainColor,
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

                  Text("UNIVERSO $universo", style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ingrese su nombre',
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      errorText: nombreVacio ? "El nombre no puede estar vacío" : null,
                      hintStyle: TextStyle(color: Colors.white),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      widget.onNameChanged(value);
                      setState(() {
                        nombreVacio = value.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ColorSelector(
                    onColorsSelected: (Color? color1) {
                      setState(() {
                        mainColor = color1;
                      });
                      widget.onColorChanged(color1);
                    },
                  ),
                  SizedBox(height: 20),
                  Text("Nivel:", style: TextStyle(color: Colors.white, fontSize: 20)),
                  Slider(
                    activeColor: mainColor,
                    value: _currentSliderValue,
                    max: ultimoNivelDisponible.toDouble(),
                    divisions: ultimoNivelDisponible,
                    label: _currentSliderValue.round() != 0
                        ? "${_currentSliderValue.round()}"
                        : "Reglas",
                    onChanged: (double value) {
                      if(value <= ultimoNivelDesbloqueado){
                        widget.onLevelChanged(value);
                        setState(() {
                          _currentSliderValue = value;
                        });
                      }
                    },
                  ),
                  /*Row(
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
                  ),*/
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String name = _nameController.text.trim();
                      //name = "Nico";
                      if(name.isEmpty){
                        setState(() {
                          nombreVacio = true;
                        });
                      }
                      else if(_currentSliderValue.round() == 0){
                        panelReglas();
                      }
                      else{
                        widget.onStartGame();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50), // Establecer el tamaño del botón
                    ),
                    child: Text("Play", style: TextStyle(fontSize: 20, color: mainColor),),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(universo>1)
                        ElevatedButton(onPressed: (){
                          setState(() {
                            universo--;
                            widget.onUniverseChanged(universo);
                          });
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.7), // Color de fondo con 50% de opacidad
                            elevation: 0,
                          ),
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.arrow_left,
                              color: mainColor,
                              size: 20,
                            ),
                            SizedBox(width: 3),
                            Text(
                              "Universo anterior",
                              style: TextStyle(fontSize: 10, color: mainColor),
                            ),
                          ],
                        ),),
                      SizedBox(width: 10),
                      if(universo < ultimoUniversoDesbloqueado)
                        ElevatedButton(onPressed: (){
                          setState(() {
                            universo++;
                            widget.onUniverseChanged(universo);
                          });
                        },style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.7), // Color de fondo con 50% de opacidad
                          elevation: 0, // Elimina la sombra del botón
                        ),
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Proximo universo",
                              style: TextStyle(fontSize: 10, color: mainColor),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_right,
                              color: mainColor,
                              size: 20,
                            ),


                          ],
                        ),),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
  void panelReglas(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Dialog.fullscreen(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Reglas.png"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                    },
                    child: Text('Entendido'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}



class ColorSelector extends StatefulWidget {
  final Function(Color?) onColorsSelected;
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

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (Color color in colors)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          J1selectedColor = color;
                          widget.onColorsSelected(J1selectedColor);
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
            ]
        )
    );
  }
}
