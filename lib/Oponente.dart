import 'package:flutter/cupertino.dart';
import 'package:myapp/cartaTablero.dart';
import 'Mazo.dart';
import 'package:flutter/material.dart';
import 'OponentStrategies/TirarCartaStrategyN1.dart';
import 'OponentStrategies/TirarCartaStrategyN2.dart';
import 'OponentStrategies/TirarCartaStrategyN3.dart';
import 'OponentStrategies/TirarCartaStrategyN4.dart';
import 'OponentStrategies/TirarCartaStrategyN5.dart';

class Oponente{
  int Nivel = 0;
  int tiempoTurnoUsuario = 0;
  List<Carta> cartasEnMano = [];
  List<List<Triplet>> matriz =  List.generate(10, (_) => List<Triplet>.generate(10, (_) => Triplet(0, "0", ""),),);
  Carta ultimaCartaTirada = Carta("", "");
  Color? colorUsuario;
  Color? colorOponente;
  TirarCartaStrategy? strategy;


  Oponente(this.Nivel, this.colorUsuario){
    DarColorOponente();
    switch (this.Nivel){
      case 1: setStrategy(TirarCartaStrategyN1()); tiempoTurnoUsuario = 40;
      case 2: setStrategy(TirarCartaStrategyN1()); tiempoTurnoUsuario = 30;
      case 3: setStrategy(TirarCartaStrategyN1()); tiempoTurnoUsuario = 20;
      case 4: setStrategy(TirarCartaStrategyN1()); tiempoTurnoUsuario = 10;

      case 5: setStrategy(TirarCartaStrategyN2()); tiempoTurnoUsuario = 40;
      case 6: setStrategy(TirarCartaStrategyN2()); tiempoTurnoUsuario = 30;
      case 7: setStrategy(TirarCartaStrategyN2()); tiempoTurnoUsuario = 20;
      case 8: setStrategy(TirarCartaStrategyN2()); tiempoTurnoUsuario = 10;

      case 9: setStrategy(TirarCartaStrategyN3()); tiempoTurnoUsuario = 40;
      case 10: setStrategy(TirarCartaStrategyN3()); tiempoTurnoUsuario = 30;
      case 11: setStrategy(TirarCartaStrategyN3()); tiempoTurnoUsuario = 20;
      case 12: setStrategy(TirarCartaStrategyN3()); tiempoTurnoUsuario = 10;

      case 13: setStrategy(TirarCartaStrategyN4()); tiempoTurnoUsuario = 40;
      case 14: setStrategy(TirarCartaStrategyN4()); tiempoTurnoUsuario = 30;
      case 15: setStrategy(TirarCartaStrategyN4()); tiempoTurnoUsuario = 20;
      case 16: setStrategy(TirarCartaStrategyN4()); tiempoTurnoUsuario = 10;

      case 17: setStrategy(TirarCartaStrategyN5()); tiempoTurnoUsuario = 40;
      case 18: setStrategy(TirarCartaStrategyN5()); tiempoTurnoUsuario = 30;
      case 19: setStrategy(TirarCartaStrategyN5()); tiempoTurnoUsuario = 20;
      case 20: setStrategy(TirarCartaStrategyN5()); tiempoTurnoUsuario = 10;

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

  void DarColorOponente(){
    List<Color> listaColores = [Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.purple, Colors.teal, Colors.black];
    listaColores.remove(colorUsuario);
    List<Color> nuevaLista = [];
    nuevaLista.add(Colors.white);
    for(var color in listaColores){
      nuevaLista.add(Color.lerp(color, Colors.white, 0.35)!);
      nuevaLista.add(Color.lerp(color, Colors.white, 0.65)!);
      nuevaLista.add(color);
      nuevaLista.add(Color.lerp(color, Colors.black, 0.35)!);
      nuevaLista.add(Color.lerp(color, Colors.black, 0.65)!);
    }
    listaColores = nuevaLista;
    colorOponente = listaColores[this.Nivel];
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
