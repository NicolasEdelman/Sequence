import '../Oponente.dart';
import '../Mazo.dart';
import 'package:myapp/cartaTablero.dart';

class TirarCartaStrategyN3 implements TirarCartaStrategy{

  List<List<int>> opciones1 = [[1, 1, 1, 1, 0], [1, 1, 1, 0, 1], [1, 1, 0, 1, 1], [1, 0, 1, 1, 1],
    [0, 1, 1, 1, 1], [-2, 1, 1, 1, 0], [-2, 1, 1, 0, 1], [-2, 1, 0, 1, 1], [-2, 0, 1, 1, 1],
    [1, 1, 1, 0, -2], [1, 1, 0, 1, -2], [1, 0, 1, 1, -2], [0, 1, 1, 1, -2],
  ];
  List<List<int>> opciones2 = [[2, 2, 2, 2, 0], [2, 2, 2, 0, 2], [2, 2, 0, 2, 2], [2, 0, 2, 2, 2],
    [0, 2, 2, 2, 2], [-2, 2, 2, 2, 0], [-2, 2, 2, 0, 2], [-2, 2, 0, 2, 2], [-2, 0, 2, 2, 2],
    [2, 2, 2, 0, -2], [2, 2, 0, 2, -2], [2, 0, 2, 2, -2], [0, 2, 2, 2, -2],
  ];

  @override
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja){

    for (Carta carta in baraja){
      if(carta.numero != "Wild" && carta.numero != "Remove"){
        if(VerSiTiroCarta(mat, 2, carta)){
          print("Tire el ${carta.numero} de ${carta.palo} ofensivo");
          baraja.remove(carta);
          return TableroyCarta(carta, mat);
        }
        else if(VerSiTiroCarta(mat, 1, carta)){
          print("Tire el ${carta.numero} de ${carta.palo} defensivo");
          baraja.remove(carta);
          return TableroyCarta(carta, mat);
        }
      }
    }
    return TirarPrimeraCarta(mat, baraja);
  }


  TableroyCarta TirarPrimeraCarta(List<List<Triplet>> mat, List<Carta> baraja){
    String numeroCarta = baraja[0].numero;
    String paloCarta = baraja[0].palo;
    bool deadCard = true;
    bool puseCarta = false;
    for (int i=0; i<10; i++){
      for (int j=0; j<10; j++){
        if(!puseCarta){
          if(mat[i][j].fichaPuesta == 0){
            if(mat[i][j].numeroCarta == numeroCarta && mat[i][j].palo == paloCarta){
              baraja.removeAt(0);
              deadCard = false;
              puseCarta = true;
              mat[i][j] = Triplet(2, numeroCarta.toString(), paloCarta);
            }
          }
        }
      }
    }
    if(deadCard){
      baraja.removeAt(0);
      print("El oponente tiene una dead card");
    }
    return TableroyCarta(Carta(numeroCarta, paloCarta), mat);
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


  bool VerSiTiroCarta(List<List<Triplet>> mat, int numero, Carta carta) {
    bool puseCarta = false;
    List<List<int>> opciones;
    if(numero == 1)opciones = opciones1;
    else opciones = opciones2;

    //print("Voy a ver si tiro el ${carta.numero} de ${carta.palo}");

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      puseCarta = false;
      for (List<int> opcion in opciones) {
        for (int i = 0; i <= fila.length - 5; i++) {
          if (listasIguales(opcion, fila.sublist(i, i + 5).map((triplet) => triplet.fichaPuesta).toList())) {
            for (int j = i; j < i + 5; j++) {
              if(fila[j].fichaPuesta == 0 && fila[j].numeroCarta == carta.numero && fila[j].palo == carta.palo){
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
    for (List<Triplet> fila in mat) {
      if(buscarPatronesEnFila(fila)) return true;
    }

    // Verificar en columnas
    for (int j = 0; j < mat[0].length; j++) {
      if(buscarPatronesEnFila(mat.map((fila) => fila[j]).toList())) return true;
    }

    // Verificar en diagonales principales (\)
    for (int i = 0; i <= mat.length - 5; i++) {
      for (int j = 0; j <= mat[0].length - 5; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(mat[i + k][j + k]);
        }
        if(buscarPatronesEnFila(diagonal)) return true;
      }
    }

    // Verificar en diagonales secundarias (/)
    for (int i = 0; i <= mat.length - 5; i++) {
      for (int j = 4; j < mat[0].length; j++) {
        List<Triplet> diagonal = [];
        for (int k = 0; k < 5; k++) {
          diagonal.add(mat[i + k][j - k]);
        }
        if(buscarPatronesEnFila(diagonal)) return true;
      }
    }
    return false;
  }



}