import '../Oponente.dart';
import '../Mazo.dart';
import 'package:myapp/cartaTablero.dart';

class TirarCartaStrategyN3 implements TirarCartaStrategy{

  List<Carta> cartas = [];
  List<List<Triplet>> matriz = [[]];

  List<List<int>> opciones1 = [[1, 1, 1, 1, 0], [1, 1, 1, 0, 1], [1, 1, 0, 1, 1], [1, 0, 1, 1, 1],
    [0, 1, 1, 1, 1], [-2, 1, 1, 1, 0], [-2, 1, 1, 0, 1], [-2, 1, 0, 1, 1], [-2, 0, 1, 1, 1],
    [1, 1, 1, 0, -2], [1, 1, 0, 1, -2], [1, 0, 1, 1, -2], [0, 1, 1, 1, -2],
  ];
  List<List<int>> opciones2 = [[2, 2, 2, 2, 0], [2, 2, 2, 0, 2], [2, 2, 0, 2, 2], [2, 0, 2, 2, 2],
    [0, 2, 2, 2, 2], [-2, 2, 2, 2, 0], [-2, 2, 2, 0, 2], [-2, 2, 0, 2, 2], [-2, 0, 2, 2, 2],
    [2, 2, 2, 0, -2], [2, 2, 0, 2, -2], [2, 0, 2, 2, -2], [0, 2, 2, 2, -2],
  ];
  List<List<int>> opciones4 = [[4, 4, 4, 4, 0], [4, 4, 4, 0, 4], [4, 4, 0, 4, 4], [4, 0, 4, 4, 4],
    [0, 4, 4, 4, 4], [-2, 4, 4, 4, 0], [-2, 4, 4, 0, 4], [-2, 4, 0, 4, 4], [-2, 0, 4, 4, 4],
    [4, 4, 4, 0, -2], [4, 4, 0, 4, -2], [4, 0, 4, 4, -2], [0, 4, 4, 4, -2],
  ];

  @override
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja, int ficha){
    cartas = baraja;
    matriz = mat;
    for (Carta carta in cartas){
      if(siCompletaOMata(carta, ficha)) return TableroyCarta(carta, matriz);
    }
    return TirarPrimerCarta(cartas[0], ficha);
  }

  void PonerPrimeraAlFinal(){
    Carta primera = cartas[0];
    for(int i=0; i<6; i++){
      cartas[i] = cartas[i+1];
    }
    cartas[6] = primera;
  }

  TableroyCarta TirarPrimerCarta(Carta cartaATirar, int ficha){
    bool deadCard = true;
    bool puseCarta = false;
    for (int i=0; i<10; i++){
      for (int j=0; j<10; j++){
        if(!puseCarta){
          if(matriz[i][j].fichaPuesta == 0){
            if(matriz[i][j].numeroCarta == cartaATirar.numero && matriz[i][j].palo == cartaATirar.palo){
              cartas.removeAt(0);
              deadCard = false;
              puseCarta = true;
              matriz[i][j] = Triplet(ficha, cartaATirar.numero.toString(), cartaATirar.palo);
            }
          }
        }
      }
    }
    if(deadCard){
      cartas.removeAt(0);
      print("El oponente tiene una dead card");
    }
    return TableroyCarta(cartaATirar, matriz);
  }

  bool siCompletaOMata(Carta carta, int ficha){
      if(carta.numero != "Wild" && carta.numero != "Remove"){
        if(VerSiTiroCarta(ficha, carta, ficha)){
          print("Tire el ${carta.numero} de ${carta.palo} ofensivo");
          cartas.remove(carta);
          return true;
        }
        else if(VerSiTiroCarta(1, carta, ficha)){
          print("Tire el ${carta.numero} de ${carta.palo} defensivo");
          cartas.remove(carta);
          return true;
        }
      }
    return false;
  }




  // Función auxiliar para verificar si dos listas son iguales
  bool listasIguales(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }


  bool VerSiTiroCarta(int numero, Carta carta, int ficha) {
    bool puseCarta = false;
    List<List<int>> opciones;
    if(numero == 1)opciones = opciones1;
    else if (numero == 2) opciones = opciones2;
    else opciones = opciones4;

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      puseCarta = false;
      for (List<int> opcion in opciones) {
        for (int i = 0; i <= fila.length - 5; i++) {
          if (listasIguales(opcion, fila.sublist(i, i + 5).map((triplet) => triplet.fichaPuesta).toList())) {
            for (int j = i; j < i + 5; j++) {
              if(fila[j].fichaPuesta == 0 && fila[j].numeroCarta == carta.numero && fila[j].palo == carta.palo){
                fila[j].fichaPuesta = ficha;
                puseCarta = true;
              }
            }
          }
        }
      }
      return puseCarta;
    }

    // Verificar en filas
    for (List<Triplet> fila in matriz) {
      if(buscarPatronesEnFila(fila)) return true;
    }

    // Verificar en columnas
    for (int j = 0; j < matriz[0].length; j++) {
      if(buscarPatronesEnFila(matriz.map((fila) => fila[j]).toList())) return true;
    }

    // Verificar en diagonales principales (\)
    for (int i = 0; i <= matriz.length - 5; i++) {
      for (int j = 0; j <= matriz[0].length - 5; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(matriz[i + k][j + k]);
        }
        if(buscarPatronesEnFila(diagonal)) return true;
      }
    }

    // Verificar en diagonales secundarias (/)
    for (int i = 0; i <= matriz.length - 5; i++) {
      for (int j = 4; j < matriz[0].length; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(matriz[i + k][j - k]);
        }
        if(buscarPatronesEnFila(diagonal)) return true;
      }
    }
    return false;
  }



}