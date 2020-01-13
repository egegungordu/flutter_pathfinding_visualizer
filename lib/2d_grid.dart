import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/gesture_handler.dart';
import 'package:flutter_2d_grid/node_widgets.dart';
import 'package:provider/provider.dart';


// class Nodes{

//   static const Node wallNode = Node(
//     nodeWidget: WallNodePaintWidget(unitSize, i, j, callback, removeNode)
//   );
// }
// class Node{
//   const Node({this.nodeWidget,this.type,this.staticRect});
//   final Widget nodeWidget;
//   final int type;
//   final Rect staticRect;
// }
enum GridGenerationFunction{
  random,
  maze,
  recursive,
}

enum VisualizerAlgorithm{
  astar,
  dijkstra,
  dfs,
  bfs
}

enum Brush{
  wall,
  start,
  finish,
  closed,
  open
}

class Grid extends ChangeNotifier{

  Grid(this.rows,this.columns, this.unitSize, this.starti, this.startj, this.finishi, this.finishj){
    nodeTypes = List.generate(rows, (_) => List.filled(columns, 0));
    nodes = List.generate(rows, (_) => List.filled(columns, null));
    staticNodes = List.generate(rows, (_) => List.filled(columns, null));

    // double xBox = (width - rows - 1) / rows;
    // double yBox = (height - columns - 1) / columns;
    width = unitSize * rows + rows + 1;
    height = unitSize * columns + columns + 1;
    //unitSize = min(yBox, xBox);
    addNode(starti, startj, Brush.start);
    addNode(finishi, finishj, Brush.finish);
  }

  int starti;
  int startj;
  int finishi;
  int finishj;

  double width;
  double height;
  final int rows;
  final int columns;

  bool _isPanning = false;
  double scale = 1;
  final double unitSize;
  List<List<Widget>> nodes;
  List<List<int>> nodeTypes;
  List<List<Rect>> staticNodes;

  Widget gridWidget({
    Function(int i, int j) onTapNode, 
    Function(int i, int j, int k , int l, int type) onDragNode, 
    Function(double scale, double zoom) onScaleUpdate,
    Function onDragNodeEnd}){
    return ChangeNotifierProvider.value(
      value: this,
      child: GridGestureDetector(
        width: width,
        height: height,
        onDragNode: (i,j,k,l,t) =>onDragNode(i,j,k,l,t),
        onTapNode: (i,j) => onTapNode(i,j),
        unitSize: unitSize,
        rows: rows,
        columns: columns,
        nodeTypes: nodeTypes,
        onScaleUpdate: (scale,zoom) => 0,//updateDecorationScale(scale),
        onDragNodeEnd: () => onDragNodeEnd(),
        child: GridWidget(rows,columns,unitSize,width,height)
      ),
    );
  }

  bool boundaryCheckFailed(int i, int j) {
    if (i > rows - 1 || i < 0 || j > columns - 1 || j < 0) {
      return true;
    }
    return false;
  }

  void _updateStaticNode(int i, int j, Rect rect){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    staticNodes[i][j] = rect;
    notifyListeners();
  }

  void clearPaths(){
    //nodeTypes.forEach((f) => f.where((f) => f == 4 || f == 5).forEach((f) => 0));
    for (var i = 0; i < nodeTypes.length; i++) {
      for (var j = 0; j < nodeTypes[0].length; j++) {
        removePath(i, j);
        removePath(i, j);
      }
    }
  }

  void addNodeWidgetOnly(int i, int j, Brush type){
    switch (type) {
      case Brush.start:
      nodes[i][j] = Positioned(
          key: UniqueKey(),
          left: 0.50 + i * (unitSize.toDouble() + 1),
          top: 0.50 + j * (unitSize.toDouble() + 1),
          child: NodeImageWidget(unitSize, "assets/images/start_node.png")
        );
        break;
      case Brush.finish:
      nodes[i][j] = Positioned(
          key: UniqueKey(),
          left: 0.50 + i * (unitSize.toDouble() + 1),
          top: 0.50 + j * (unitSize.toDouble() + 1),
          child: NodeImageWidget(unitSize, "assets/images/end_node.png")
        );
        break;
      default:
    }
    notifyListeners();
  }

  void addNode(int i, int j, Brush type){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    if(nodeTypes[i][j] == 0 || nodeTypes[i][j] == 4 || nodeTypes[i][j] == 5){
      switch (type) {
        case Brush.wall:
          nodeTypes[i][j] = 1;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: WallNodePaintWidget(unitSize, i, j, (i, j, rect) {
              _updateStaticNode(i, j, rect);
            },
            (i, j) {
              removeNodeWidgetOnly(i, j);
            })
          );
          break;
        case Brush.start:
          nodeTypes[i][j] = 2;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: NodeImageWidget(unitSize, "assets/images/start_node.png")
          );
          break;
        case Brush.finish:
          nodeTypes[i][j] = 3;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: NodeImageWidget(unitSize, "assets/images/end_node.png")
          );
          break;
        case Brush.open:
        nodeTypes[i][j] = 4;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: OpenNodePaintWidget(unitSize)
          );
          break;
        case Brush.closed:
        nodeTypes[i][j] = 5;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: ClosedNodePaintWidget(unitSize)
          );
          break;
          
        default:
      }
      notifyListeners();
    }else if (nodeTypes[i][j] == 1 && (type == Brush.start || type == Brush.finish)) {
      switch (type) {
        case Brush.finish:
          removeNode(i, j, 1);
          nodeTypes[i][j] = 3;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: NodeImageWidget(unitSize, "assets/images/end_node.png")
          );
          break;
        case Brush.start:
          removeNode(i, j, 1);
          nodeTypes[i][j] = 2;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: NodeImageWidget(unitSize, "assets/images/start_node.png")
          );
          break;
        default:
      }
      notifyListeners();
    }
  }


  void removeNodeWidgetOnly(int i, int j){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    nodes[i][j] = null;
    notifyListeners();
  }

  void removeNode(int i, int j, int t){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    staticNodes[i][j] = null;
    if (nodeTypes[i][j] == t) {
      staticNodes[i][j] = null;
      nodeTypes[i][j] = 0;
      nodes[i][j] = null;
      notifyListeners();
    }
  }

  void removePath(int i, int j){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    if (nodeTypes[i][j] == 4 || nodeTypes[i][j] == 5) {
      staticNodes[i][j] = null;
      nodeTypes[i][j] = 0;
      nodes[i][j] = null;
      notifyListeners();
    }
  }


  void generateBoard({@required GridGenerationFunction function, @required Function onFinished}){
    int i = 0;
    int j = 0;
    switch (function) {
      case GridGenerationFunction.random:
        Timer.periodic(Duration(microseconds: 1000), (timer) {
          removeNode(i, j, 1);
          if (Random().nextDouble() < 0.3) {
            addNode(i, j, Brush.wall);
          }
          i++;
          if (i == nodeTypes.length) {
            i = 0;
            j++;
          }
          if (j == nodeTypes[0].length) {
            onFinished();
            timer.cancel();
            return;
          }
        });
        break;
      default:
    }
  }

  void hoverSpecialNode(int i, int j, Brush type){
    if (nodeTypes[i][j] == 2 || nodeTypes[i][j] == 3 ) {
      return;
    }
    switch (type) {
      case Brush.start:
        if (starti != i || startj != j) {
          addNodeWidgetOnly(i, j, Brush.start);
          removeNodeWidgetOnly(starti, startj);
          if (nodeTypes[starti][startj] == 2) {
            removeNode(starti, startj, 2);
          }
          starti = i;
          startj = j;
        }
        break;
      case Brush.finish:
        if (finishi != i || finishj != j) {
          addNodeWidgetOnly(i, j, Brush.finish);
          removeNodeWidgetOnly(finishi, finishj);
          if (nodeTypes[finishi][finishj] == 3) {
            removeNode(finishi, finishj, 3);
          }
          finishi = i;
          finishj = j;
        }
        break;
      default:
    }
  }

  void addSpecialNode(Brush type){
    print("Start $starti $startj\nFinish $finishi $finishj");
    switch (type) {
      case Brush.start:
        addNode(starti, startj, Brush.start);
        break;
      case Brush.finish:
        addNode(finishi, finishj, Brush.finish);
        break;
      default:
    }
  }

  void clearBoard({Function onFinished}){
    int i = 0;
    int j = 0;
    clearPaths();
    Timer.periodic(Duration(microseconds: 1000), (timer) {
      removeNode(i, j, 1);
      i++;
      if (i == nodeTypes.length) {
        i = 0;
        j++;
      }
      if (j == nodeTypes[0].length) {
        onFinished();
        timer.cancel();
      }
    });
  }

  bool get isPanning => _isPanning;

  set isPanning(bool value){
    _isPanning = value;
    notifyListeners();
  }

  void updateDecorationScale(double value){
    scale = value;
    notifyListeners();
  }
}

class GridWidget extends StatefulWidget {
  GridWidget(this.rows,this.columns,this.unitSize,this.width, this.height);
  final int rows;
  final int columns;
  final double unitSize;
  final double width;
  final double height;

  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {

  @override
  Widget build(BuildContext context) {
    print("grid built");
    return Stack(
      children: <Widget>[
        FittedBox(
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Consumer<Grid>(
              builder: (_,grid,__){
                return CustomPaint(
                  painter: GridPainter(widget.rows, widget.columns, widget.unitSize, widget.width, widget.height, context, grid.scale)
                );
              },
            ),
          ),
        ),
        Consumer<Grid>(
          builder: (_,grid,__) {
            return CustomPaint(
              painter: StaticNodePainter(grid.staticNodes)
            );
          },
        ),
        Consumer<Grid>(
          builder: (_,grid,__) {
            return Stack(
              children: <Widget>[
                ...grid.nodes
                    .expand((row) => row)
                    .toList()
                    .where((w) => w != null)
              ],
            );
          },
        ),
      ],
    );
  }
}

class StaticNodePainter extends CustomPainter {
  StaticNodePainter(this.staticNodes);
  List<List<Rect>> staticNodes;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    paint.color = Colors.grey.shade900;
    
    staticNodes
      .expand((row) => row)
      .toList()
      .where((rect) => rect != null)
      .forEach((rect) => canvas.drawRect(rect, paint));
  }

  @override
  bool shouldRepaint(StaticNodePainter oldDelegate) {
    return true;
  }
} 

class GridPainter extends CustomPainter {
  GridPainter(this.rows, this.columns, this.unitSize, this.width, this.height, this.context, this.scale);
  final double scale;
  final BuildContext context;
  final int rows;
  final int columns;
  final double unitSize;
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    var background = Rect.fromLTRB(0, 0, size.width, size.height);
    paint.color = Theme.of(context).scaffoldBackgroundColor;
    canvas.drawRect(background, paint);

    paint.color = Theme.of(context).primaryColor;
    paint.strokeWidth = 1/scale * 1;

    for (var i = 0; i < rows+1; i++) {
      canvas.drawLine(
        Offset(i.toDouble() * (unitSize + 1) + 0.5, 0),
        Offset(i.toDouble() * (unitSize + 1) + 0.5, height),
        paint);
    }

    for (var i = 0; i < columns+1; i++) {
      canvas.drawLine(
        Offset(0, i.toDouble() * (unitSize + 1) + 0.5),
        Offset(width, i.toDouble() * (unitSize + 1) + 0.5),
        paint);
    }
  }
  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}