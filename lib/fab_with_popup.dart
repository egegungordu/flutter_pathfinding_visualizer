
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';

class FabWithPopUp extends StatefulWidget {
  FabWithPopUp({@required this.onPressed,this.items, @required this.child, this.color = Colors.white, this.onLongPressed, this.disabled = false, this.direction = AnimatedButtonPopUpDirection.horizontal, this.width = 50, this.height = 50, this.popUpOffset = const Offset(0,0)});
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
  _FabWithPopUpState createState() => _FabWithPopUpState();
}

class _FabWithPopUpState extends State<FabWithPopUp> with SingleTickerProviderStateMixin{
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.disabled,
      child: Opacity(
        opacity: widget.disabled ? 0.7 : 1,
        child: AnimatedContainer(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: widget.disabled ? 0 : 10,
                spreadRadius: 0,
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
              widget.onPressed();
            },
            onLongPress: () {
              if (widget.onLongPressed != null) {
                widget.onLongPressed();
              }
              if(widget.items != null && widget.items.length != 0){
                this._overlayEntry = _createOverlayEntry();
                Overlay.of(context).insert(this._overlayEntry);
              }
            },
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
// class PopUpModel extends ChangeNotifier{
  
//   Color brushColor1 = Colors.orangeAccent;
//   Color brushColor2 = Color(0xFF2E2E2E);
//   Color brushColor3 = Color(0xFF2E2E2E);
//   Brush selectedBrush = Brush.wall;

//   Color algColor1 = Colors.orangeAccent;
//   Color algColor2 = Color(0xFF2E2E2E);
//   Color algColor3 = Color(0xFF2E2E2E);
//   GridGenerationFunction selectedAlg = GridGenerationFunction.maze;
  
//   void setActiveBrush(int i){
//     switch (i) {
//       case 1: //wall
//         brushColor1 = Colors.orangeAccent;
//         brushColor2 = Color(0xFF2E2E2E);
//         brushColor3 = Color(0xFF2E2E2E);
//         selectedBrush = Brush.wall;
//         notifyListeners();
//         break;
//       case 2: //start
//         brushColor1 = Color(0xFF2E2E2E);
//         brushColor2 = Colors.orangeAccent;
//         brushColor3 = Color(0xFF2E2E2E);
//         selectedBrush = Brush.start;
//         notifyListeners();
//         break;
//       case 3: //finish
//         brushColor1 = Color(0xFF2E2E2E);
//         brushColor2 = Color(0xFF2E2E2E);
//         brushColor3 = Colors.orangeAccent;
//         selectedBrush = Brush.finish;
//         notifyListeners();
//         break;
//       default:
//     }
//   }

//   void setActiveAlgorithm(int i){
//     switch (i) {
//       case 1: //wall
//         algColor1 = Colors.orangeAccent;
//         algColor2 = Color(0xFF2E2E2E);
//         algColor3 = Color(0xFF2E2E2E);
//         selectedAlg = GridGenerationFunction.maze;
//         notifyListeners();
//         break;
//       case 2: //start
//         algColor1 = Color(0xFF2E2E2E);
//         algColor2 = Colors.orangeAccent;
//         algColor3 = Color(0xFF2E2E2E);
//         selectedAlg = GridGenerationFunction.random;
//         notifyListeners();
//         break;
//       case 3: //finish
//         algColor1 = Color(0xFF2E2E2E);
//         algColor2 = Color(0xFF2E2E2E);
//         algColor3 = Colors.orangeAccent;
//         selectedAlg = GridGenerationFunction.recursive;
//         notifyListeners();
//         break;
//       default:
//     }
//   }

// }
