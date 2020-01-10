import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'package:provider/provider.dart';
import 'package:zoom_widget/zoom_widget.dart';

class GridGestureDetector extends StatefulWidget {

  GridGestureDetector({
    this.child, 
    this.onScaleUpdate, 
    this.width, this.height, 
    this.onDragNode, 
    this.onTapNode,
    this.unitSize,
    this.rows,
    this.columns,
    this.nodeTypes, 
    this.onDragNodeEnd});
  final List<List<int>> nodeTypes;
  final int rows;
  final int columns;
  final double unitSize;
  final double width;
  final double height;
  final Widget child;
  final void Function(double scale, double zoon) onScaleUpdate;

  final Function(int i, int j) onTapNode;
  final Function(int i, int j, int k , int l, int type) onDragNode;
  final Function onDragNodeEnd;

  @override
  _GridGestureDetectorState createState() => _GridGestureDetectorState();
}

class _GridGestureDetectorState extends State<GridGestureDetector> {

  int i;
  int j;

  int snapToGrid(double gridSize, double position, int maxSize){
    var numb = position/gridSize;
    int pos = numb.floor().clamp(0, maxSize);
    return pos;
  }

  void dragUpdate(var details){
    var newi = snapToGrid(widget.unitSize + 1, details.dx, widget.rows - 1);
    var newj = snapToGrid(widget.unitSize + 1, details.dy, widget.columns - 1);

    if (newi != i || newj != j) {
      var type = widget.nodeTypes[i][j];
      widget.onDragNode(i,j,newi,newj, type);
    }
    i = newi;
    j = newj;
  }

  void tapUpdate(var details){
    i = snapToGrid(widget.unitSize + 1, details.dx, widget.rows - 1);
    j = snapToGrid(widget.unitSize + 1, details.dy, widget.columns - 1);
    widget.onTapNode(i,j);
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<Grid>(
      builder: (_, grid, __) {
        return Zoom(
          scrollWeight: 4,
          backgroundColor: Colors.white,
          initZoom: 0.03,
          centerOnScale: true,
          doubleTapZoom: false,
          width: widget.width,
          height: widget.height,
          onScaleUpdate: (scale,zoom) => widget.onScaleUpdate(scale,zoom),
          child: IgnorePointer(
            ignoring: grid.isPanning,
            child: GestureDetector(
              // onSecondaryTapDown: (details){
              //   tapUpdate(details.localPosition);
              // },
              onLongPressMoveUpdate: (details) {
                dragUpdate(details.localPosition);
              },
              onScaleUpdate: (details) {
                if (details.scale == 1.0) {
                  dragUpdate(details.localFocalPoint);
                }
              },
              onTapDown: (details) {
                tapUpdate(details.localPosition);
              },
              onScaleStart: (details) {
                tapUpdate(details.localFocalPoint);
              },
              onScaleEnd: (details){
                widget.onDragNodeEnd();
              },
              onTapUp: (details){
                widget.onDragNodeEnd();
              },
              onLongPressUp: (){
                widget.onDragNodeEnd(); 
              },
              onLongPressStart: (details){
                tapUpdate(details.localPosition);
              },
              child: widget.child
            )
          )
        );
      }
    );
  }
}