
import 'package:flutter/material.dart';
import 'Tablero.dart';
import 'Mazo.dart';

class CartaTablero extends StatefulWidget {
  final Triplet triplet;
  final Function(Carta) onTap;
  final Color? J1Color;
  final Color? J2Color;

  const CartaTablero({
    Key? key,
    required this.triplet,
    required this.onTap,
    required this.J1Color,
    required this.J2Color,
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
    IconData? icono;
    Color colorIcono;
    double sizeNumber;
    double sizeIcon;
    switch (widget.triplet.palo) {
      case "Picas":
        icono = Icons.spa;
        colorIcono = Colors.black;
        sizeNumber = 10;
        sizeIcon = 15;
        break;
      case "Trebol":
        icono = Icons.grass;
        colorIcono = Colors.black;
        sizeNumber = 10;
        sizeIcon = 15;
        break;
      case "Corazon":
        icono = Icons.favorite;
        colorIcono = Colors.red;
        sizeNumber = 10;
        sizeIcon = 15;
        break;
      case "Joker":
        icono = Icons.face;
        colorIcono = Colors.lightBlue;
        sizeNumber = 1;
        sizeIcon = 20;
        break;
      case "Diamante":
        icono = Icons.diamond;
        colorIcono = Colors.red;
        sizeNumber = 10;
        sizeIcon = 15;
        break;
      default:
        icono = null;
        colorIcono = Colors.black;
        sizeNumber = 10;
        sizeIcon = 15;
        break;
    }

    switch (widget.triplet.fichaPuesta) {
      case 0:
        return _buildCelda(Colors.grey[200]!, icono, colorIcono, sizeNumber, sizeIcon);
      case 1:
        return _buildCelda(widget.J1Color ?? Colors.white, icono, colorIcono, sizeNumber, sizeIcon);
      case 2:
        return _buildCelda(widget.J2Color ?? Colors.white, icono, colorIcono, sizeNumber, sizeIcon);
      default:
        return _buildCelda(Colors.grey[200]!, icono, colorIcono, sizeNumber, sizeIcon);
    }
  }

  Widget _buildCelda(Color colorCelda, IconData? icono, Color colorIcono, double sizeNumber, double sizeIcon) {
    return Container(
      margin: EdgeInsets.all(1), // Espacio entre las celdas
      padding: EdgeInsets.symmetric(vertical: 2),
      color: colorCelda, // Color de fondo de la celda
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.triplet.numeroCarta, style: TextStyle(fontSize: sizeNumber),), // Mostrar el entero de la matriz
            Icon(icono, size: sizeIcon, color: colorIcono,), // Mostrar el palo
          ],
        ),
      ),
    );
  }
}

class Triplet {
  final int fichaPuesta;
  final String numeroCarta;
  final String palo;

  Triplet(this.fichaPuesta, this.numeroCarta, this.palo);
}


