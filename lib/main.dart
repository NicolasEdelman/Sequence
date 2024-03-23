import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/EntradaSplashScreen.dart';
import 'package:myapp/SplashScreenCargaNivel.dart';
import 'package:provider/provider.dart';
import 'Tablero.dart';
import 'PaginaInicio.dart';
import 'myAppState.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: EntradaSplashScreen(),

      ),
    );
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

  var selectedIndex = 0;
  bool isPlaying = false;
  Color? J1selectedColor = Colors.blue;
  double nivelActual = 1;
  int ultimoNivelDesbloqueado = 1;
  int universoActual = 1;
  int ultimoUniversoDisponible = 1;
  List<int> nivelesUniversos = [0, 1, 0, 0, 0];


  @override
  void initState(){
    super.initState();
    ultimoNivelDesbloqueado = nivelesUniversos[universoActual];
    //initSharedPreferences();
  }
  /*Future<void> initSharedPreferences() async {
    await leerDatos();
  }

  Future<void> leerDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.remove('ultimoNivelDesbloqueado'); // Para resetear lo que hay en la variable en Disco
    setState(() {
      ultimoNivelDesbloqueado = prefs.getInt('ultimoNivelDesbloqueado') ?? 1;
    });
  }*/

  /*void cargarDatos() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ultimoNivelDesbloqueado', ultimoNivelDesbloqueado);
    //await prefs.setInt("ultimoNivelDesbloqueado", ultimoNivelDesbloqueado);
    int nuevoNivel = prefs.getInt('ultimoNivelDesbloqueado') ?? 1;
    setState(() {
      ultimoNivelDesbloqueado = nuevoNivel;
    });
  }*/
  void handleLevelChanged(double nuevoNivel){
    setState(() {
      nivelActual = nuevoNivel;
    });

  }
  void handleUniverseChanged(int nuevoUniverso){
    print("Cambiando de universo perriiii");
    setState(() {
      universoActual = nuevoUniverso;
      ultimoNivelDesbloqueado = nivelesUniversos[universoActual];
      nivelActual = 1;
    });
  }

  void handleMatchFinished(Resultado resultado) async{
    print("El nivel que acaba de terminar es: ${resultado.nivel}");
    setState(() {
      if(resultado.ganador == 1 && resultado.nivel%30 == 0){
        print("Podes pasar al proximo universo!");
        terminasteElJuego();
      }
      else if(resultado.ganador == 1 && nivelActual == nivelesUniversos[universoActual]){
        setState(() {
          nivelesUniversos[universoActual]++;
          ultimoNivelDesbloqueado++;
        });
        print("Desbloqueaste el nivel: ${nivelesUniversos[universoActual]} del universo: $universoActual");
      }
      //cargarDatos();
    });
  }

  void handleSiguienteNivel(int siguienteNiv){
    if(siguienteNiv > 90){
      terminasteElJuego();
      print("Te diste vuelta el juego");
    }
    else if(siguienteNiv == 31 || siguienteNiv == 61){
      terminasteElJuego();
    }
    else{
      setState(() {
        nivelActual = siguienteNiv.toDouble();
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
                  isPlaying = false;
                  selectedIndex = 0;
                  //selectedSequence = 1;
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
      if(universoActual == ultimoUniversoDisponible && universoActual <3){
        ultimoUniversoDisponible++;
        nivelesUniversos[ultimoUniversoDisponible]++;
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
                        isPlaying = false;
                        selectedIndex = 0;
                        if(universoActual<3){
                          universoActual++;
                          nivelActual = 1;
                          ultimoNivelDesbloqueado = nivelesUniversos[universoActual];
                        }
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
    return ChangeNotifierProvider(
      create: (_) => MyState(),
      child: Consumer<MyState>(
        builder: (context, myState, _) {
          String titlebar = "";
          Widget page;
          switch (selectedIndex) {
            case 0:
              print("ultimoNivelDesbloqueado: ${ultimoNivelDesbloqueado}, universoActual: ${universoActual}, nivelActual: ${nivelActual}");
              titlebar = "";
              isPlaying = false;
              page =  GeneratorPage(
                onStartGame: startGame,
                onLevelChanged: handleLevelChanged,
                onUniverseChanged: handleUniverseChanged,
                mainColor: myState.J1selectedColor!,
                universo: universoActual,
                ultimoUniversoDesbloqueado: ultimoUniversoDisponible,
                ultimoNivelDesbloqueado: ultimoNivelDesbloqueado,
                nivelesUniversos: nivelesUniversos,
              );
              break;
            case 1:
              titlebar = "Nivel ${nivelActual.toInt()} - Universo ${universoActual}";
              isPlaying = true;
              page = TableroPage(
                J1selectedColor: myState.J1selectedColor!,
                J2selectedColor: Colors.white,
                name: myState.name,
                level: nivelActual.toDouble(),
                universo: universoActual,
                onMatchFinished: handleMatchFinished,
                siguienteNivel: handleSiguienteNivel,
              );
              break;
            case 2:
              int cantSecuencias = 2;
              if (universoActual == 1 || universoActual == 3) cantSecuencias = 1;
              titlebar = "Nivel ${nivelActual.toInt()} - Universo ${universoActual}";
              isPlaying = false;
              page = SplashScreen(
                nivel: nivelActual.toInt(),
                cantidadSequencias: cantSecuencias,
                j1Color: myState.J1selectedColor!,
                universo: universoActual,
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
              backgroundColor: myState.J1selectedColor ?? Colors.blue,
              toolbarHeight: 50,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    child: page,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}







