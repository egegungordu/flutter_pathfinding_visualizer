import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'dart:math' as math;

List<List<int>> grid;
List<List<Node>> nodes;

int x;
int y;

int endi = 0;
int endj = 0;

int starti = 0;
int startj = 0;


class Node{
  Node(this.i, this.j){
    this.h = heuristic(i,j);
  }
  final int i;
  final int j;

  double f;
  double g = double.infinity;
  double h;

  Node parent;

  bool visited = false;

  List<Node> get neighbors{
    List<Node> neighbors = <Node>[];
    if (i > 0 && grid[i-1][j] != 1) { //left
      neighbors.add(nodes[i-1][j]);
    }
    if (i < x-1 && grid[i + 1][j] != 1) { //right
      neighbors.add(nodes[i + 1][j]);
    }
    if (j > 0 && grid[i][j-1] != 1) { //top
      neighbors.add(nodes[i][j-1]);
    }
    if (j < y-1 && grid[i][j+1] != 1) { //bottom
      neighbors.add(nodes[i][j + 1]);
    }
    if (i > 0 && j > 0 && (grid[i-1][j] == 0 || grid[i][j-1] == 0) && grid[i-1][j-1] != 1) { //topleft
      neighbors.add(nodes[i-1][j-1]);
    }
    if (i < x-1 && j > 0 && (grid[i+1][j] == 0 || grid[i][j-1] == 0) && grid[i+1][j-1] != 1) { //topright
      neighbors.add(nodes[i+1][j-1]);
    }
    if (i > 0 && j < y-1 && (grid[i-1][j] == 0 || grid[i][j+1] == 0) && grid[i-1][j+1] != 1) { //bottomleft
      neighbors.add(nodes[i-1][j+1]);
    }
    if (i < x-1 && j < y-1 && (grid[i+1][j] == 0 || grid[i][j+1] == 0) && grid[i+1][j+1] != 1) { //bottomright
      neighbors.add(nodes[i+1][j+1]);
    }
    return neighbors;
  }
}

class PathfindAlgorithms{

  static void visualize({
    VisualizerAlgorithm algorithm, 
    List<List<int>> gridd, 
    int startti,
    int starttj,
    int finishi,
    int finishj,
    Function(int i, int j) onShowClosedNode, 
    Function(int i, int j) onShowOpenNode,
    bool Function(Node lastNode, int count) onDrawPath,
    Function() onFinished,
    int Function() speed}){

    endi = finishi;
    endj = finishj;

    starti = startti;
    startj = starttj;

    x = gridd.length;
    y = gridd[0].length;

    grid = gridd;
    nodes = List.generate(x, (i) => List.generate(y, (j) => Node(i, j)));

    switch (algorithm) {
      case VisualizerAlgorithm.astar:
        astar(onShowClosedNode,onShowOpenNode,onFinished,onDrawPath, speed);
        break;
      case VisualizerAlgorithm.dijkstra:
        dijkstra(onShowClosedNode,onShowOpenNode,onFinished,onDrawPath, speed);
        break;
      case VisualizerAlgorithm.bfs:
        bfs(onShowClosedNode,onShowOpenNode,onFinished,onDrawPath);
        break;
      default:
    }
  }
  //await Future.delayed(Duration(seconds: 1));
  static void astar(Function onShowClosedNode, Function onShowOpenNode, Function onFinished, Function onDrawPath, Function speed) async{
    int c = 0;

    List<Node> openSet = <Node>[];
    List<Node> closedSet = <Node>[];
    
    Node startNode = nodes[starti][startj];
    startNode.g = 0;
    startNode.f = startNode.g + startNode.h;
    openSet.add(startNode);

    int mils;
    while(openSet.isNotEmpty) {
      int smallest = 0;
      for (int i = 0; i < openSet.length; ++i) {
        if (openSet[i].f < openSet[smallest].f) {
          smallest = i;
        }
      }
      Node currentNode = openSet[smallest];
      if(onDrawPath(currentNode, c)){
        break;
      }
      
      openSet.remove(currentNode);

      for (Node neighbor in currentNode.neighbors) {
        double tentativeGScore = currentNode.g + distance(currentNode.i,currentNode.j,neighbor.i,neighbor.j);
        if (!closedSet.contains(neighbor) && (!openSet.contains(neighbor) || tentativeGScore < neighbor.g)) {
          c++;
          neighbor.parent = currentNode;
          neighbor.g = tentativeGScore;
          neighbor.f = neighbor.g + neighbor.h;
          if (neighbor.i == endi && neighbor.j == endj) {
            onFinished();
            onDrawPath(neighbor, c);
            openSet.clear();
            break;
          }
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
            onShowOpenNode(neighbor.i,neighbor.j);
          }
        }
      } 
      closedSet.add(currentNode);
      onShowClosedNode(currentNode.i,currentNode.j);
      mils = speed();
      await Future.delayed(Duration(milliseconds: mils));
    }
    onFinished();
  }

  static void dijkstra(Function onShowClosedNode, Function onShowOpenNode, Function onFinished, Function onDrawPath, Function speed) async{
    int c = 0;

    List<Node> queue = <Node>[];

    Node startNode = nodes[starti][startj];
    startNode.g = 0;
    queue.add(startNode);
    
    int mils;

    while (queue.isNotEmpty) {
      int smallest = 0;
      for (int i = 0; i < queue.length; ++i) {
        if (queue[i].g < queue[smallest].g) {
          smallest = i;
        }
      }
      Node currentNode = queue[smallest];
      if(onDrawPath(currentNode, c)){
        break;
      }

      queue.remove(currentNode);
      currentNode.visited = true;
      onShowClosedNode(currentNode.i,currentNode.j);
      for (Node neighbor in currentNode.neighbors) {
        double tentativeGScore = currentNode.g + distance(currentNode.i,currentNode.j,neighbor.i,neighbor.j);
        if (!neighbor.visited && tentativeGScore < neighbor.g) {
          c++;
          neighbor.parent = currentNode;
          neighbor.g = tentativeGScore;
          if (neighbor.i == endi && neighbor.j == endj) {
            onFinished();
            onDrawPath(neighbor, c);
            queue.clear();
            break;
          }
          queue.add(neighbor);
          onShowOpenNode(neighbor.i,neighbor.j);
        }
      }
      mils = speed();
      await Future.delayed(Duration(milliseconds: mils));
    }
    onFinished();
  }

  static void bfs(Function onShowClosedNode, Function onShowOpenNode, Function onFinished, Function onDrawPath) async{
    int mils = 3000;
    while (mils > 1) {
      await Future.delayed(Duration(milliseconds: mils));
      mils = mils ~/2;
    }
    onFinished();
  }

  
}

const double d1 = 1;
const double d2 = math.sqrt2;

double heuristic(int i, int j){
  var dx = (i-endi).abs();
  var dy = (j-endj).abs();
  //return d1 * (dx + dy);
  //return math.sqrt(dx *dx + dy * dy);
  return d1 * (dx + dy) + (d2 - 2 * d1) * math.min(dx, dy);
  // return math.sqrt(math.pow((i-endi), 2) + math.pow((j-endj), 2)).toDouble();
}

double distance(int i, int j, int k, int l){
  var dx = (i-k).abs();
  var dy = (j-l).abs();
  //return math.sqrt(dx *dx + dy * dy);
  //return d1 * (dx + dy);
  return d1 * (dx + dy) + (d2 - 2 * d1) * math.min(dx, dy);
  // var a = (i - k).abs();
  // var b = (j - l).abs();
  // if (a + b == 1) {
  //   return 10;
  // }else {
  //   return 14;
  // }
  // return math.sqrt(math.pow((i-k), 2) + math.pow((j-l), 2)).toDouble();
}