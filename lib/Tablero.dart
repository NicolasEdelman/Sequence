import 'dart:async';
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
  final String name;
  final double level;
  final int universo;
  final Function(Resultado) onMatchFinished;
  final Function(int) siguienteNivel;

  const TableroPage({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.name,
    required this.level,
    required this.universo,
    required this.onMatchFinished,
    required this.siguienteNivel,
  });

  @override
  State<TableroPage> createState() => _TableroPageState(
    J1selectedColor: J1selectedColor,
    J2selectedColor: J2selectedColor,
    name: name,
    level: level,
    universo: universo,
  );

}

class _TableroPageState extends State<TableroPage> {

  Color? J1selectedColor;
  Color? J2selectedColor;
  Color? J3selectedColor;
  String name;
  double level = 1;

  Completer<void> _completer = Completer<void>();
  late List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  var mazo =  Mazo();
  List<Carta> cartasEnManoMia = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  List<Carta> cartasEnManoOponente1 = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  List<Carta> cartasEnManoOponente2 = [Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),Carta("0",""),];
  Carta cartaPresionada = Carta("0", '');
  int poscartaPresionada =0;
  List<int> puntajes = [0, 0];
  bool empezoJuego = false;
  bool ganeJuego = false;
  bool perdiJuego = false;
  bool miTurno = false;
  Carta cartaSeleccionadaTablero = Carta("-1", '');
  int filaCartaSeleccionadaTablero = 0;
  int columnaCartaSeleccionadaTablero = 0;
  String estado = "";
  Carta ultimaCartaTirada = Carta("0", "");
  StreamController<int> _timerController = StreamController<int>();
  int nivelOponente = 0;
  int universo = 1;
  int cantSequences = 0;
  Oponente oponente = Oponente(0, null);
  int cantWilds = 0;
  List<List<CartaConPos>> sequences1 = [];
  List<List<CartaConPos>> sequences2 = [];
  List<List<CartaConPos>> sequences3 = [];

  _TableroPageState({
    required this.J1selectedColor,
    required this.J2selectedColor,
    required this.name,
    required this.level,
    required this.universo,}) {
    matriz = construirTablero(this.level.toInt());
  }

  @override
  Widget build(BuildContext context) {
    String fondoPath = "";
    Color? colorLetras;
    switch (universo){
      case 1:
        fondoPath = "assets/images/Fondo1.png";
        colorLetras = Colors.black;
        cantSequences = 1;
      case 2:
        fondoPath = "assets/images/FondoVerde.png";
        colorLetras = Colors.white;
        cantSequences = 2;
      case 3:
        fondoPath = "assets/images/FondoNegro.png";
        colorLetras = Colors.white;
        cantSequences = 1;
    }
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(fondoPath),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.only(top: 3),),
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      //Carta carta = cartasEnManoOponente1[index];
                      return cartaMano(carta: Carta("", ""), index: index, miTurno: miTurno);
                      //return cartaMano(carta: carta, index: index, miTurno: miTurno);
                    },
                  ),
                ),
                Text("Se juega a $cantSequences sequences", style: TextStyle(color: colorLetras),),
                Padding(padding: EdgeInsets.only(top: 5),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cartaMano(carta: Carta("0", ""), index: -1, miTurno: miTurno),
                    cartaMano(carta: ultimaCartaTirada, index: -1, miTurno: miTurno),
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 5),),
                Expanded(
                  child: GridView.builder(
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
                      return CartaTablero(columna: columna, fila: fila, triplet: triplet, J1Color: J1selectedColor, J2Color: J2selectedColor, J3Color: J3selectedColor, onTap: (Carta carta){
                        setState(() {
                          cartaSeleccionadaTablero = carta;
                          filaCartaSeleccionadaTablero = fila;
                          columnaCartaSeleccionadaTablero = columna;
                        });
                      },);
                    },
                  ),
                ),
                if(estado != "" && !ganeJuego && !perdiJuego) Text(estado, style: TextStyle(color: colorLetras)),
                SizedBox(height: 10),
                if(!empezoJuego) ElevatedButton(onPressed: jugarPrimeraVez, child: Text("Start")),
                if(ganeJuego) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: reiniciar, child: Text("Volver a intentar")),
                    SizedBox(width: 10,),
                    ElevatedButton(onPressed: avanzarDeNivel, child: Text("Siguiente nivel"))
                  ],
                ),
                if(perdiJuego) Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(onPressed: reiniciar, child: Text("Volver a intentar")),
                  ],
                ),
                if(miTurno) Text("Es tu turno!", style: TextStyle(color: colorLetras)),

                StreamBuilder<int>(
                  stream: _timerController.stream,
                  initialData: -1 ,// Establece el valor inicial del temporizador
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.data == 0) {
                      return Text('Tiempo agotado', style: TextStyle(color: colorLetras));
                    }
                    else if(snapshot.data == -1){
                      return Text("");
                    }
                    else {
                      return Text('Te quedan ${snapshot.data} segundos', style: TextStyle(color: colorLetras));
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
                          },
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
          if (ganeJuego)
            Center(
              child: Image.asset(
                "assets/images/Ganaste.png",
                fit: BoxFit.cover,
              ),
            ),
          if (perdiJuego)
            Center(
              child: Image.asset(
                "assets/images/Perdiste1.png",
                fit: BoxFit.cover,
              ),
            ),
        ],
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
  void avanzarDeNivel(){
    nivelOponente++;
    widget.siguienteNivel(nivelOponente);
    //jugar();
  }
  void reiniciar() {
    jugar();
  }
  void jugarPrimeraVez(){
    nivelOponente = level.toInt();
    jugar();
  }

  void jugar() async{
    oponente = Oponente(nivelOponente, J1selectedColor);
    int niv = oponente.Nivel;
    construirTablero(niv);
    print("Soy el oponente de nivel $niv");
    setState(() {
      mazo = Mazo();
      estado = "Empezo el juego!";
      empezoJuego = true;
      ganeJuego = false;
      perdiJuego = false;
      cartasEnManoOponente1 = [];
      cartasEnManoOponente2 = [];
      ultimaCartaTirada = Carta("", "");
      level = oponente.tiempoTurnoUsuario.toDouble();
      J2selectedColor = oponente.colorOponente1;
      J3selectedColor = oponente.colorOponente2;
      cantWilds = 0;
      sequences1 = [];
      sequences2 = [];
      sequences3 = [];
    });
    repartirCartas();
    while(!ganeJuego && !perdiJuego){
      await turnoJugador1();
      //await turnoJugador1Maquina(oponente);
      if(revisarGanador(1, cantSequences)){
        final completer = Completer<void>();
        MostrarGanador(sequences1, 1, completer);
        await completer.future;
        setState(() {
          ganeJuego = true;
          estado = "GANASTEEEE";
          Resultado resultado = Resultado(nivelOponente, 1, cantSequences, 0, universo);
          widget.onMatchFinished(resultado);
        });
      }
      else{
        await turnoOponente(oponente, 2);
        if(revisarGanador(2, cantSequences)){
          final completer = Completer<void>();
          MostrarGanador(sequences2, 2, completer);
          await completer.future;
          setState(() {
            //empezoJuego = false;
            perdiJuego = true;
            estado = "PERDISTEEE";
            Resultado resultado = Resultado(nivelOponente, 2, cantSequences, 0, universo);
            widget.onMatchFinished(resultado);
          });
        }
        if(universo == 3){
          await turnoOponente(oponente, 4);
          if(revisarGanador(4, cantSequences)){
            final completer = Completer<void>();
            MostrarGanador(sequences3, 4, completer);
            await completer.future;
            setState(() {
              perdiJuego = true;
              estado = "PERDISTEEE";
              Resultado resultado = Resultado(nivelOponente, 4, cantSequences, 0, universo);
              widget.onMatchFinished(resultado);
            });
          }
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
      estado = "Tiraste el ${cartaPresionada.numero} de ${cartaPresionada.palo}";
      ultimaCartaTirada = cartaPresionada;
    });
  }

  Future<void> turnoOponente(Oponente oponente, int ficha) async{
    await Future.delayed(Duration(milliseconds: 2000));
    List<Carta> cartasEnManoOponente = [];
    if(ficha == 2){
      cartasEnManoOponente = cartasEnManoOponente1;
    }
    else{
      cartasEnManoOponente = cartasEnManoOponente2;
    }
    oponente.ActualizarMatriz(matriz);
    for (Carta carta in cartasEnManoOponente){
      if(tengoDeadCard(carta) && carta.numero != "Wild" && carta.numero != "Remove"){
        cartasEnManoOponente.remove(carta);
        entregarCarta(ficha);
      }
    }
    oponente.ActualizarCartas(cartasEnManoOponente);
    var retorno = oponente.tirarCarta(ficha);
    setState(() {
      matriz = retorno.tablero;
      ultimaCartaTirada = retorno.carta;
      estado = "";
    });
    entregarCarta(ficha);
  }

  Future<void> turnoJugador1Maquina(Oponente oponente) async{
    oponente.ActualizarMatriz(matriz);
    for (Carta carta in cartasEnManoMia){
      if(tengoDeadCard(carta) && carta.numero != "Wild" && carta.numero != "Remove"){
        cartasEnManoMia.remove(carta);
        entregarCarta(1);
      }
    }
    oponente.ActualizarCartas(cartasEnManoMia);
    var retorno = oponente.tirarCarta(2);
    setState(() {
      matriz = retorno.tablero;
      ultimaCartaTirada = retorno.carta;
      estado = "";
    });
    entregarCarta(1);
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
        Carta cartaADar = mazo.darPrimerCarta();
        if(cartaADar.numero == "Wild"){
          if(cantWilds >= 1 ) cartasEnManoMia.add(mazo.darPrimerCarta());
          else if(nivelOponente > 25) cartasEnManoMia.add(mazo.darPrimerCarta());
          else{
            cartasEnManoMia.add(cartaADar);
            cantWilds ++;
          }
        }
        else if(cartaADar.numero == "Remove" && nivelOponente == 30){
          cartasEnManoMia.add(mazo.darPrimerCarta());
        }
        else cartasEnManoMia.add(cartaADar);
      }
      else if(jugador == 2){
        cartasEnManoOponente1.add(mazo.darPrimerCarta());
      }
      else if(jugador == 4){
        cartasEnManoOponente2.add(mazo.darPrimerCarta());
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
      if(universo == 3) entregarCarta(4);
    }
    print("Se teriminaron de repartir las cartas");
  }


  bool sonIguales(List<CartaConPos> lista1, List<CartaConPos> lista2){
    for(int i=0; i<lista1.length; i++){
      if(lista1[i].carta.numero != lista2[i].carta.numero || lista1[i].carta.palo != lista2[i].carta.palo || lista1[i].columna != lista2[i].columna || lista1[i].fila != lista2[i].fila){
        return false;
      }
    }
    return true;
  }
  bool tienenMasDeUnoEnComun(List<CartaConPos> lista1, List<CartaConPos> lista2){
    int cantEnComun = 0;
    for(int i=0; i<lista1.length; i++){
      for(int j=0; j<lista2.length; j++){
        if(lista1[i].carta.numero == lista2[j].carta.numero && lista1[i].carta.palo == lista2[j].carta.palo && lista1[i].columna == lista2[j].columna && lista1[i].fila == lista2[j].fila){
          cantEnComun++;
        }
      }
    }
    if(cantEnComun > 1){
      return true;
    }
    else{
      return false;
    }
  }

  bool perteneceASequences(List<List<CartaConPos>> sequencesYaHechos, List<CartaConPos> sequence) {
    for(List<CartaConPos> lista in sequencesYaHechos){
      if(sonIguales(lista, sequence)) return true;
      if(tienenMasDeUnoEnComun(lista, sequence)) return true;
    }
    return false;
  }
  void verSiLoAgrego(List<CartaConPos> lista, int ficha){
    if(ficha == 1){
      if(!perteneceASequences(sequences1, lista)){
        setState(() {
          sequences1.add(lista);
        });
      }
    }
    else if(ficha == 2){
      if(!perteneceASequences(sequences2, lista)){
        setState(() {
          sequences2.add(lista);
        });
      }
    }
  }

  bool revisarGanador(int ficha, int sequences) {
    CartaConPos cartaAingresar = CartaConPos(Carta("", ""), 0, 0);
    List<CartaConPos> sequence = [];
    // Revisar filas
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
          sequence = [];
          for (int k = 0; k < 5; k++) {
            cartaAingresar = CartaConPos(Carta(matriz[i][j+k].numeroCarta, matriz[i][j+k].palo), j+k, i);
            sequence.add(cartaAingresar);
          }
          verSiLoAgrego(sequence, ficha);
        }
      }
    }
    // Revisar columnas
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
          sequence = [];
          for (int k = 0; k < 5; k++) {
            cartaAingresar = CartaConPos(Carta(matriz[j+k][i].numeroCarta, matriz[j+k][i].palo), i, j+k);
            sequence.add(cartaAingresar);
          }
          verSiLoAgrego(sequence, ficha);
        }
      }
    }

    // Revisar diagonales principales (\)
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
          sequence = [];
          for (int k = 0; k < 5; k++) {
            cartaAingresar =CartaConPos(Carta(matriz[i+k][j+k].numeroCarta, matriz[i+k][j+k].palo), j+k, i+k) ;
            sequence.add(cartaAingresar);
          }
          verSiLoAgrego(sequence, ficha);
        }
      }
    }

    // Revisar diagonales secundarias (/)
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
          sequence = [];
          for (int k = 0; k < 5; k++) {
            cartaAingresar =CartaConPos(Carta(matriz[i+k][j-k].numeroCarta, matriz[i+k][j-k].palo), j-k, i+k) ;
            sequence.add(cartaAingresar);
          }
          verSiLoAgrego(sequence, ficha);
        }

      }
    }

    if(sequences1.length >= sequences) return true;
    if(sequences2.length >= sequences) return true;
    return false;
  }



  void MostrarGanador(List<List<CartaConPos>> listasDelGanador, int ficha, Completer<void> completer) async{
    String texto = "";
    if(ficha == 1) texto = "¡GANASTE!";
    else texto = "¡PERDISTE!";

      for(int i=0; i<5; i++){
        setState(() {
          for(List<CartaConPos> lista in listasDelGanador){
            for(CartaConPos carta in lista){
              matriz[carta.fila][carta.columna].fichaPuesta = 3;
              estado = texto;
            }
          }
        });
        await Future.delayed(Duration(milliseconds: 300));
        setState(() {
          for(List<CartaConPos> lista in listasDelGanador){
            for(CartaConPos carta in lista){
              matriz[carta.fila][carta.columna].fichaPuesta = ficha;
              estado = "";
            }
          }
        });
        await Future.delayed(Duration(milliseconds: 300));
      }
      completer.complete();
  }


  List<List<Triplet>> construirTablero(int nivel) {
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
    if(nivel % 4 == 3) desordenarMatriz(matriz);
    else if(nivel % 2 == 0) voltearMatriz(matriz);
    return matriz;
  }


  void voltearMatriz(List<List<Triplet>> matrizOriginal) {
    List<List<Triplet>> matrizVolteada = List.generate(10, (_) => List<Triplet>.filled(10, Triplet(0, "", ""), growable: false),);
    for (int i = 0; i < 10; i++) {
      matrizVolteada[i] = matrizOriginal[9 - i];
    }
    matriz = matrizVolteada;
  }

  void desordenarMatriz(List<List<Triplet>> matrizOriginal) {
    List<List<Triplet>> matrizDesordenada = List.generate(10, (_) => List<Triplet>.filled(10, Triplet(0, "", ""), growable: false),);

    // Copiar las esquinas "Joker"
    matrizDesordenada[0][0] = matrizOriginal[0][0];
    matrizDesordenada[0][9] = matrizOriginal[0][9];
    matrizDesordenada[9][0] = matrizOriginal[9][0];
    matrizDesordenada[9][9] = matrizOriginal[9][9];

    // Crear una lista con los elementos no esquinas
    List<Triplet> elementosNoEsquinas = [];
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 9; j++) {
        elementosNoEsquinas.add(matrizOriginal[i][j]);
      }
    }
    for(int i=1; i<9; i++){
      elementosNoEsquinas.add(matrizOriginal[i][0]);
      elementosNoEsquinas.add(matrizOriginal[i][9]);
      elementosNoEsquinas.add(matrizOriginal[0][i]);
      elementosNoEsquinas.add(matrizOriginal[9][i]);
    }

    // Desordenar la lista de elementos no esquinas
    elementosNoEsquinas.shuffle();

    // Asignar los elementos desordenados en la matriz desordenada
    int index = 0;
    for (int i = 1; i < 9; i++) {
      for (int j = 1; j < 9; j++) {
        matrizDesordenada[i][j] = elementosNoEsquinas[index];
        index++;
      }
    }
    for(int i=1; i<9; i++){
      matrizDesordenada[i][0] = elementosNoEsquinas[index++];
      matrizDesordenada[i][9] = elementosNoEsquinas[index++];
      matrizDesordenada[0][i] = elementosNoEsquinas[index++];
      matrizDesordenada[9][i] = elementosNoEsquinas[index++];
    }

    matriz =  matrizDesordenada;
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

class Resultado {
  int nivel;
  int ganador;
  int cantSecuences;
  int tiempoJugado;
  int universo;

  Resultado (this.nivel, this.ganador, this.cantSecuences, this.tiempoJugado, this.universo);
}

class CartaConPos{
  Carta carta;
  int columna;
  int fila;
  CartaConPos(this.carta, this.columna, this.fila);
}



