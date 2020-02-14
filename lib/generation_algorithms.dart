

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

class Point{
  Point(this.i,this.j);
  int i;
  int j;
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
      case GridGenerationFunction.recursive:
        recursiveMaze(gridd, onRemoveWall, onFinished, onShowWall, stopCallback, speed);
        break;
      case GridGenerationFunction.random:
        random(gridd, onRemoveWall, onFinished, onShowWall, stopCallback, speed);
        break;
      case GridGenerationFunction.backtracker:
        backtrackMaze(gridd,onShowCurrentNode,onRemoveWall,onFinished,onShowWall,stopCallback,speed);
        break;
      default:
    }
  }

  static void random(List<List<int>> grid, Function onRemoveWall,Function onFinished, Function onShowWall, Function stopCallback, Function speed) async {
    var rand = math.Random.secure();
    for (var j = 0; j < grid[0].length; j++) {
      for (var i = 0; i < grid.length; i++) {
        onRemoveWall(i,j);
        if (rand.nextInt(3) == 0) {
          onShowWall(i,j);
        }
        if (stopCallback()) {
          onFinished();
          return;
        }
        await Future.delayed(Duration(milliseconds: speed()~/10));
      }
    }
    onFinished();
  }

  static void backtrackMaze(List<List<int>> grid, Function onShowCurrentNode,Function onRemoveWall,Function onFinished, Function onShowWall, Function stopCallback, Function speed) async {

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

    void showWall(MazeNode a){
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
  
  static void recursiveMaze(List<List<int>> grid, Function onRemoveWall,Function onFinished, Function onShowWall, Function stopCallback, Function speed) async {
    for (var i = 0; i < grid.length; i++) {
      for (var j = 0; j < grid[0].length; j++) {
        onRemoveWall(i,j);
      }
    }

    List<Point> queue = <Point>[];

    var rand = math.Random.secure();

    void drawHorizontalWall(int pos, int start, int finish, bool passage){
      int hole = -1;
      if (passage) {
        hole = rand.nextInt((finish-start)~/2) * 2 + start;
      }
      for (var i = start; i <= finish; i++) {
        if (i != hole) {
          //onShowWall(i,pos);
          queue.add(new Point(i,pos));
        }
      }
    }

    void drawVerticalWall(int pos, int start, int finish, bool passage){
      int hole = -1;
      if (passage) {
        hole = rand.nextInt((finish-start)~/2) * 2 + start;
      }
      for (var i = start; i <= finish; i++) {
        if (i != hole) {
          //onShowWall(pos,i);
          queue.add(new Point(pos,i));
        }
      }
    }

    void drawEdges(){
      drawVerticalWall(0, 0, grid[0].length-1, false);
      drawVerticalWall(grid.length-1, 0, grid[0].length-1, false);
      drawHorizontalWall(0, 0, grid.length-1, false);
      drawHorizontalWall(grid[0].length-1, 0, grid.length-1, false);
    }
    
    void chooseWall(int left, int right, int top, int bottom){
      if (right-left < 2 || top-bottom < 2) {
        return;
      }
      bool isHorizontal = rand.nextBool();
      if (isHorizontal) {
        int y = rand.nextInt((top-bottom)~/2) * 2 + 1 + bottom;
        print(right);
        drawHorizontalWall(y, left, right, true);
        chooseWall(left, right, top, y+1);
        chooseWall(left, right, y-1, bottom);
      }else{
        int x = rand.nextInt((right-left)~/2) * 2 + 1 + left;
        drawVerticalWall(x, bottom, top, true);
        chooseWall(x + 1, right, top, bottom);
        chooseWall(left, x - 1, top, bottom);
      }
    }
    drawEdges();
    chooseWall(1,grid.length-2,grid[0].length-2,1);
    for (var i = 0; i < queue.length; i++) {
      if(stopCallback()){
        break;
      }
      onShowWall(queue.elementAt(i).i,queue.elementAt(i).j);
      await Future.delayed(Duration(milliseconds: speed()~/10));
    }
    onFinished();
  }
}