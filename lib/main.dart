import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/EntradaSplashScreen.dart';
import 'package:myapp/SplashScreenCargaNivel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: EntradaSplashScreen(),

    );
  }
}

class MyAppState extends ChangeNotifier{
  Color? J1selectedColor;
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
  int selectedSequence = 1;
  String name = '';
  double nivel = 1;
  MyAppState? appState;
  int ultimoNivelDesbloqueado = 30;
  int ultimoNivelDisponible = 30;
  int universoActual = 1;
  int ultimoUniversoDisponible = 1;


  @override
  void initState(){
    super.initState();
    _dynamicTitle = widget.title;
    //initSharedPreferences();
  }
  Future<void> initSharedPreferences() async {
    await leerDatos();
  }

  Future<void> leerDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('ultimoNivelDesbloqueado'); // Para resetear lo que hay en la variable en Disco
    setState(() {
      ultimoNivelDesbloqueado = prefs.getInt('ultimoNivelDesbloqueado') ?? 1;
    });
  }

  void cargarDatos() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ultimoNivelDesbloqueado', ultimoNivelDesbloqueado);
    //await prefs.setInt("ultimoNivelDesbloqueado", ultimoNivelDesbloqueado);
    int nuevoNivel = prefs.getInt('ultimoNivelDesbloqueado') ?? 1;
    setState(() {
      ultimoNivelDesbloqueado = nuevoNivel;
    });


  }

  void handleNameChanged(String newName) {
    setState(() {
      name = newName;
    });
  }
  void handleColorChanged(Color? color1){
    setState(() {
      J1selectedColor = color1;
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
  void handleUniverseChanged(int nuevoUniverso){
    setState(() {
      universoActual = nuevoUniverso;
    });
  }

  void handleMatchFinished(Resultado resultado) async{
    print("Termino el partido y el ganador fue el jugador  ${resultado.ganador}");
    setState(() {
      if(resultado.ganador == 1 && resultado.nivel == ultimoNivelDesbloqueado){
        ultimoNivelDesbloqueado++;
      }
      //cargarDatos();
    });
  }

  void handleSiguienteNivel(int siguienteNiv){
    if(siguienteNiv > ultimoNivelDisponible){
      terminasteElJuego();
    }
    else{
      setState(() {
        nivel = siguienteNiv.toDouble();
        startGame();
      });
    }
  }

  void startGame() {
      setState(() {
        selectedIndex = 2;
      });
      Future.delayed(Duration(seconds: 3), (){
        setState(() {
          isPlaying = true;
          selectedIndex = 1;
        });
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
                  selectedSequence = 1;
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

  void terminasteElJuego(){
    setState(() {
      if(universoActual == ultimoUniversoDisponible){
        ultimoUniversoDisponible++;
      }
    });
    String completadoPath = "";
    String texto = "";
    switch (universoActual){
      case 1:
        completadoPath = "assets/images/Completado1.png";
        texto = "¡Viajar al proximo universo!";
      case 2:
        completadoPath = "assets/images/Completado2.png";
        texto = "¡Viajar al proximo universo!";
      case 3:
        completadoPath = "assets/images/Completado3.png";
        texto = "¡Completaste el juego!";

    }
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
                  Image.asset(completadoPath),
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
                      setState(() {
                        _dynamicTitle = widget.title;
                        isPlaying = false;
                        selectedIndex = 0;
                        selectedSequence = 1;
                        if(universoActual<3)universoActual++;
                      });// Cierra el cuadro de diálogo
                    },
                    child: Text(texto),
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
        setState(() {
          isPlaying = false;
        });
        page = GeneratorPage(
          onStartGame: startGame,
          onNameChanged: handleNameChanged,
          onColorChanged: handleColorChanged,
          onCantSequencesChanged: handleCantSequencesChanged,
          onLevelChanged: handleLevelChanged,
          onUniverseChanged: handleUniverseChanged,
          mainColor: J1selectedColor!,
          ultimoNivelDesbloqueado: ultimoNivelDesbloqueado,
          universo: universoActual,
          ultimoUniversoDesbloqueado: ultimoUniversoDisponible,
        );
        break;
      case 1:
        titlebar = "${name} - Nivel ${nivel.toInt()}";
        setState(() {
          isPlaying = true;
        });
        page = TableroPage(
          J1selectedColor: J1selectedColor,
          J2selectedColor: Colors.white,
          name: name,
          level: nivel,
          universo: universoActual,
          onMatchFinished: handleMatchFinished,
          siguienteNivel: handleSiguienteNivel,
        );
        break;
      case 2:
        titlebar = "${name} - Nivel ${nivel.toInt()}";
        setState(() {
          isPlaying = false;
        });
        page = SplashScreen(
          nivel: nivel.toInt(),
          cantidadSequencias: selectedSequence,
          j1Color: J1selectedColor,

        );
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
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: J1selectedColor,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          Expanded(child: Container(child: page,)),
        ]
        ),
    );
  }
}







