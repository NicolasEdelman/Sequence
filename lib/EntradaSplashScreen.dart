import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/SplashScreenCargaNivel.dart';
import 'package:myapp/main.dart';

class EntradaSplashScreen extends StatefulWidget{
  const EntradaSplashScreen({super.key});

  @override
  State<EntradaSplashScreen> createState() => _EntradaSplashScreenState();
}

class _EntradaSplashScreenState extends State<EntradaSplashScreen> with SingleTickerProviderStateMixin{
  @override
  void initState(){
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MyHomePage(title: "Hola", subtitle: "Verano")));
    });
  }

  @override
  void dispose(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/poker.png", height: 150,),
          ],
        ),
      )
    );
  }
}
