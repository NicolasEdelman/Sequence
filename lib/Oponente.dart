import 'package:myapp/cartaTablero.dart';

import 'Mazo.dart';

class Oponente{
  int Nivel = 0;
  List<Carta> cartasEnMano = [];
  List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  Carta ultimaCartaTirada = Carta("", "");
  TirarCartaStrategy? strategy;

  Oponente(this.Nivel){}

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

class TirarCartaStrategyN1 implements TirarCartaStrategy{
   @override
   TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja){
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
      return TirarCarta(mat, baraja);
    }
     return TableroyCarta(Carta(numeroCarta, paloCarta), mat);
   }
}

class TirarCartaStrategyN2 implements TirarCartaStrategy{
  @override
  TableroyCarta TirarCarta(List<List<Triplet>> mat, List<Carta> baraja){
    print("Tire la carta numero 2");
    return TableroyCarta(Carta("", ""), mat);
  }
}

class TableroyCarta{
   Carta carta;
   List<List<Triplet>> tablero;

   TableroyCarta(this.carta, this.tablero);
}

