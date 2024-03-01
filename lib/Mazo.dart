


class Mazo {
  List<Carta> cartas = [];
  int cantCartas = 0;

  Mazo(){
    for (var palo in Palos) {
      cartas.add(Carta("Wild", palo));
      cartas.add(Carta("Remove", palo));
      for (var numero in numeros) {
        cartas.add(Carta(numero, palo));
        cartas.add(Carta(numero, palo));
        cantCartas++;
        cantCartas++;
      }
    }
  }

  List<String> Palos = [
    "Corazon",
    "Diamante",
    "Trebol",
    "Picas",
  ];

  List<String> numeros = [
    "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Q", "K",
  ];


  void mezclarMazo(){
    cartas.shuffle();
  }

  Carta darPrimerCarta(){
    if(cartas.isEmpty){
      throw Exception("El mazo esta vacio");
    }
    cantCartas--;
    return cartas.removeAt(0);

  }
}

class Carta {
  String numero;
  String palo;

  Carta(this.numero, this.palo);
}


