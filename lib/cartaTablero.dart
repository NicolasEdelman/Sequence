import 'package:flutter/material.dart';
import 'Mazo.dart';

class CartaTablero extends StatefulWidget {
  final Triplet triplet;
  final Function(Carta) onTap;
  final Color? J1Color;
  final Color? J2Color;
  final Color? J3Color;
  final int columna;
  final int fila;


  const CartaTablero({
    Key? key,
    required this.triplet,
    required this.onTap,
    required this.J1Color,
    required this.J2Color,
    required this.J3Color,
    required this.columna,
    required this.fila,
  }) : super(key: key);

  @override
  _CartaTableroState createState() => _CartaTableroState();
}

class _CartaTableroState extends State<CartaTablero> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Llamar a la función onTap y pasar la carta correspondiente cuando se toque la carta
        widget.onTap(Carta(widget.triplet.numeroCarta, widget.triplet.palo));
      },
      child: _buildCarta(),
    );
  }

  Widget _buildCarta() {
    double sizeNumber;
    String imagePath = "";
    switch (widget.triplet.palo) {
      case "Picas":
        sizeNumber = 10;
        imagePath = "assets/images/Picas.png";
        break;
      case "Trebol":
        sizeNumber = 10;
        imagePath = "assets/images/Trebol.png";
        break;
      case "Corazon":
        sizeNumber = 10;
        imagePath = "assets/images/Corazon.png";
        break;
      case "Joker":
        sizeNumber = 1;
        imagePath = "assets/images/Joker.png";
        break;
      case "Diamante":
        sizeNumber = 10;
        imagePath = "assets/images/Diamante.png";
        break;
      default:
        sizeNumber = 10;
        imagePath = "";
        break;
    }

    switch (widget.triplet.fichaPuesta) {
      case 0:
        return _buildCelda(Colors.grey[200]!, imagePath,  sizeNumber, );
      case 1:
        return _buildCelda(widget.J1Color ?? Colors.white, imagePath, sizeNumber);
      case 2:
        return _buildCelda(widget.J2Color ?? Colors.white, imagePath, sizeNumber );
      case 3: 
        return _buildCelda(Colors.transparent, imagePath, sizeNumber);
      case 4:
        return _buildCelda(widget.J3Color ?? Colors.white, imagePath, sizeNumber);
      default:
        return _buildCelda(Colors.grey[200]!, imagePath, sizeNumber);
    }
  }

  Widget _buildCelda(Color colorCelda, String imagePath, double sizeNumber) {
    bool isDarkJ2Color = widget.J2Color != null ? ThemeData.estimateBrightnessForColor(colorCelda!) == Brightness.dark : false;
    return Container(
      margin: EdgeInsets.all(1), // Espacio entre las celdas
      padding: EdgeInsets.symmetric(vertical: 2),
      color: colorCelda, // Color de fondo de la celda
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.triplet.numeroCarta, style: TextStyle(fontSize: sizeNumber, color: isDarkJ2Color ? Colors.white : null,)),
            Image.asset(imagePath, width: 15, height: 15,), // Mostrar el palo
          ],
        ),
      ),
    );
  }
}

class Triplet {
  int fichaPuesta;
  final String numeroCarta;
  final String palo;

  Triplet(this.fichaPuesta, this.numeroCarta, this.palo);
}


