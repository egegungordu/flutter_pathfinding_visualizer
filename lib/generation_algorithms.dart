

import 'package:flutter_2d_grid/2d_grid.dart';
import 'dart:math' as math;

List<List<MazeNode>> mazeNodes;
List<MazeNode> stack = <MazeNode>[];

int x;
int y;

class MazeNode{
  MazeNode(this.i,this.j);
  int i;
  int j;
  bool visited = false;

  MazeNode pickNeighbor(){
    List<MazeNode> neighbors = <MazeNode>[];

    if (j > 0 && !mazeNodes[i][j-1].visited) {
      neighbors.add(mazeNodes[i][j-1]);
    }
    if (i < x - 1 && !mazeNodes[i + 1][j].visited) {
      neighbors.add(mazeNodes[i + 1][j]);
    }
    if (j < y - 1 && !mazeNodes[i][j+1].visited) {
      neighbors.add(mazeNodes[i][j+1]);
    }
    if (i > 0 && !mazeNodes[i-1][j].visited) {
      neighbors.add(mazeNodes[i-1][j]);
    }

    if (neighbors.length > 0) {
      int n = math.Random.secure().nextInt(neighbors.length);
      return neighbors[n];
    }else{
      return null;
    }
  }
}

class GenerateAlgorithms{
  static void visualize({
    GridGenerationFunction algorithm, 
    List<List<int>> gridd, 
    Function(int i, int j) onShowCurrentNode, 
    Function(int i, int j) onRemoveWall,
    Function(int i, int j) onShowWall,
    Function() stopCallback,
    Function() onFinished,
    int Function() speed}){

    switch (algorithm) {
      case GridGenerationFunction.maze:
        maze(gridd,onShowCurrentNode,onRemoveWall,onFinished,onShowWall,stopCallback,speed);
        break;
      case GridGenerationFunction.random:
        //dijkstra(onShowClosedNode,onShowOpenNode,onFinished,onDrawPath, speed);
        break;
      case GridGenerationFunction.recursive:
        //bfs(onShowClosedNode,onShowOpenNode,onFinished,onDrawPath);
        break;
      default:
    }
  }

  static void maze(List<List<int>> grid, Function onShowCurrentNode,Function onRemoveWall,Function onFinished, Function onShowWall, Function stopCallback, Function speed) async {

    removeWall(MazeNode a, MazeNode b){
      int gridi = a.i * 2 + 1;
      int gridj = a.j * 2 + 1;
      var dx = a.i - b.i;
      var dy = a.j - b.j;
      onRemoveWall(gridi,gridj);
      onShowCurrentNode(gridi,gridj);
      if (dx == -1) {
        onRemoveWall(gridi + 1, gridj);
        onShowCurrentNode(gridi + 1, gridj);
      }else if (dx == 1){
        onRemoveWall(gridi - 1, gridj);
        onShowCurrentNode(gridi - 1, gridj);
      }else if (dy == -1){
        onRemoveWall(gridi, gridj + 1);
        onShowCurrentNode(gridi, gridj + 1);
      }
      else if (dy == 1){
        onRemoveWall(gridi, gridj - 1);
        onShowCurrentNode(gridi, gridj - 1);
      }
    }

    showWall(MazeNode a){
      int gridi = a.i * 2 + 1;
      int gridj = a.j * 2 + 1;
      int i = a.i;
      int j = a.j;
      if (j > 0 && !mazeNodes[i][j-1].visited || j == 0) {
        onShowWall(gridi-1,gridj-1);
        onShowWall(gridi,gridj-1);
        onShowWall(gridi+1,gridj-1);
      }
      if (i < x - 1 && !mazeNodes[i + 1][j].visited || i == x - 1) {
        onShowWall(gridi+1,gridj-1);
        onShowWall(gridi+1,gridj);
        onShowWall(gridi+1,gridj+1);
      }
      if (j < y - 1 && !mazeNodes[i][j+1].visited || j == y - 1) {
        onShowWall(gridi+1,gridj+1);
        onShowWall(gridi,gridj+1);
        onShowWall(gridi-1,gridj+1);
      }
      if (i > 0 && !mazeNodes[i-1][j].visited || i == 0) {
        onShowWall(gridi-1,gridj+1);
        onShowWall(gridi-1,gridj);
        onShowWall(gridi-1,gridj-1);
      }
    }

    x = grid.length ~/ 2;
    y = grid[0].length ~/ 2;
    int totalNodes = x * y;
    mazeNodes = List.generate(x, (i) => List.generate(y, (j) => MazeNode(i, j)));

    var current = mazeNodes[0][0];
    current.visited = true;
    
    int visitedCount = 1;
    int mils;
    while (visitedCount < totalNodes) {
      var next = current.pickNeighbor();
      if(stopCallback()){
        break;
      }
      if (next != null) {
        stack.add(current);
        showWall(current);
        removeWall(current,next);
        next.visited = true;
        visitedCount++;
        current = next;
      }else if (!stack.isEmpty) {
        showWall(current);
        removeWall(current,current);
        current = stack.removeLast();
      }
      mils = speed();
      await Future.delayed(Duration(milliseconds: mils));
    }
    onFinished();
  }
}