import 'dart:async';
import 'package:flutter/material.dart';
import 'Mazo.dart';
import 'cartaTablero.dart';

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

  const TableroPage({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.selectedSequence,
    required this.name,
  });

  @override
  State<TableroPage> createState() => _TableroPageState(
    J1selectedColor: J1selectedColor,
    J2selectedColor: J2selectedColor,
    selectedSequence: selectedSequence,
    name: name,
  );

}

class _TableroPageState extends State<TableroPage> {

  Color? J1selectedColor;
  Color? J2selectedColor;
  int selectedSequence;
  String name;

  Completer<void> _completer = Completer<void>();
  late List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  var mazo =  Mazo();
  List<Carta> cartasEnManoMia = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  Carta cartaPresionada = Carta("0", '');
  int poscartaPresionada =0;
  List<Carta> cartasEnManoOponente = [];
  List<int> puntajes = [0, 0];
  bool enJuego = false;
  bool miTurno = false;
  Carta cartaSeleccionadaTablero = Carta("-1", '');
  int filaCartaSeleccionadaTablero = 0;
  int columnaCartaSeleccionadaTablero = 0;
  String estado = "";
  Carta ultimaCartaTirada = Carta("0", "");

  _TableroPageState({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.selectedSequence,
    required this.name,}) {
    matriz = construirTablero();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("$name vs la maquina"),
        Text("Se juega a $selectedSequence sequences"),
        Padding(padding: EdgeInsets.only(top: 70),),
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
        if(!enJuego) ElevatedButton(onPressed: jugar, child: Text("Start")),
        if(miTurno) Text("Es tu turno!"),
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
    setState(() {
      mazo = Mazo();
      estado = "Empezo el juego!";
    });
    print("Empezo el juegooo");
    enJuego = true;
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
        await turnoJugador2();
        if(revisarGanador(2, selectedSequence)){
          setState(() {
            enJuego = false;
            estado = "PERDISTEEE";
          });
        }
      }
    }
  }

  Future<void>  turnoJugador1() async{

    setState(() {
      cartaPresionada = Carta("0", "");
      cartaSeleccionadaTablero = Carta("-1", "");
      miTurno = true;
    });

    print("Es mi turno y estoy esperando que aprete una carta...");

    while(cartaPresionada.numero == "0" ){
      await Future.delayed(Duration(milliseconds: 100));
    }
    if((cartaPresionada.numero != "Wild" && cartaPresionada.numero != "Remove") && tengoDeadCard(cartaPresionada)){
      setState(() {
        for(int i = poscartaPresionada; i <6; i++){
          cartasEnManoMia[i] = cartasEnManoMia[i+1];
        }
        cartasEnManoMia[6] = mazo.darPrimerCarta();
        estado = "¡Dead card!";
        print("Dead card!");
      });
    }
    while (cartaPresionada.numero != cartaSeleccionadaTablero.numero ||
        cartaPresionada.palo != cartaSeleccionadaTablero.palo) {
      await Future.delayed(Duration(milliseconds: 100)); // Esperar un breve tiempo antes de revisar de nuevo
      if(cartaSeleccionadaTablero.numero != "-1"){
        if(cartaPresionada.numero == "Wild"){

          if(matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero].fichaPuesta != 0){
            setState(() {
              estado = "El Wild se debe tirar en una posición vacía!";
            });
            return turnoJugador1();
          }
          else {
            break;
          }
        }
        else if(cartaPresionada.numero == "Remove"){

          if(matriz[filaCartaSeleccionadaTablero][columnaCartaSeleccionadaTablero].fichaPuesta == 0){
            setState(() {
              estado = "Tenes que quitar una ficha!";
            });
            return turnoJugador1();
          }
          else {
            break;
          }
        }
        else{

        }
      }

    }
    tirarCarta();
  }

  void tirarCarta(){
    print("$name, apoyaste el ${cartaSeleccionadaTablero.numero} de ${cartaSeleccionadaTablero.palo} en el tablero que esta en la fila ${filaCartaSeleccionadaTablero} y columna ${columnaCartaSeleccionadaTablero}");

    setState(() {
      miTurno = false;
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

  Future<void> turnoJugador2() async{
    await Future.delayed(Duration(milliseconds: 1000));
    String numeroCarta = cartasEnManoOponente[0].numero;
    String paloCarta = cartasEnManoOponente[0].palo;
    bool deadCard = true;
    bool puseCarta = false;
    for (int i=0; i<10; i++){
      for (int j=0; j<10; j++){
        if(!puseCarta){
          if(matriz[i][j].fichaPuesta == 0){
            if(matriz[i][j].numeroCarta == numeroCarta && matriz[i][j].palo == paloCarta){
              for(int i = 0; i <6; i++){
                cartasEnManoOponente[i] = cartasEnManoOponente[i+1];
              }
              deadCard = false;
              puseCarta = true;
              setState(() {
                matriz[i][j] = Triplet(2, numeroCarta.toString(), paloCarta);
                ultimaCartaTirada = Carta(numeroCarta, paloCarta);
                cartasEnManoOponente[6] = mazo.darPrimerCarta();
                estado = "Tu oponente tiró el ${numeroCarta} de ${paloCarta}";
              });
            }
          }
        }
      }
    }
    if(deadCard){
      for(int i = 0; i <5; i++){
        cartasEnManoOponente[i] = cartasEnManoOponente[i+1];
      }
      turnoJugador2();
    }
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
      if(jugador == 2){cartasEnManoOponente.add(mazo.darPrimerCarta());}
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
    IconData? icono;
    Color colorIcono;
    Color? colorCelda;
    double sizeNumber;
    double sizeIcon;
    double scaleFactor = 1.0;

    switch(carta.palo){
      case "Picas":
        icono = Icons.spa;
        colorIcono = Colors.black;
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        sizeIcon = 20;
        break;
      case "Trebol":
        icono = Icons.grass;
        colorIcono = Colors.black;
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        sizeIcon = 20;
        break;
      case "Corazon":
        icono = Icons.favorite;
        colorIcono = Colors.red;
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        sizeIcon = 20;
        break;
      case "Diamante":
        icono = Icons.diamond;
        colorIcono = Colors.red;
        colorCelda = Colors.grey[300];
        sizeNumber = 20;
        sizeIcon = 20;
        break;
      default:
        icono = Icons.ac_unit;
        colorIcono = Colors.black;
        colorCelda = Colors.blue;
        sizeNumber = 0;
        sizeIcon = 20;
        break;
    }
    if(carta.numero == "Wild" || carta.numero == "Remove"){
      sizeNumber = 12;
    }
    if(cartaPresionada == carta){
      scaleFactor = 1.3;
      colorCelda = Colors.grey[400];
    }
    return GestureDetector(
      onTap: (){
        if(miTurno){
          setState(() {
            cartaPresionada = carta;
            poscartaPresionada = index;
          });
          if(!_completer.isCompleted){
            _completer.complete();
          }
        }
      },
      child: Container(
        width: 55*scaleFactor,
        height: 50*scaleFactor,
        color: colorCelda,
        margin: EdgeInsets.all(2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(carta.numero, style: TextStyle(fontSize: sizeNumber*scaleFactor),), // Mostrar el entero de la matriz
              Icon(icono,  color: colorIcono, size: sizeIcon*scaleFactor,), // Mostrar el palo
            ],
          ),
        ),
      ),
    );
  }
}





