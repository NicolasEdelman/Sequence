import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyState extends ChangeNotifier{
  Color? J1selectedColor = Colors.blue;
  String name = "";
  int ultimoNivelDesbloqueado = 1;
  int nivelActual = 1;
  int ultimoUniversoDesbloqueado = 1;
  int universoActual = 1;
  bool isPlaying = false;

  void cambiarNombre(String nuevoNombre){
    name = nuevoNombre;
    notifyListeners();
  }
  void cambiarColor(Color nuevoColor){
    J1selectedColor = nuevoColor;
    notifyListeners();
  }
  void avanzarNivelDesbloqueado(){
    ultimoNivelDesbloqueado++;
    notifyListeners();
  }
  void cambiarNivelActual(int nuevoNivel){
    nivelActual == nuevoNivel;
    notifyListeners();
  }

}