import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'Mazo.dart';
import 'cartaTablero.dart';
import 'Oponente.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Tablero')),
        //body: TableroPage(),
      ),
    ),
  );
}

class TableroPage extends StatefulWidget {
  final Color? J1selectedColor;
  final Color? J2selectedColor;
  final int selectedSequence;
  final String name;
  final double level;

  const TableroPage({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.selectedSequence,
    required this.name,
    required this.level,
  });

  @override
  State<TableroPage> createState() => _TableroPageState(
    J1selectedColor: J1selectedColor,
    J2selectedColor: J2selectedColor,
    selectedSequence: selectedSequence,
    name: name,
    level: level,
  );

}

class _TableroPageState extends State<TableroPage> {

  Color? J1selectedColor;
  Color? J2selectedColor;
  int selectedSequence;
  String name;
  double level = 1;

  Completer<void> _completer = Completer<void>();
  late List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  var mazo =  Mazo();
  List<Carta> cartasEnManoMia = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  List<Carta> cartasEnManoOponente = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  Carta cartaPresionada = Carta("0", '');
  int poscartaPresionada =0;

  List<int> puntajes = [0, 0];
  bool enJuego = false;
  bool miTurno = false;
  Carta cartaSeleccionadaTablero = Carta("-1", '');
  int filaCartaSeleccionadaTablero = 0;
  int columnaCartaSeleccionadaTablero = 0;
  String estado = "";
  Carta ultimaCartaTirada = Carta("0", "");
  StreamController<int> _timerController = StreamController<int>();


  _TableroPageState({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.selectedSequence,
    required this.name,
    required this.level}) {
    matriz = construirTablero();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Fondo1.png"),
            fit: BoxFit.cover,
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(top: 10),),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  Carta carta = cartasEnManoOponente[index];
                  //return cartaMano(carta: Carta("", ""), index: index, miTurno: miTurno);
                  return cartaMano(carta: carta, index: index, miTurno: miTurno);
                },
              ),
            ),

            Text("Se juega a $selectedSequence sequences"),
            Padding(padding: EdgeInsets.only(top: 10),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                cartaMano(carta: Carta("0", ""), index: -1, miTurno: miTurno),
                cartaMano(carta: ultimaCartaTirada, index: -1, miTurno: miTurno),
              ],
            ),

            Padding(padding: EdgeInsets.only(top: 5),),
            Expanded(
                child:GridView.builder(
                  itemCount: 10 * 10, // Total de celdas en el tablero
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 10, // Número de columnas en el tablero
                  ),
                  itemBuilder: (context, index) {
                    // Calcular la fila y la columna para este índice
                    int fila = index ~/ 10;
                    int columna = index % 10;

                    // Obtener el par correspondiente en la matriz combinada
                    Triplet triplet = matriz[fila][columna];

                    // Construir el widget de la celda
                    return CartaTablero(triplet: triplet, J1Color: J1selectedColor, J2Color: J2selectedColor, onTap: (Carta carta){
                      setState(() {
                        cartaSeleccionadaTablero = carta;
                        filaCartaSeleccionadaTablero = fila;
                        columnaCartaSeleccionadaTablero = columna;
                      });
                    },);
                  },
                )
            ),
            if(estado != "") Text(estado),
            SizedBox(height: 10),
            if(!enJuego) ElevatedButton(onPressed: jugar, child: Text("Start")),
            if(miTurno)Text("Es tu turno!"),

            StreamBuilder<int>(
              stream: _timerController.stream,
              initialData: -1 ,// Establece el valor inicial del temporizador
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.data == 0) {
                  return Text('Tiempo agotado');
                }
                else if(snapshot.data == -1){
                  return Text("");
                }
                else {
                  return Text('Te quedan ${snapshot.data} segundos');
                }
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 70),
              child: Center(
                  child:
                  Container(
                    height: 90,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index){
                          Carta carta = cartasEnManoMia[index];
                          return Draggable(
                            childWhenDragging: Container(),
                            feedback: cartaMano(carta: carta, index: index, miTurno: miTurno),
                            onDragStarted: () {
                              setState(() {
                                cartaPresionada = carta;
                                poscartaPresionada = index;
                              });
                            },
                            // Cuando termina de arrastrar
                            onDragEnd: (details) {
                              setState(() {
                                cartasEnManoMia.removeAt(poscartaPresionada); // Removemos la carta de su posición original
                                cartasEnManoMia.insert(6, cartaPresionada); // La insertamos en la nueva posición
                                cartaPresionada = Carta("0", ""); // Reiniciamos la carta presionada
                              });
                            },
                            child: cartaMano(carta: carta, index: index, miTurno: miTurno),
                          );

                          //return cartaMano(carta: carta, index: index, miTurno: miTurno);
                        }),
                  )
              ),),
          ],
        ),
      ),
    );

  }

  void actualizarOrdenCartas(int index) {
    setState(() {
      cartasEnManoMia.insert(poscartaPresionada, cartaPresionada);
      if (poscartaPresionada < index) {
        cartasEnManoMia.removeAt(index + 1);
      } else {
        cartasEnManoMia.removeAt(index);
      }
    });
  }

  void jugar() async{
    construirTablero();
    int nivelOponente = level.toInt();
    Oponente oponente = Oponente(nivelOponente);
    setState(() {
      mazo = Mazo();
      estado = "Empezo el juego!";
      enJuego = true;
      cartasEnManoOponente = [];
      ultimaCartaTirada = Carta("", "");
      level = oponente.tiempoTurnoUsuario.toDouble();
    });
    repartirCartas();
    while(enJuego){
      await turnoJugador1();
      if(revisarGanador(1, selectedSequence)){
        setState(() {
          enJuego = false;
          estado = "GANASTEEEE";
        });
      }
      else{
        await turnoJugador2(oponente);
        if(revisarGanador(2, selectedSequence)){
          setState(() {
            enJuego = false;
            estado = "PERDISTEEE";
          });
        }
      }
    }
  }

  Future<void> turnoJugador1() async {
    miTurno = true;
    int tiempoRestante = level.toInt(); // Establece el tiempo inicial
    _timerController.add(tiempoRestante); // Emite el valor inicial
    Timer timerTurn = Timer.periodic(Duration(seconds: 1), (timerTurn) {
      setState(() {
        if(tiempoRestante > 0){
          tiempoRestante --;
          _timerController.add(tiempoRestante);
        }
        else{
          miTurno = false;
          _timerController.add(0);
          timerTurn.cancel();
        }
      });
    });

    setState(() {
      cartaPresionada = Carta("0", "");
      cartaSeleccionadaTablero = Carta("-1", "");
      miTurno = true;
    });

    //print("Es mi turno y estoy esperando que aprete una carta...");

    while (cartaPresionada.numero == "0") {
      await Future.delayed(Duration(milliseconds: 100));
      if(!miTurno){
        setState(() {
          estado = "Perdiste tu turno!";
        });
        timerTurn.cancel();
        return;
      }
    }

    if ((cartaPresionada.numero != "Wild" && cartaPresionada.numero != "Remove") &&
        tengoDeadCard(cartaPresionada)) {
      setState(() {
        for (int i = poscartaPresionada; i < 6; i++) {
          cartasEnManoMia[i] = cartasEnManoMia[i + 1];
        }
        cartasEnManoMia[6] = mazo.darPrimerCarta();
        estado = "¡Dead card!";
      });
    }
    cartaSeleccionadaTablero = Carta("-1", "");
    while (cartaPresionada.numero != cartaSeleccionadaTablero.numero ||
        cartaPresionada.palo != cartaSeleccionadaTablero.palo) {
      await Future.delayed(Duration(milliseconds: 100));
      if(!miTurno){
        setState(() {
          estado = "Perdiste tu turno!";
        });
        timerTurn.cancel();
        return;
      }
      if (cartaSeleccionadaTablero.numero != "-1") {
        if (cartaPresionada.numero == "Wild") {
          if (matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero].fichaPuesta != 0) {
            setState(() {
              estado = "El Wild se debe tirar en una posición vacía!";
            });
            return turnoJugador1();
          } else {
            break;
          }
        } else if (cartaPresionada.numero == "Remove") {
          if (matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero].fichaPuesta == 0) {
            setState(() {
              estado = "Tenes que quitar una ficha!";
            });
            return turnoJugador1();
          } else {
            break;
          }
        }
      }
    }
    tirarCarta();
    timerTurn.cancel();
    setState(() {
      _timerController.add(-1);
    });

  }






  void tirarCarta(){
    //print("$name, apoyaste el ${cartaSeleccionadaTablero.numero} de ${cartaSeleccionadaTablero.palo} en el tablero que esta en la fila ${filaCartaSeleccionadaTablero} y columna ${columnaCartaSeleccionadaTablero}");

    setState(() {
      miTurno = false;
      ultimaCartaTirada = Carta(cartaPresionada.numero, cartaPresionada.palo);
      if(cartaPresionada.numero == "Remove")
        matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero] = Triplet(0, cartaSeleccionadaTablero.numero.toString(), cartaSeleccionadaTablero.palo);
      else{matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero] = Triplet(1, cartaSeleccionadaTablero.numero.toString(), cartaSeleccionadaTablero.palo);}
      for(int i = poscartaPresionada; i <6; i++){
        cartasEnManoMia[i] = cartasEnManoMia[i+1];
      }
      cartasEnManoMia[6] = mazo.darPrimerCarta();
      estado = "$name tiró el ${cartaPresionada.numero} de ${cartaPresionada.palo}";
      ultimaCartaTirada = cartaPresionada;
    });
  }

  Future<void> turnoJugador2(Oponente oponente) async{
    await Future.delayed(Duration(milliseconds: 2000));
    oponente.ActualizarMatriz(matriz);
    for (Carta carta in cartasEnManoOponente){
      if(tengoDeadCard(carta) && carta.numero != "Wild" && carta.numero != "Remove"){
        cartasEnManoOponente.remove(carta);
        entregarCarta(2);
      }
    }
    oponente.ActualizarCartas(cartasEnManoOponente);
    print("Tengo ${oponente.cartasEnMano.length} cartas en mano");
    var retorno = oponente.tirarCarta();
    setState(() {
      matriz = retorno.tablero;
      ultimaCartaTirada = retorno.carta;
      estado = "";
    });
    entregarCarta(2);
  }


  bool tengoDeadCard(Carta carta){
    for (int i=0; i<10; i++){
      for (int j=0; j<10; j++){
        if(matriz[i][j].numeroCarta == carta.numero && matriz[i][j].palo == carta.palo && matriz[i][j].fichaPuesta == 0){
          return false;
        }
      }
    }
    return true;
  }

  void entregarCarta(int jugador){
    setState(() {
      if(jugador == 1){
        cartasEnManoMia.add(mazo.darPrimerCarta());
      }
      if(jugador == 2){
        cartasEnManoOponente.add(mazo.darPrimerCarta());
      }
    });
  }

  void repartirCartas(){
    setState(() {
      mazo.mezclarMazo();
      cartasEnManoMia = [];
    });
    for (int i=0; i<=6; i++){
      entregarCarta(1);
      entregarCarta(2);
    }
    print("Se teriminaron de repartir las cartas");
  }



  bool revisarGanador(int ficha, int sequences) {
    List<List<bool>> visitado = List.generate(10, (_) => List<bool>.filled(10, false));
    int cantidad = 0;

    // Revisar filas
    int celdasVisitadas = 0;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j <= 5; j++) {
        bool posibleganador = true;
        for (int k = 0; k < 5; k++) {
          if (matriz[i][j + k].fichaPuesta != ficha && matriz[i][j + k].fichaPuesta != -2) {
            posibleganador = false;
            break;
          }
        }
        if (posibleganador) {
          for (int k = 0; k < 5; k++) {
            if(visitado[i][j+k] == true){celdasVisitadas++;}
          }
          if(celdasVisitadas > 1) break;
          else{
            for (int k = 0; k < 5; k++) {
              visitado[i][j+k] = true;
            }
          }
          cantidad++;
        }
      }
    }
    // Revisar columnas
    celdasVisitadas = 0;
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j <= 5; j++) {
        bool posibleganador = true;
        for (int k = 0; k < 5; k++) {
          if (matriz[j + k][i].fichaPuesta != ficha && matriz[j + k][i].fichaPuesta != -2) {
            posibleganador = false;
            break;
          }
        }
        if (posibleganador) {
          for (int k=0; k< 5; k++){
            if(visitado[j+k][i] == true) celdasVisitadas++;
          }
          if(celdasVisitadas > 1) break;
          else{
            for(int k=0; k<5; k++){
              visitado[j+k][i] == true;
            }
          }
         cantidad++;
        }
      }
    }

    // Revisar diagonales principales (\)
    celdasVisitadas = 0;
    for (int i = 0; i <= 5; i++) {
      for (int j = 0; j <= 5; j++) {
        bool posibleganador = true;
        for (int k = 0; k < 5; k++) {
          if (matriz[i + k][j + k].fichaPuesta != ficha && matriz[i + k][j + k].fichaPuesta != -2) {
            posibleganador = false;
            break;
          }
        }
        if (posibleganador) {
          for (int k = 0; k < 5; k++){
            if(visitado[i+k][j+k] == true) celdasVisitadas++;
          }
          if(celdasVisitadas>1)break;
          else{
            for (int k = 0; k < 5; k++){
              visitado[i+k][j+k] = true;
            }
          }
          cantidad++;
        }
      }
    }

    // Revisar diagonales secundarias (/)
    celdasVisitadas = 0;
    for (int i = 0; i <= 5; i++) {
      for (int j = 4; j < 10; j++) {
        bool posibleganador = true;
        for (int k = 0; k < 5; k++) {
          if (matriz[i + k][j - k].fichaPuesta != ficha && matriz[i + k][j - k].fichaPuesta != -2) {
            posibleganador = false;
            break;
          }
        }
        if (posibleganador) {
          for (int k = 0; k < 5; k++){
            if(visitado[i+k][j-k] == true) celdasVisitadas++;
          }
          if(celdasVisitadas>1)break;
          else{
            for (int k = 0; k < 5; k++)
              visitado[i+k][j-k] = true;
          }
          cantidad++;
        }
      }
    }
    if(cantidad >= sequences) return true;
    else return false;
  }






  List<List<Triplet>> construirTablero() {
    List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
    matriz[0] = [
      Triplet(-2, "0", "Joker"), // Joker
      for (int i = 2; i <= 9; i++) Triplet(0, i.toString(), "Picas"), // picas
      Triplet(-2, "0", "Joker"), // Joker
    ];
    matriz[1] = [
      for (int i = 6; i >= 2; i--) Triplet(0,i.toString(), "Trebol"),
      Triplet(0, "A", "Corazon"),
      Triplet(0, "K", "Corazon"),
      Triplet(0, "Q", "Corazon"),
      Triplet(0, "10", "Corazon"),
      Triplet(0, "10", "Picas"),
    ];
    matriz[2] = [
      Triplet(0, "7", "Trebol"),
      Triplet(0, "A", "Picas"),
      for (int i = 2; i <= 7; i++) Triplet(0,i.toString(), "Diamante"),
      Triplet(0, "9", "Corazon"),
      Triplet(0, "Q", "Picas")
    ];
    matriz[3] = [
      Triplet(0, "8", "Trebol"),
      Triplet(0, "K", "Picas"),
      for (int i = 6; i >= 2; i--) Triplet(0,i.toString(), "Trebol"),
      Triplet(0, "8", "Diamante"),
      Triplet(0, "8", "Corazon"),
      Triplet(0, "K", "Picas"),
    ];
    matriz[4] = [
      Triplet(0, "9", "Trebol"),
      Triplet(0, "Q", "Picas"),
      Triplet(0, "7", "Trebol"),
      Triplet(0, "6", "Corazon"),
      Triplet(0, "5", "Corazon"),
      Triplet(0, "4", "Corazon"),
      Triplet(0, "A", "Corazon"),
      Triplet(0, "9", "Diamante"),
      Triplet(0, "7", "Corazon"),
      Triplet(0, "A", "Picas"),
    ];
    matriz[5] = [
      Triplet(0, "10", "Trebol"),
      Triplet(0, "10", "Picas"),
      Triplet(0, "8", "Trebol"),
      Triplet(0, "7", "Corazon"),
      Triplet(0, "2", "Corazon"),
      Triplet(0, "3", "Corazon"),
      Triplet(0, "K", "Corazon"),
      Triplet(0, "10", "Diamante"),
      Triplet(0, "6", "Corazon"),
      Triplet(0, "2", "Diamante"),
    ];
    matriz[6] = [
      Triplet(0, "Q", "Trebol"),
      Triplet(0, "9", "Picas"),
      Triplet(0, "9", "Trebol"),
      Triplet(0, "8", "Corazon"),
      Triplet(0, "9", "Corazon"),
      Triplet(0, "10", "Corazon"),
      Triplet(0, "Q", "Corazon"),
      Triplet(0, "Q", "Diamante"),
      Triplet(0, "5", "Corazon"),
      Triplet(0, "3", "Diamante"),
    ];
    matriz[7] = [
      Triplet(0, "K", "Trebol"),
      Triplet(0, "8", "Picas"),
      Triplet(0, "10", "Trebol"),
      Triplet(0, "Q", "Trebol"),
      Triplet(0, "K", "Trebol"),
      Triplet(0, "A", "Trebol"),
      Triplet(0, "A", "Diamante"),
      Triplet(0, "K", "Diamante"),
      Triplet(0, "4", "Corazon"),
      Triplet(0, "4", "Diamante"),
    ];
    matriz[8] = [
      Triplet(0, "A", "Trebol"),
      for (int i = 7; i >= 2; i--) Triplet(0,i.toString(), "Picas"),
      Triplet(0, "2", "Corazon"),
      Triplet(0, "3", "Corazon"),
      Triplet(0, "5", "Diamante"),
    ];
    matriz[9] = [
      Triplet(-2, "0", "Joker"),
      Triplet(0, "A", "Diamante"),
      Triplet(0, "K", "Diamante"),
      Triplet(0, "Q", "Diamante"),
      for (int i = 10; i >= 6; i--) Triplet(0,i.toString(), "Diamante"),
      Triplet(-2,"0", "Joker"),
    ];
    return matriz;
  }


  Widget cartaMano({required Carta carta, required int index, required bool miTurno}) {
    Color? colorCelda;
    double sizeNumber;
    double scaleFactor = 1.0;
    String imagePath = "";

    switch(carta.palo){
      case "Picas":
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        imagePath = "assets/images/Picas.png";
        break;
      case "Trebol":
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        imagePath = "assets/images/Trebol.png";
        break;
      case "Corazon":
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        imagePath = "assets/images/Corazon.png";
        break;
      case "Diamante":
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        imagePath = "assets/images/Diamante.png";
        break;
      default:
        colorCelda = J1selectedColor;
        sizeNumber = 0;
        imagePath = "assets/images/poker.png";
        break;
    }
    if(carta.numero == "Wild" || carta.numero == "Remove"){
      sizeNumber = 12;
    }
    if(cartaPresionada == carta && index != -1){
      scaleFactor = 1.3;
      colorCelda = Colors.grey[400];
    }
    if(index == -1){
      scaleFactor = 0.9;
    }
    return GestureDetector(
      onTap: (){
        if(miTurno && index != -1){
          setState(() {
            cartaPresionada = carta;
            poscartaPresionada = index;
          });
          if(!_completer.isCompleted){
            _completer.complete();
          }
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: J1selectedColor!, // Color del borde amarillo
            width: 0.5, // Grosor del borde
          ),
        ),
        child: Container(
          width: 55 * scaleFactor,
          height: 50 * scaleFactor,
          color: colorCelda,
          margin: EdgeInsets.all(2),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  carta.numero,
                  style: TextStyle(fontSize: sizeNumber * scaleFactor),
                ),
                Image.asset(
                  imagePath,
                  width: 20 * scaleFactor,
                  height: 20 * scaleFactor,
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}






