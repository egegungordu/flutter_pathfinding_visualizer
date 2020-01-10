import 'package:flutter/material.dart';

class WallNodePaintWidget extends StatefulWidget {
  final double unitSize;
  final int i;
  final int j;
  final Function(int i, int j, Rect rect) callback;
  final Function(int i, int j) removeNode;
  WallNodePaintWidget(this.unitSize, this.i, this.j, this.callback, this.removeNode,{Key key}) : super(key:key);
  @override
  _WallNodePaintWidgetState createState() => _WallNodePaintWidgetState();
}

class _WallNodePaintWidgetState extends State<WallNodePaintWidget> with SingleTickerProviderStateMixin{

  double fraction = 0;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Rect rect = Rect.fromLTWH((widget.unitSize +1) * widget.i, (widget.unitSize +1) * widget.j, widget.unitSize + 2, widget.unitSize + 2);
        widget.callback(widget.i,widget.j,rect);
        widget.removeNode(widget.i, widget.j);
      }
    });

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut
    ))
    ..addListener((){
      setState(() {
        fraction = animation.value;
      });
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WallNodePainter(widget.unitSize, fraction)
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


abstract class NodePainter extends CustomPainter{
  NodePainter(this.unitSize, this.fraction);
  double fraction;
  double unitSize;

  @override
  bool shouldRepaint(NodePainter oldDelegate) {
    return oldDelegate.fraction != fraction ? true : false;
  }
}

class WallNodePainter extends NodePainter{
  WallNodePainter(double unitSize, double fraction) : super(unitSize, fraction);

  @override
  void paint(Canvas canvas, Size size) {
    var rectl = Rect.fromCenter(
      center: Offset(unitSize/2,unitSize/2),
      width: fraction * (unitSize + 2),
      height: fraction * (unitSize + 2),
      );
    Paint paint = Paint();
    paint.color = Colors.grey.shade900;
    canvas.drawRect(rectl, paint);
  }
}

//ImageNodes
class NodeImageWidget extends StatefulWidget {

  final double boxSize;
  final String asset;
  NodeImageWidget(this.boxSize, this.asset);
  @override
  _NodeImageWidgetState createState() => _NodeImageWidgetState();
}

class _NodeImageWidgetState extends State<NodeImageWidget> with SingleTickerProviderStateMixin{

  double fraction = 0;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut
    ))
    ..addListener((){
      setState(() {
        fraction = animation.value;
      });
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: fraction,
      child: Image.asset(widget.asset, width: widget.boxSize, height: widget.boxSize,),
    );
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
