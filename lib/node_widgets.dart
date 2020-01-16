import 'package:flutter/material.dart';

class WallNodePaintWidget extends StatefulWidget {
  final double unitSize;
  final int i;
  final int j;
  final Color color;
  final Function(int i, int j, Color rect) callback;
  WallNodePaintWidget({this.unitSize, this.i, this.j, this.callback,Key key, this.color}) : super(key:key);
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
        widget.callback(widget.i,widget.j,widget.color);
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
      painter: WallNodePainter(widget.unitSize, fraction, widget.color)
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


abstract class NodePainter extends CustomPainter{
  NodePainter(this.unitSize, this.fraction, this.color);
  double fraction;
  double unitSize;
  Color color;

  @override
  bool shouldRepaint(NodePainter oldDelegate) {
    return oldDelegate.fraction != fraction ? true : false;
  }
}

class WallNodePainter extends NodePainter{
  WallNodePainter(double unitSize, double fraction, Color color) : super(unitSize, fraction,color);

  @override
  void paint(Canvas canvas, Size size) {
    var rectl = Rect.fromCenter(
      center: Offset(unitSize/2,unitSize/2),
      width: fraction * (unitSize + 2),
      height: fraction * (unitSize + 2),
      );
    Paint paint = Paint()
      ..color = color;
    canvas.drawRect(rectl, paint);
  }
}

//ImageNodes
class NodeImageWidget extends StatefulWidget {

  final double boxSize;
  final String asset;
  // final Function(Image img) callback;
  NodeImageWidget(this.boxSize, this.asset,); //this.callback);
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
    )
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     Image img = Image.asset(widget.asset, width: widget.boxSize, height: widget.boxSize,);
    //     widget.callback(img);
    //   }
    // });
    ;
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


class VisitedNodePaintWidget extends StatefulWidget {
  final double unitSize;
  final int i;
  final int j;
  final Color color;
  final Function(int i, int j, Color color) callback;
  VisitedNodePaintWidget({this.unitSize, Key key, this.i, this.j, this.callback, this.color}) : super(key:key);
  @override
  _VisitedNodePaintWidgetState createState() => _VisitedNodePaintWidgetState();
}

class _VisitedNodePaintWidgetState extends State<VisitedNodePaintWidget> with SingleTickerProviderStateMixin{

  double fraction = 0;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.callback(widget.i,widget.j,widget.color);
      }
    });

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInToLinear
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
      painter: VisitedNodePainter(widget.unitSize, fraction, widget.color)
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class VisitedNodePainter extends NodePainter{
  VisitedNodePainter(double unitSize, double fraction, Color color) : super(unitSize, fraction, color);
  
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromCenter(
      center: Offset(unitSize/2,unitSize/2),
      width: fraction * (unitSize + 2),
      height: fraction * (unitSize + 2),
    );
    var rrect = RRect.fromRectAndRadius(rect, Radius.circular((1-fraction)*100));
    Paint paint = Paint()
      ..color = color;
    canvas.drawRRect(rrect, paint);
  }
}
