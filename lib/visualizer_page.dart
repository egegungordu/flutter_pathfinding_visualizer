import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Visualizer extends StatefulWidget {
  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {

  bool isRunning = false;
  List<String> algorithms = ["Maze","Random","Recursive"];
  String selectedAlg = "Maze";

  void disableButtons(int i){
    switch (i) {
      case 1: //brush
        grid.isPanning = false;
        drawTool = true;
        setState(() {
          _color1 = Colors.orangeAccent;
          _color2 = Colors.white;
          _color3= Colors.white;
        });
        break;
      case 2: //eraser
        grid.isPanning = false;
        drawTool = false;
        setState(() {
          _color1 = Colors.white;
          _color2 = Colors.orangeAccent;
          _color3= Colors.white;
        });
        break;
      case 3: // pan
        grid.isPanning = true;
        setState(() {
          _color1 = Colors.white;
          _color2 = Colors.white;
          _color3= Colors.orangeAccent;
        });
        break;
      default:
    }
  }

  void setActiveButton(int i){
    switch (i) {
      case 1: //brush
        grid.isPanning = false;
        drawTool = true;
        setState(() {
          _color1 = Colors.orangeAccent;
          _color2 = Colors.white;
          _color3= Colors.white;
        });
        break;
      case 2: //eraser
        grid.isPanning = false;
        drawTool = false;
        setState(() {
          _color1 = Colors.white;
          _color2 = Colors.orangeAccent;
          _color3= Colors.white;
        });
        break;
      case 3: // pan
        grid.isPanning = true;
        setState(() {
          _color1 = Colors.white;
          _color2 = Colors.white;
          _color3= Colors.orangeAccent;
        });
        break;
      default:
    }
  }

  void disableBottomButtons(){
    setState(() {
      _disabled1 = true;
      _disabled2 = true;
      _disabled3 = true;
      _disabled4 = true;
      _disabled5 = true;
    });
  }
  void enableBottomButtons(){
    setState(() {
      _disabled1 = false;
      _disabled2 = false;
      _disabled3 = false;
      _disabled4 = false;
      _disabled5 = false;
    });
  }

  Color _color1 = Colors.orangeAccent;
  Color _color2 = Colors.white;
  Color _color3 = Colors.white;
  Color _color4 = Colors.white;
  Color _color5 = Colors.white;
  bool _disabled1 = false;
  bool _disabled2 = false;
  bool _disabled3 = false;
  bool _disabled4 = false;
  bool _disabled5 = false;

  bool drawTool = true;
  
  Grid grid = Grid(35, 50, 40, 5,5, 10,10);

  double brushSize = 0.1;

  @override
  initState(){
    super.initState();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget drawer(){
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Links',style: TextStyle(fontSize:25,color: Colors.white),),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Color(0xFF494964),
                  Colors.indigo,
                ] 
              ),
            ),
          ),
          ListTile(
            leading: Image.asset("assets/images/github_mark.png",scale: 1.8,),
            title: Text('Github Repo'),
            onTap: () {
              _launchURL("https://github.com/egegungordu/flutter_pathfinding_visualizer");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Image.asset("assets/images/wikipedia_logo.png",scale: 1.8, ),
            title: Text('Learn more'),
            subtitle: Text("Pathfinding Algorithms wikipedia page"),
            onTap: () {
              _launchURL("https://en.wikipedia.org/wiki/Pathfinding#Algorithms");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Pathfinding Visualizer",style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(color: Color(0xFF494964)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightGreen[500],
        label: Text("Visualize", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
        onPressed: (){
          disableBottomButtons();
          setActiveButton(3);
          Timer(Duration(milliseconds: 2000),(){
            enableBottomButtons();
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF494964),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Consumer<PopUpModel>(
                builder: (_,model,__) {
                  return AnimatedButtonWithPopUp(
                    width: 150,
                    direction: AnimatedButtonPopUpDirection.vertical,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Generate\n",
                        style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 22, height: 1.0),
                        children: [
                          TextSpan(
                            style: TextStyle(color: Color(0xFF2E2E2E),fontSize: 16),
                            text: ((){
                              switch (model.selectedAlg) {
                                case GridGenerationFunction.maze:
                                  return "Maze";
                                  break;
                                case GridGenerationFunction.random:
                                  return "Random";
                                  break;
                                case GridGenerationFunction.recursive:
                                  return "Recursive";
                                  break;
                                default:
                                return "Maze";
                              }
                            }())
                          )
                        ]
                      ),
                    ),
                    onPressed: (){
                      setState(() {
                        setActiveButton(3);
                        _color5 = Colors.redAccent;
                      });
                      disableBottomButtons();
                      grid.generateBoard(
                        function: model.selectedAlg,
                        onFinished: (){
                          setState(() {
                            _color5 = Colors.white;
                          });
                          enableBottomButtons();
                        }
                      );
                    },
                    onLongPressed: () {
                    },
                    disabled: _disabled5,
                    color: _color5,
                    items: <AnimatedButtonPopUpItem>[
                      AnimatedButtonPopUpItem(
                        child: Text("Maze",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.algColor1),),
                        onPressed: () {
                          model.setActiveAlgorithm(1);
                        },
                      ),
                      AnimatedButtonPopUpItem(
                        child: Text("Random",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.algColor2),),
                        onPressed: () {
                          model.setActiveAlgorithm(2);
                        },
                      ),
                      AnimatedButtonPopUpItem(
                        child: Text("Recursive",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.algColor3),),
                        onPressed: () {
                          model.setActiveAlgorithm(3);
                        },
                      )
                    ],
                  );
                },
              ),
              Container(width: 0,height: 60,),
              Consumer<PopUpModel>(
                builder: (_,model,__) {
                  return AnimatedButtonWithPopUp(
                  direction: AnimatedButtonPopUpDirection.horizontal,
                  child: Image.asset("assets/images/brush.png"),
                  onPressed: (){
                    setActiveButton(1);
                  },
                  onLongPressed: () {
                    setActiveButton(1);
                  },
                  disabled: _disabled1,
                  color: _color1,
                  items: <AnimatedButtonPopUpItem>[
                     AnimatedButtonPopUpItem(
                      child: Image.asset("assets/images/wall_node.png",color: model.brushColor1, scale: 1.5,),
                      onPressed: () {
                        model.setActiveBrush(1);
                      },
                    ),
                    AnimatedButtonPopUpItem(
                      child: Image.asset("assets/images/start_node.png",color: model.brushColor2, scale: 1.9,),
                      onPressed: () {
                        model.setActiveBrush(2);
                      },
                    ),
                     AnimatedButtonPopUpItem(
                      child: Image.asset("assets/images/end_node.png",color: model.brushColor3, scale: 1.9,),
                      onPressed: () {
                        model.setActiveBrush(3);
                      },
                    )
                  ]
                );
                }, 
              ),
              Container(width: 0,height: 60,),
              AnimatedButtonWithPopUp(
                child: Image.asset("assets/images/erase.png"),
                onPressed: (){
                  setActiveButton(2);
                },
                disabled: _disabled2,
                color: _color2,
              ),
              Container(width: 0,height: 60,),
              AnimatedButtonWithPopUp(
                child: Image.asset("assets/images/pan.png"),
                onPressed: (){
                  setActiveButton(3);
                },
                disabled: _disabled3,
                color: _color3,
              ),
              Container(width: 0,height: 60,),
              AnimatedButtonWithPopUp(
                child: Icon(Icons.delete,size:35),
                color: _color4,
                disabled: _disabled4,
                onPressed: (){
                  setState(() {
                    _color4 = Colors.redAccent;
                    _disabled4 = true;
                    _disabled5 = true;
                  });
                  grid.clearBoard(
                    onFinished: () {
                      setState(() {
                        _disabled4 = false;
                        _disabled5 = false;
                        _color4 = Colors.white;
                      });
                    }
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<PopUpModel>(
        builder: (_,model,__){
          return Stack(
            children: <Widget>[
              grid.gridWidget(
                onTapNode: (i,j) {
                  if (drawTool) {
                    if (model.selectedBrush == Brush.wall) {
                      grid.addNode(i, j, Brush.wall);
                    }else{
                      grid.hoverSpecialNode(i, j, model.selectedBrush);
                    }
                  }else{
                    grid.removeNode(i, j, 1);
                  }
                },
                onDragNode: (i, j, k, l, t) {
                  if (drawTool) {
                    if (model.selectedBrush != Brush.wall) {
                      grid.hoverSpecialNode(k, l,model.selectedBrush);
                    }else{
                      grid.addNode(k, l, model.selectedBrush);
                    }
                  }else{
                    grid.removeNode(k, l, 1);
                  }
                },
                onDragNodeEnd: () {
                  if (model.selectedBrush != Brush.wall && drawTool) {
                    grid.addSpecialNode(model.selectedBrush);
                  }
                }
              ),
            ],
          );
        },
      ),
    );
  }
}
