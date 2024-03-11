import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'Tablero.dart';
import 'PaginaInicio.dart';

void main() {
  var appState = MyAppState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
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
      home: const MyHomePage(title: "", subtitle: 'Hola verano',),

    );
  }
}

class MyAppState extends ChangeNotifier{
  Color? J1selectedColor;
  Color? J2selectedColor;
  int selectedSequence = 1;
  String name = '';
  double? nivel = 1;

  void updatePlayerInfo(String playerName, double level){
    name = playerName;
    nivel = level;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _dynamicTitle = '';
  var selectedIndex = 0;
  bool isPlaying = false;
  Color? J1selectedColor = Colors.blue;
  Color? J2selectedColor = Colors.green;
  int selectedSequence = 1;
  String name = '';
  double nivel = 1;
  MyAppState? appState;

  @override
  void initState(){
    super.initState();
    _dynamicTitle = widget.title;
  }

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
  void handleLevelChanged(double nuevoNivel){
    setState(() {
      nivel = nuevoNivel;
    });
  }

  void handleMatchFinished(Resultado resultado){
    print("Termino el partido y el ganador fue el jugador  ${resultado.ganador}");
  }

  void handleSiguienteNivel(int siguienteNiv){
    print("Yendo al nivel $siguienteNiv");
    setState(() {
      nivel = siguienteNiv.toDouble();
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
                  _dynamicTitle = widget.title;
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

  @override
  Widget build(BuildContext context) {
    String titlebar = "";
    Widget page;
    switch (selectedIndex){
      case 0:
        titlebar = "";
        page = GeneratorPage(
          onStartGame: startGame,
          onNameChanged: handleNameChanged,
          onColorChanged: handleColorChanged,
          onCantSequencesChanged: handleCantSequencesChanged,
          onLevelChanged: handleLevelChanged,
        );
        break;
      case 1:
        titlebar = "${name} - Nivel ${nivel.toInt()}";
        page = TableroPage(
          J1selectedColor: J1selectedColor,
          J2selectedColor: J2selectedColor,
          selectedSequence: selectedSequence,
          name: name,
          level: nivel,
          onMatchFinished: handleMatchFinished,
          siguienteNivel: handleSiguienteNivel,
        );
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(titlebar),
        leading: isPlaying
            ? IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Salir del juego',
          onPressed: exitGame,
        )
            : IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Menú',
          onPressed: null,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: 'Ayuda',
            onPressed: panelReglas,
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(child: Container(child: page,)),
        ]
        ),
    );
  }

}







