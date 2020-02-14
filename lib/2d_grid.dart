import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/algorithms.dart';
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
  backtracker,
  recursive,
}

enum VisualizerAlgorithm{
  astar,
  dijkstra,
  bidir_dijkstra
}

enum Brush{
  wall,
  start,
  finish,
  closed,
  open,
  shortestPath
}

class Grid extends ChangeNotifier{

  Grid(this.rows,this.columns, this.unitSize, this.starti, this.startj, this.finishi, this.finishj){
    nodeTypes = List.generate(rows, (_) => List.filled(columns, 0));
    nodes = List.generate(rows, (_) => List.filled(columns, null));
    staticNodes = List.generate(rows, (_) => List.filled(columns, null));
    staticShortPathNode = List.generate(rows, (_) => List.filled(columns, null));

    // double xBox = (width - rows - 1) / rows;
    // double yBox = (height - columns - 1) / columns;
    width = unitSize * rows + rows + 1;
    height = unitSize * columns + columns + 1;
    //unitSize = min(yBox, xBox);
    addNode(starti, startj, Brush.start);
    addNode(finishi, finishj, Brush.finish);
    _currentNode = Node(finishi, finishj);
    _currentSecondNode = Node(starti, startj);
  }

  int starti;
  int startj;
  int finishi;
  int finishj;

  Node _currentNode;
  Node _currentSecondNode;

  double width;
  double height;
  final int rows;
  final int columns;

  bool _isPanning = false;
  double scale = 1;
  final double unitSize;
  List<List<Widget>> nodes;
  List<List<int>> nodeTypes;
  List<List<Color>> staticNodes;
  List<List<Color>> staticShortPathNode;

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
        child: GridWidget(rows,columns,unitSize,width,height),
      ),
    );
  }

  bool boundaryCheckFailed(int i, int j) {
    if (i > rows - 1 || i < 0 || j > columns - 1 || j < 0) {
      return true;
    }
    return false;
  }

  void _updateStaticNode(int i, int j, Color color){
    if(boundaryCheckFailed(i, j)){
      return;
    }
    staticNodes[i][j] = color;
    notifyListeners();
  }

  void clearPaths(){
    _currentSecondNode = Node(0, 0);
    _currentNode = Node(0, 0);
    //nodeTypes.forEach((f) => f.where((f) => f == 4 || f == 5).forEach((f) => 0));
    staticShortPathNode = List.generate(rows, (_) => List.filled(columns, null));
    for (var i = nodeTypes.length - 1; i > -1; i--) {
      for (var j = nodeTypes[0].length - 1; j > -1; j--) {
        removePath(i, j);
        //removePath(i, j);
      }
    }
  }

  void fillWithWall(){
    for (var i = 0; i < nodeTypes.length; i++) {
      for (var j = 0; j < nodeTypes[0].length; j++) {
        nodeTypes[i][j] = 1;
      }
    }
    staticNodes.forEach((l) => l.fillRange(0, nodeTypes[0].length-1,Color(0xff212121)));
    nodeTypes[starti][startj] = 2;
    nodeTypes[endi][endj] = 3;
    staticNodes[starti][startj] = null;
    staticNodes[endi][endj] = null;
    notifyListeners();
  }

  void addNodeWidgetOnly(int i, int j, Brush type){
    switch (type) {
      case Brush.start:
      nodes[i][j] = Positioned(
          key: UniqueKey(),
          left: 0.50 + i * (unitSize.toDouble() + 1),
          top: 0.50 + j * (unitSize.toDouble() + 1),
          child: NodeImageWidget(unitSize, "assets/images/start_node.png",)
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
            child: WallNodePaintWidget(
              color: Color(0xff212121),
              unitSize: unitSize,
              i: i,
              j: j,
              callback: (i, j, color) {
                _updateStaticNode(i, j, color);
                removeNodeWidgetOnly(i, j);
              },
            )
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
          _updateStaticNode(i, j, Colors.cyan.withOpacity(0.8));
          // nodes[i][j] = Positioned(
          //   key: UniqueKey(),
          //   left: 0.50 + i * (unitSize.toDouble() + 1),
          //   top: 0.50 + j * (unitSize.toDouble() + 1),
          //   child: VisitedNodePaintWidget(
          //     color: Colors.cyan.withOpacity(0.8),
          //     unitSize: unitSize,
          //     i: i,
          //     j: j,
          //     callback: (i, j, color) {
          //       if (nodeTypes[i][j] == 4) {
          //         _updateStaticNode(i, j, color);
          //         removeNodeWidgetOnly(i, j);
          //       }
          //     },
          //   )
          // );
          break;
        case Brush.closed:
          nodeTypes[i][j] = 5;
          nodes[i][j] = Positioned(
            key: UniqueKey(),
            left: 0.50 + i * (unitSize.toDouble() + 1),
            top: 0.50 + j * (unitSize.toDouble() + 1),
            child: VisitedNodePaintWidget(
              color: Colors.red.withOpacity(0.8),
              unitSize: unitSize,
              i: i,
              j: j,
              callback: (i, j, color) {
                if (nodeTypes[i][j] == 5) {
                  _updateStaticNode(i, j, color);
                  removeNodeWidgetOnly(i, j);
                }
              },
            )
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

  void drawPath(Node lastNode){
    staticShortPathNode = List.generate(rows, (_) => List.filled(columns, null));

    Node currentNode = lastNode;
    while (currentNode.parent != null) {
      staticShortPathNode[currentNode.i][currentNode.j] = Colors.amber;
      currentNode = currentNode.parent;
    }
    staticShortPathNode[currentNode.i][currentNode.j] = Colors.amber;
    notifyListeners();
  }

  void drawPath2(Node lastNode){
    _currentNode = lastNode;
    notifyListeners();
  }

  void drawSecondPath2(Node lastNode){
    _currentSecondNode = lastNode;
    notifyListeners();
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
      nodeTypes[i][j] = 0;
      nodes[i][j] = null;
      notifyListeners();
    }
  }

  void removePath(int i, int j){
    if (nodeTypes[i][j] == 4 || nodeTypes[i][j] == 5) {
      staticNodes[i][j] = null;
      nodeTypes[i][j] = 0;
      nodes[i][j] = null;
      notifyListeners();
    }
  }


  void generateBoard({@required GridGenerationFunction function, @required Function onFinished,  @required Function callback}){
    int i = 0;
    int j = 0;
    clearPaths();
    switch (function) {
      case GridGenerationFunction.random:
        Timer.periodic(Duration(microseconds: 10), (timer) {
          if (callback()) {
            timer.cancel();
          }
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

  double currentPosX;
  double currentPosY;

  void putCurrentNode(int i,int j){
    currentPosX = 0.50 + i * (unitSize.toDouble() + 1);
    currentPosY = 0.50 + j * (unitSize.toDouble() + 1);
  }

  void clearBoard({Function onFinished}){
    int i = 0;
    int j = 0;
    clearPaths();
    for (var i = 0; i < nodeTypes.length; i++) {
      for (var j = 0; j < nodeTypes[0].length; j++) {
        removeNode(i, j, 1);
      }
    }
    // Timer.periodic(Duration(microseconds: 1000), (timer) {
    //   removeNode(i, j, 1);
    //   i++;
    //   if (i == nodeTypes.length) {
    //     i = 0;
    //     j++;
    //   }
    //   if (j == nodeTypes[0].length) {
    //     onFinished();
    //     timer.cancel();
    //   }
    // });
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

    final grid = FittedBox(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: GridPainter(widget.rows, widget.columns, widget.unitSize, widget.width, widget.height, context)
        ),
      ),
    );
    print("grid built");
    return Stack(
      children: <Widget>[
        grid,
        Selector<Grid,List<List<Color>>>(
          selector: (_,model) => model.staticNodes,
          builder: (_,staticNodes,__) {
            return CustomPaint(
              painter: StaticNodePainter(staticNodes,widget.unitSize)
            );
          },
        ),
        // Consumer<Grid>(
        //   builder: (_,grid,__) {
        //     return CustomPaint(
        //       painter: StaticNodePainter(grid.staticShortPathNode,widget.unitSize)
        //     );
        //   },
        // ),
        Selector<Grid,Node>(
          selector: (_,model) => model._currentNode,
          builder: (_,currentNode,__) {
            return CustomPaint(
              painter: PathPainter(currentNode,widget.unitSize),
            );
          },
        ),
        Selector<Grid,Node>(
          selector: (_,model) => model._currentSecondNode,
          builder: (_,currentNode,__) {
            return CustomPaint(
              painter: SecondPathPainter(currentNode,widget.unitSize),
            );
          },
        ),
        Selector<Grid,List<List<Widget>>>(
          selector: (_,model) => model.nodes,
          shouldRebuild: (a,b) => true,
          builder: (_,nodes,__) {
            return Stack(
              children: <Widget>[
                ...nodes
                    .expand((row) => row)
                    .toList()
                    .where((w) => w != null)
              ],
            );
          },
        ),
        // Consumer<Grid>(
        //   builder: (_,model,__) {
        //     return Positioned(
        //       left: model.currentPosX,
        //       top: model.currentPosY,
        //       child: Container(
        //         color: Colors.red,
        //         width: widget.unitSize+1,
        //         height: widget.unitSize+1,
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}

class StaticNodePainter extends CustomPainter {
  StaticNodePainter(this.staticNodes, this.unitSize);
  List<List<Color>> staticNodes;
  final double unitSize;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    for (var i = 0; i < staticNodes.length; i++) {
      for (var j = 0; j < staticNodes[0].length; j++) {
        if (staticNodes[i][j] != null) {
          canvas.drawRect(
            Rect.fromLTWH((unitSize +1) * i, (unitSize +1) * j, unitSize + 2, unitSize + 2), 
            paint..color = staticNodes[i][j]
          );
        }
      }
    }
    
    // staticNodes
    //   .expand((row) => row)
    //   .toList()
    //   .where((rect) => rect != null)
    //   .forEach((rect) => canvas.drawRect(rect, paint));
  }

  @override
  bool shouldRepaint(StaticNodePainter oldDelegate) {
    return true;
  }
} 

class GridPainter extends CustomPainter {
  const GridPainter(this.rows, this.columns, this.unitSize, this.width, this.height, this.context);
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

    paint.color = Theme.of(context).primaryColorLight;
    paint.strokeWidth = 1;

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

class PathPainter extends CustomPainter {
  PathPainter(this.currentNode, this.unitSize);
  final double unitSize;
  final Node currentNode;
  Node drawingNode;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    Path path = Path();
    drawingNode = currentNode;
    path.moveTo(currentNode.i* (unitSize + 1) + unitSize/2, currentNode.j* (unitSize + 1) + unitSize/2);
    while (drawingNode.parent != null) {
      drawingNode = drawingNode.parent;
      path.lineTo(drawingNode.i* (unitSize + 1) + unitSize/2, drawingNode.j* (unitSize + 1) + unitSize/2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) {
    return oldDelegate.currentNode != currentNode ? true : false;
  }
}

class SecondPathPainter extends CustomPainter {
  SecondPathPainter(this.currentNode, this.unitSize);
  final double unitSize;
  final Node currentNode;
  Node drawingNode;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    Path path = Path();
    drawingNode = currentNode;
    path.moveTo(currentNode.i* (unitSize + 1) + unitSize/2, currentNode.j* (unitSize + 1) + unitSize/2);
    while (drawingNode.parent2 != null) {
      drawingNode = drawingNode.parent2;
      path.lineTo(drawingNode.i* (unitSize + 1) + unitSize/2, drawingNode.j* (unitSize + 1) + unitSize/2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SecondPathPainter oldDelegate) {
    return oldDelegate.currentNode != currentNode ? true : false;
  }
}
