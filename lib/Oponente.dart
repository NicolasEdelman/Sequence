import 'package:myapp/cartaTablero.dart';
import 'Mazo.dart';
import 'OponentStrategies/TirarCartaStrategyN1.dart';
import 'OponentStrategies/TirarCartaStrategyN2.dart';

class Oponente{
  int Nivel = 0;
  List<Carta> cartasEnMano = [];
  List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  Carta ultimaCartaTirada = Carta("", "");
  TirarCartaStrategy? strategy;

  Oponente(this.Nivel){
    switch (this.Nivel){
      case 1: setStrategy(TirarCartaStrategyN1());
      case 2: setStrategy(TirarCartaStrategyN2());
    }
  }

  void setStrategy(TirarCartaStrategy strate){
    this.strategy = strate;
  }
  TableroyCarta tirarCarta(){
    return strategy!.TirarCarta(matriz, cartasEnMano);
  }
  bool? ActualizarCartas(List<Carta> nuevaBaraja){
    this.cartasEnMano = nuevaBaraja;
  }
  void ActualizarMatriz(List<List<Triplet>> nuevamatriz){
    this.matriz = nuevamatriz;
  }
}

abstract class TirarCartaStrategy{
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja);
}


class TableroyCarta{
  Carta carta;
  List<List<Triplet>> tablero;

  TableroyCarta(this.carta, this.tablero);
}
