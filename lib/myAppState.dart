import 'package:flutter/material.dart';

class MyState extends ChangeNotifier{
  Color? J1selectedColor = Colors.blue;
  String name = "";

  void cambiarNombre(String nuevoNombre){
    name = nuevoNombre;
    notifyListeners();
  }
  void cambiarColor(Color nuevoColor){
    J1selectedColor = nuevoColor;
    notifyListeners();
  }
}