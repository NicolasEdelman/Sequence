import '../Oponente.dart';
import '../Mazo.dart';
import 'package:myapp/cartaTablero.dart';

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
    }
    return TableroyCarta(Carta(numeroCarta, paloCarta), mat);
  }
}