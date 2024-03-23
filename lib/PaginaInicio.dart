import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/myAppState.dart';
import 'package:provider/provider.dart';


class GeneratorPage extends StatefulWidget {
  final VoidCallback onStartGame;
  final Function(double) onLevelChanged;
  final Function(int) onUniverseChanged;
  final Color mainColor;
  final int universo;
  final int ultimoUniversoDesbloqueado;
  final int ultimoNivelDesbloqueado;
  final List<int> nivelesUniversos;

   GeneratorPage({
    Key? key,
    required this.onStartGame,
    required this.onLevelChanged,
    required this.onUniverseChanged,
    required this.mainColor,
    required this.universo,
    required this.ultimoUniversoDesbloqueado,
    required this.ultimoNivelDesbloqueado,
    required this.nivelesUniversos}) : super(key: key){
  }

  @override
  State<GeneratorPage> createState() => _GeneratorPageState(
    mainColor: mainColor,
    universo: universo,
    ultimoUniversoDesbloqueado: ultimoUniversoDesbloqueado,
    ultimoNivelDesbloqueado: ultimoNivelDesbloqueado,
    nivelesUniversos: nivelesUniversos,
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
  List<int> nivelesUniversos = [];
  bool cambieUniverso = false;

  _GeneratorPageState({
    required this.mainColor,
    required this.universo,
    required this.ultimoUniversoDesbloqueado,
    required this.ultimoNivelDesbloqueado,
    required this.nivelesUniversos,
  });

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    _currentSliderValue = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(cambieUniverso){
      _currentSliderValue = 1;
      cambieUniverso = false;
    }
    return Consumer<MyState>(
      builder: (context, myState, _){
        mainColor = myState.J1selectedColor ?? Colors.blue;
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
                        /*TextField(
                          controller: _nameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ingrese su nombre',
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                            errorText: nombreVacio ? "El nombre no puede estar vacío" : null,
                            hintStyle: TextStyle(color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          onChanged: (value) {
                            context.read<MyState>().cambiarNombre(value);
                            setState(() {
                              nombreVacio = value.isEmpty;
                            });
                          },
                        ),*/
                        SizedBox(height: 20),
                        ColorSelector(
                          actualColor: context.read<MyState>().J1selectedColor ?? Colors.blue,
                          onColorsSelected: (Color? color1) {
                            setState(() {
                              mainColor = color1;
                            });
                            context.read<MyState>().cambiarColor(mainColor!);
                          },
                        ),
                        SizedBox(height: 20),
                        Text("Nivel:", style: TextStyle(color: Colors.white, fontSize: 20)),
                        Slider(
                          activeColor: mainColor,
                          value: _currentSliderValue,
                          max: 30.toDouble(),
                          divisions: ultimoNivelDisponible,
                          label: _currentSliderValue.round() != 0
                              ? "${_currentSliderValue.round()}"
                              : "Reglas",
                          onChanged: (double value) {
                            if(value <=  nivelesUniversos[universo]){
                              widget.onLevelChanged(value);
                              setState(() {
                                _currentSliderValue = value;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            //String name = _nameController.text.trim();
                            /*if(name.isEmpty){
                              setState(() {
                                nombreVacio = true;
                              });
                            }*/
                            if(_currentSliderValue.round() == 0){
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
                                  cambieUniverso = true;
                                });
                              },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
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
                            if(nivelesUniversos[universo+1] > 0)
                              ElevatedButton(onPressed: (){
                                setState(() {
                                  universo++;
                                  cambieUniverso = true;
                                  widget.onUniverseChanged(universo);
                                });
                              },style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.7),
                                elevation: 0,
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
                      Navigator.of(context).pop();
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
  final Color? actualColor;
  ColorSelector({required this.onColorsSelected, required this.actualColor});

  @override
  _ColorSelectorState createState() => _ColorSelectorState( J1SelectedColor: actualColor);
}

class _ColorSelectorState extends State<ColorSelector> {

  _ColorSelectorState({required this.J1SelectedColor});

  Color? J1SelectedColor;
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];


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
                          J1SelectedColor = color;
                          //context.read<MyState>().cambiarColor(color);
                          widget.onColorsSelected(J1SelectedColor);
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: J1SelectedColor == color ? Colors.black : Colors.transparent,
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
