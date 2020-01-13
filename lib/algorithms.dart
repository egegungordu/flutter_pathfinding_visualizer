import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'dart:math' as math;

List<List<int>> grid;
List<List<Node>> nodes;

int x;
int y;

int endi;
int endj;

class Node{

  Node(this.i, this.j){
    this.h = distance(i,j,endi,endj);
  }
  final int i;
  final int j;

  double f;
  double g = double.infinity;
  double h;

  Node parent;

  List<Node> get neighbors{
    List<Node> neighbors = <Node>[];
    if (i > 0 && grid[i-1][j] == 0) { //left
      neighbors.add(nodes[i-1][j]);
    }
    if (i < x-1 && grid[i + 1][j] == 0) { //right
      neighbors.add(nodes[i + 1][j]);
    }
    if (j > 0 && grid[i][j-1] == 0) { //top
      neighbors.add(nodes[i][j-1]);
    }
    if (j < y-1 && grid[i][j+1] == 0) { //bottom
      neighbors.add(nodes[i][j + 1]);
    }
    if (i > 0 && j > 0 && (grid[i-1][j] == 0 || grid[i][j-1] == 0) && grid[i-1][j-1] == 0) { //topleft
      neighbors.add(nodes[i-1][j-1]);
    }
    if (i < x-1 && j > 0 && (grid[i+1][j] == 0 || grid[i][j-1] == 0) && grid[i+1][j-1] == 0) { //topright
      neighbors.add(nodes[i+1][j-1]);
    }
    if (i > 0 && j < y-1 && (grid[i-1][j] == 0 || grid[i][j+1] == 0) && grid[i-1][j+1] == 0) { //bottomleft
      neighbors.add(nodes[i-1][j+1]);
    }
    if (i < x-1 && j < y-1 && (grid[i+1][j] == 0 || grid[i][j+1] == 0) && grid[i+1][j+1] == 0) { //bottomright
      neighbors.add(nodes[i+1][j+1]);
    }
    return neighbors;
  }
}

class PathfindAlgorithms{

  static visualize({
    VisualizerAlgorithm algorithm, 
    List<List<int>> gridd, 
    int starti,
    int startj,
    int finishi,
    int finishj,
    Function(int i, int j) onShowClosedNode, 
    Function(int i, int j) onShowOpenNode,
    Function(Node lastNode) onDrawPath,
    Function onFinished}){

    List<Node> openSet = <Node>[];
    List<Node> closedSet = <Node>[];
    

    endi = finishi;
    endj = finishj;

    x = gridd.length;
    y = gridd[0].length;

    grid = gridd;
    gridd[starti][startj] = 0;
    gridd[endi][endj] = 0;

    nodes = List.generate(x, (i) => List.generate(y, (j) => Node(i, j)));
    Node startNode = nodes[starti][startj];
    startNode.g = 0;
    startNode.f = startNode.g + startNode.h;
    openSet.add(startNode);

    Timer.periodic(Duration(milliseconds: 100), (timer){
      if (!openSet.isEmpty) {
        int smallest = 0;
        for (int i = 0; i < openSet.length; ++i) {
          if (openSet[i].f < openSet[smallest].f) {
            smallest = i;
          }
        }
        Node currentNode = openSet[smallest];

        if (currentNode.i == endi && currentNode.j == endj) {
          onFinished();
          print('found');
          timer.cancel();
        }

        openSet.remove(currentNode);
        closedSet.add(currentNode);
        onShowClosedNode(currentNode.i,currentNode.j);

        for (Node neighbor in currentNode.neighbors) {
          double tentativeGScore = currentNode.g + distance(currentNode.i,currentNode.j,neighbor.i,neighbor.j);
          if (!closedSet.contains(neighbor) && (!openSet.contains(neighbor) || tentativeGScore < neighbor.g)) {
            neighbor.parent = currentNode;
            neighbor.g = tentativeGScore;
            neighbor.f = neighbor.g + neighbor.h;
            if (!openSet.contains(neighbor)) {
              openSet.add(neighbor);
              onShowOpenNode(neighbor.i,neighbor.j);
            }
          }
        } 
      }else{
        timer.cancel();
      }
    });
  }
}

double distance(int i, int j, int k, int l){
  return (math.pow((i-k), 2) + math.pow((j-l), 2)).toDouble();//euclidean distance
}