
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'package:flutter_2d_grid/algorithms.dart';

enum AnimatedButtonPopUpDirection{
  horizontal,
  vertical
}

class AnimatedButtonWithPopUp extends StatefulWidget {
  AnimatedButtonWithPopUp({@required this.onPressed,this.items, @required this.child, this.color = Colors.white, this.onLongPressed, this.disabled = false, this.direction = AnimatedButtonPopUpDirection.horizontal, this.width = 50, this.height = 50, this.popUpOffset = const Offset(0,0)});
  final bool disabled;
  final Function onPressed;
  final List<AnimatedButtonPopUpItem> items;
  final Widget child;
  final Color color;
  final Function onLongPressed;
  final AnimatedButtonPopUpDirection direction;
  final double width;
  final double height;
  final Offset popUpOffset;

  @override
  _AnimatedButtonWithPopUpState createState() => _AnimatedButtonWithPopUpState();
}

class _AnimatedButtonWithPopUpState extends State<AnimatedButtonWithPopUp> with SingleTickerProviderStateMixin{
  OverlayEntry _overlayEntry;

  double fraction = 0;
  Animation<double> animation;
  AnimationController controller;
  
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      animationBehavior: AnimationBehavior.normal,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     //
    //   }
    // })
    ;

    animation = Tween(begin: 3.0, end: 0.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutBack
    ))
    ..addListener((){
      setState(() {
        fraction = animation.value;
      });
    });

  }

  void pressAnimation(){
    controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.disabled,
      child: Padding(
        padding: EdgeInsets.only(top:fraction + 1),
        child: Opacity(
          opacity: widget.disabled ? 0.7 : 1,
          child: AnimatedContainer(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: widget.disabled ?  Offset(0,0) : Offset(0,(3 - fraction + 1) * 1.5),
                  color: Color(0xFF2E2E2E),
                  blurRadius: 0
                )
              ],
              borderRadius: BorderRadius.circular(50),
              color: widget.color,
            ),
            duration: Duration(milliseconds: 120),
            child: FlatButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.all(2),
              child: widget.child,//Image.asset("assets/images/brush.png"),
              onPressed: () {
                pressAnimation();
                widget.onPressed();
              },
              onLongPress: () {
                if (widget.onLongPressed != null) {
                  widget.onLongPressed();
                }
                if(widget.items != null && widget.items.length != 0){
                  pressAnimation();
                  this._overlayEntry = _createOverlayEntry();
                  Overlay.of(context).insert(this._overlayEntry);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);




    double boxHeight = widget.direction == AnimatedButtonPopUpDirection.horizontal ?
      widget.height : widget.height * widget.items.length;
    double boxWidth = widget.direction ==AnimatedButtonPopUpDirection.horizontal ?
      widget.width * widget.items.length : widget.width; 

    Offset boxOffset = Offset(
      offset.dx + (size.width - boxWidth)/2 + widget.popUpOffset.dx,
      offset.dy - boxHeight - 10 + widget.popUpOffset.dy
    );

    return OverlayEntry(
      builder: (context) => Positioned.fill(
        child: PopUpWidget(
          offset: boxOffset,
          width: boxWidth,
          height: boxHeight,
          direction: widget.direction,
          onHitOutside: () {
            this._overlayEntry.remove();
          },
          items: widget.items,
        )
      )
    );
  }
}

class PopUpWidget extends StatefulWidget {

  final Offset offset;
  final double height;
  final double width;
  final Function onHitOutside;
  final List<AnimatedButtonPopUpItem> items;
  final AnimatedButtonPopUpDirection direction;
  PopUpWidget({this.offset, this.height,this.width, this.onHitOutside, this.items, this.direction});
  @override
  _PopUpWidgetState createState() => _PopUpWidgetState();
}


class _PopUpWidgetState extends State<PopUpWidget> with TickerProviderStateMixin{

  double fraction = 0;
  double opacity = 1.0;
  Animation<double> animation;
  Animation<double> animationFadeOut;
  AnimationController controller;
  bool ignore = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutBack
    ))
    ..addListener((){
      setState(() {
        fraction = animation.value;
      });
    });

    controller.forward();
  }

  void removePopUp(){
    setState(() {
      ignore = true;
    });
    controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onHitOutside();
      }
    });

    animationFadeOut = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear
    ))
    ..addListener((){
      setState(() {
        opacity = animationFadeOut.value;
      });
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignore,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          if (details.localPosition.dx < widget.offset.dx || details.localPosition.dx > widget.offset.dx + widget.width
          || details.localPosition.dy < widget.offset.dy || details.localPosition.dy > widget.offset.dy + widget.height) {
            // this._overlayEntry.remove();
            removePopUp();
            //widget.onHitOutside();
          }else{
            // print("pog");
          }
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              height: widget.height * fraction,
              width: widget.width * fraction,
              left: widget.offset.dx + widget.width / 2 - (widget.width / 2) * fraction,
              top: widget.offset.dy + 50 - 50 * fraction,
              child: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(blurRadius: 15,spreadRadius: -5)
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,Colors.white
                          // Color(0xFF494984),
                          // Color(0xFF2E2E2E),
                        ]
                      ),
                      borderRadius: BorderRadius.circular(4),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.white,
                      //     offset: Offset(0, 0),
                      //     spreadRadius: 2,
                      //     blurRadius: 10
                      //   )
                      // ]
                    ),
                    // width: widget.width,
                    //height: widget.height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:11.0,vertical: 8),
                      child: widget.direction == AnimatedButtonPopUpDirection.horizontal
                      ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: widget.items.map((widget) {
                          return Flexible(
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                removePopUp();
                                widget.onPressed();
                              },
                              child: widget
                            ),
                          );
                        }).toList(),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: widget.items.map((widget) {
                          return Flexible(
                            child: FlatButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                widget.onPressed();
                                removePopUp();
                              },
                              child: widget
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class PopUpModel extends ChangeNotifier{

  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;

  set brightness(value){
    _brightness = value;
    notifyListeners();
  }

  int _speed = 10;

  int get speed => _speed;

  set speed(value){
    _speed = value;
    notifyListeners();
  }

  bool _stop = false;

  bool get stop => _stop;

  set stop(value){
    _stop = value;
    notifyListeners();
  }

  int _operations = 0;

  int get operations => _operations;

  set operations(value){
    _operations = value;
    notifyListeners();
  }

  Color brushColor1 = Colors.orangeAccent;
  Color brushColor2 = Color(0xFF2E2E2E);
  Color brushColor3 = Color(0xFF2E2E2E);
  Brush selectedBrush = Brush.wall;

  Color algColor1 = Colors.orangeAccent;
  Color algColor2 = Color(0xFF2E2E2E);
  Color algColor3 = Color(0xFF2E2E2E);
  GridGenerationFunction selectedAlg = GridGenerationFunction.maze;

  Color pAlgColor1 = Colors.lightGreen[500];
  Color pAlgColor2 = Color(0xFF2E2E2E);
  Color pAlgColor3 = Color(0xFF2E2E2E);
  Color pAlgColor4 = Color(0xFF2E2E2E);
  VisualizerAlgorithm selectedPathAlg = VisualizerAlgorithm.astar;
  
  void setActiveBrush(int i){
    switch (i) {
      case 1: //wall
        brushColor1 = Colors.orangeAccent;
        brushColor2 = Color(0xFF2E2E2E);
        brushColor3 = Color(0xFF2E2E2E);
        selectedBrush = Brush.wall;
        notifyListeners();
        break;
      case 2: //start
        brushColor1 = Color(0xFF2E2E2E);
        brushColor2 = Colors.orangeAccent;
        brushColor3 = Color(0xFF2E2E2E);
        selectedBrush = Brush.start;
        notifyListeners();
        break;
      case 3: //finish
        brushColor1 = Color(0xFF2E2E2E);
        brushColor2 = Color(0xFF2E2E2E);
        brushColor3 = Colors.orangeAccent;
        selectedBrush = Brush.finish;
        notifyListeners();
        break;
      default:
    }
  }

  void setActiveAlgorithm(int i){
    switch (i) {
      case 1: //maze
        algColor1 = Colors.orangeAccent;
        algColor2 = Color(0xFF2E2E2E);
        algColor3 = Color(0xFF2E2E2E);
        selectedAlg = GridGenerationFunction.maze;
        notifyListeners();
        break;
      case 2: //random
        algColor1 = Color(0xFF2E2E2E);
        algColor2 = Colors.orangeAccent;
        algColor3 = Color(0xFF2E2E2E);
        selectedAlg = GridGenerationFunction.random;
        notifyListeners();
        break;
      case 3: //recursive
        algColor1 = Color(0xFF2E2E2E);
        algColor2 = Color(0xFF2E2E2E);
        algColor3 = Colors.orangeAccent;
        selectedAlg = GridGenerationFunction.recursive;
        notifyListeners();
        break;
      default:
    }
  }

  void setActivePAlgorithm(int i){
    switch (i) {
      case 1: //astar
        pAlgColor1 = Colors.lightGreen[500];
        pAlgColor2 = Color(0xFF2E2E2E);
        pAlgColor3 = Color(0xFF2E2E2E);
        pAlgColor4 = Color(0xFF2E2E2E);
        selectedPathAlg = VisualizerAlgorithm.astar;
        notifyListeners();
        break;
      case 2: //dijkstra
        pAlgColor1 = Color(0xFF2E2E2E);
        pAlgColor2 = Colors.lightGreen[500];
        pAlgColor3 = Color(0xFF2E2E2E);
        pAlgColor4 = Color(0xFF2E2E2E);
        selectedPathAlg = VisualizerAlgorithm.dijkstra;
        notifyListeners();
        break;
      case 3: //dfs
        pAlgColor1 = Color(0xFF2E2E2E);
        pAlgColor2 = Color(0xFF2E2E2E);
        pAlgColor3 = Colors.lightGreen[500];
        pAlgColor4 = Color(0xFF2E2E2E);
        selectedPathAlg = VisualizerAlgorithm.dfs;
        notifyListeners();
        break;
      case 4: //bfs
        pAlgColor1 = Color(0xFF2E2E2E);
        pAlgColor2 = Color(0xFF2E2E2E);
        pAlgColor3 = Color(0xFF2E2E2E);
        pAlgColor4 = Colors.lightGreen[500];
        selectedPathAlg = VisualizerAlgorithm.bfs;
        notifyListeners();
        break;
      default:
    }
  }

}

class AnimatedButtonPopUpItem extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  const AnimatedButtonPopUpItem({Key key, this.onPressed, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}