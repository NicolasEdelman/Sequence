import '../Oponente.dart';
import '../Mazo.dart';
import 'package:myapp/cartaTablero.dart';

class TirarCartaStrategyN5 implements TirarCartaStrategy {

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


  @override
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja) {
    cartas = baraja;
    matriz = mat;
    for (Carta carta in cartas) {
      if(siCompletaOMata(carta)) return TableroyCarta(carta, matriz);
    }
    for(Carta carta in cartas){
      if(TirarJackBien(carta)) return TableroyCarta(carta, matriz);
    }
    var cartaATirar = cartas[0];
    return TirarPrimerCarta(cartaATirar);
  }

  TableroyCarta TirarPrimerCarta(Carta cartaATirar){
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
              matriz[i][j] = Triplet(2, cartaATirar.numero.toString(), cartaATirar.palo);
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

  bool TirarJackBien(Carta cartaATirar){
    if(cartaATirar.numero == "Remove"){
      if(TirarRemove()){
        print("Te sacaron una carta!");
        cartas.removeAt(0);
        return true;
      }
      PonerPrimeraAlFinal();
    }
    cartaATirar = cartas[0];
    if(cartaATirar.numero == "Wild"){
      if(TirarWild(2)){
        print("Pusieron un Wild Ofensivo!");
        cartas.removeAt(0);
        return true;
      }
      else if(TirarWild(1)){
        print("Pusieron un Wild Defensivo");
        cartas.removeAt(0);
        return true;
      }
      PonerPrimeraAlFinal();
    }
    return false;
  }

  bool siCompletaOMata(Carta carta){
    if(carta.numero != "Wild" && carta.numero != "Remove"){
      if(VerSiTiroCarta(2, carta)){
        print("Tire el ${carta.numero} de ${carta.palo} ofensivo");
        cartas.remove(carta);
        return true;
      }
      else if(VerSiTiroCarta(1, carta)){
        print("Tire el ${carta.numero} de ${carta.palo} defensivo");
        cartas.remove(carta);
        return true;
      }
    }
    return false;
  }

  void PonerPrimeraAlFinal(){
    Carta primera = cartas[0];
    for(int i=0; i<6; i++){
      cartas[i] = cartas[i+1];
    }
    cartas[6] = primera;
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


  bool VerSiTiroCarta(int numero, Carta carta) {
    bool puseCarta = false;
    List<List<int>> opciones;
    if (numero == 1)
      opciones = opciones1;
    else
      opciones = opciones2;

    //print("Voy a ver si tiro el ${carta.numero} de ${carta.palo}");

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      puseCarta = false;
      for (List<int> opcion in opciones) {
        for (int i = 0; i <= fila.length - 5; i++) {
          if (listasIguales(opcion, fila.sublist(i, i + 5)
              .map((triplet) => triplet.fichaPuesta)
              .toList())) {
            for (int j = i; j < i + 5; j++) {
              if (fila[j].fichaPuesta == 0 &&
                  fila[j].numeroCarta == carta.numero &&
                  fila[j].palo == carta.palo) {
                fila[j].fichaPuesta = 2;
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
      if (buscarPatronesEnFila(fila)) return true;
    }

    // Verificar en columnas
    for (int j = 0; j < matriz[0].length; j++) {
      if (buscarPatronesEnFila(matriz.map((fila) => fila[j]).toList()))
        return true;
    }

    // Verificar en diagonales principales (\)
    for (int i = 0; i <= matriz.length - 5; i++) {
      for (int j = 0; j <= matriz[0].length - 5; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(matriz[i + k][j + k]);
        }
        if (buscarPatronesEnFila(diagonal)) return true;
      }
    }

    // Verificar en diagonales secundarias (/)
    for (int i = 0; i <= matriz.length - 5; i++) {
      for (int j = 4; j < matriz[0].length; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(matriz[i + k][j - k]);
        }
        if (buscarPatronesEnFila(diagonal)) return true;
      }
    }
    return false;
  }


  bool TirarRemove() {

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      for (List<int> opcion in opciones1) {
        for (int i = 0; i <= fila.length - 5; i++) {
          if (listasIguales(opcion, fila.sublist(i, i + 5).map((triplet) => triplet.fichaPuesta).toList())) {
            print("Patrón encontrado en la fila:");
            for (int j = i; j < i + 5; j++) {
              print("${fila[j].numeroCarta} de ${fila[j].palo}");
            }
            // Encontrar la posición con más unos pegados y cambiar la fichaPuesta a 0
            int maxUnosPegados = 0;
            int posicionMaxUnos = i;
            for (int j = i; j < i + 5; j++) {
              int unosPegados = 0;
              if (fila[j].fichaPuesta == 1) {
                unosPegados++;
                if (j > i && fila[j - 1].fichaPuesta == 1) unosPegados++;
                if (j < i + 4 && fila[j + 1].fichaPuesta == 1) unosPegados++;
              }
              if (unosPegados > maxUnosPegados) {
                maxUnosPegados = unosPegados;
                posicionMaxUnos = j;
              }
            }
            fila[posicionMaxUnos].fichaPuesta = 0;
            return true;
          }
        }
      }
      return false;
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

  bool TirarWild(int numero) {
    List<List<int>> opciones;
    if(numero == 1)opciones = opciones1;
    else opciones = opciones2;

    print("Voy a tirar el Jack Wild defensivo");

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      for (List<int> opcion in opciones) {
        for (int i = 0; i <= fila.length - 5; i++) {
          if (listasIguales(opcion, fila.sublist(i, i + 5).map((triplet) => triplet.fichaPuesta).toList())) {
            print("Patrón encontrado en la fila:");
            for (int j = i; j < i + 5; j++) {
              print("${fila[j].numeroCarta} de ${fila[j].palo}");
              if(fila[j].fichaPuesta == 0){
                fila[j].fichaPuesta = 2;
              }
            }
            return true;
          }
        }
      }
      return false;
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
