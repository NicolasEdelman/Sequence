import '../Oponente.dart';
import '../Mazo.dart';
import 'package:myapp/cartaTablero.dart';

class TirarCartaStrategyN2 implements TirarCartaStrategy{
  @override
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja){
    if(baraja[0].numero == "Remove"){
      if(PeligroRemove(mat)){
        baraja.removeAt(0);
        return TableroyCarta(baraja[0], mat);
      }
    }
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

  bool PeligroRemove(List<List<Triplet>> mat) {
    print("Voy a tirar el Jack remove");
    List<List<int>> opciones = [
      [1, 1, 1, 1, 0],
      [1, 1, 1, 0, 1],
      [1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1],
      [0, 1, 1, 1, 1],
      [-2, 1, 1, 1, 0],
      [-2, 1, 1, 0, 1],
      [-2, 1, 0, 1, 1],
      [-2, 0, 1, 1, 1],
      [1, 1, 1, 0, -2],
      [1, 1, 0, 1, -2],
      [1, 0, 1, 1, -2],
      [0, 1, 1, 1, -2],
    ];

    // Función auxiliar para verificar si dos listas son iguales
    bool listasIguales(List<int> a, List<int> b) {
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) {
          return false;
        }
      }
      return true;
    }

    // Función auxiliar para verificar si una fila cumple con algún patrón
    bool buscarPatronesEnFila(List<Triplet> fila) {
      for (List<int> opcion in opciones) {
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