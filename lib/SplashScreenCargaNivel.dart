import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final int nivel;
  final int cantidadSequencias;
  final Color? j1Color;
  final int universo;

  const SplashScreen({
    required this.nivel,
    required this.cantidadSequencias,
    required this.j1Color,
    required this.universo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FadeInAnimation(
      duration: Duration(milliseconds: 500),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, j1Color!],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/poker.png", height: 150,),
                  SizedBox(height: 20,),
                  if(cantidadSequencias == 1)
                    Text(
                      "Nivel $nivel - 1 sequence",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  if(cantidadSequencias == 2)
                    Text(
                      "Nivel $nivel - 2 sequences",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  SizedBox(height: 20,),
                  Text("UNIVERSO $universo", style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),),
                  SizedBox(height: 40,),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class FadeInAnimation extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const FadeInAnimation({
    required this.duration,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}