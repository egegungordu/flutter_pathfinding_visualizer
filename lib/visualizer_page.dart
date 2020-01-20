import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/2d_grid.dart';
import 'package:flutter_2d_grid/algorithms.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';
import 'package:flutter_2d_grid/fab_with_popup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Visualizer extends StatefulWidget {
  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {

  bool isRunning = false;

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
      _disabled6 = true;
    });
  }
  void enableBottomButtons(){
    setState(() {
      _disabled1 = false;
      _disabled2 = false;
      _disabled3 = false;
      _disabled4 = false;
      _disabled5 = false;
      _disabled6 = false;
    });
  }

  Color _color1 = Colors.orangeAccent;
  Color _color2 = Colors.white;
  Color _color3 = Colors.white;
  Color _color4 = Colors.white;
  Color _color5 = Colors.white;
  Color _color6 = Colors.lightGreen[500];

  bool _disabled1 = false;
  bool _disabled2 = false;
  bool _disabled3 = false;
  bool _disabled4 = false;
  bool _disabled5 = false;
  bool _disabled6 = false;

  bool drawTool = true;
  
  Grid grid = Grid(35, 50, 50, 5,5, 10,10);

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
            leading: Image.asset("assets/images/github_mark.png",scale: 1.8,color: Theme.of(context).iconTheme.color,),
            title: Text('Github Repo'),
            onTap: () {
              _launchURL("https://github.com/egegungordu/flutter_pathfinding_visualizer");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Image.asset("assets/images/wikipedia_logo.png",scale: 1.8, color: Theme.of(context).iconTheme.color,),
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
    var popupmodel = Provider.of<PopUpModel>(context,listen: false);
    return Scaffold(
      drawer: drawer(),
      appBar: AppBar(
        actions: <Widget>[
          FlatButton.icon(
            label: Text(''),
            icon: Icon(Icons.settings),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SecondRoute()),
              );
            },
          )
        ],
        title: Text("Pathfinding Visualizer"),
        iconTheme: IconThemeData(color: Color(0xFF494964)),
      ),
      floatingActionButton: Consumer<PopUpModel>(
        builder: (_,model,__) {
          return FabWithPopUp(
            disabled: _disabled6,
            color: _color6,
            width: 150,
            direction: AnimatedButtonPopUpDirection.vertical,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Visualize\n",
                style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 22, height: 1.0),
                children: [
                  TextSpan(
                    style: TextStyle(color: Color(0xFF2E2E2E),fontSize: 16),
                    text: ((){
                      switch (model.selectedPathAlg) {
                        case VisualizerAlgorithm.astar:
                          return "A*";
                          break;
                        case VisualizerAlgorithm.dijkstra:
                          return "Dijkstra";
                          break;
                        case VisualizerAlgorithm.dfs:
                          return "DFS";
                          break;
                        case VisualizerAlgorithm.bfs:
                          return "BFS";
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
              model.stop = false;
              setActiveButton(3);
              setState(() {
                isRunning = true;
                _color6 = Colors.redAccent;
              });
              disableBottomButtons();
              grid.clearPaths();
              PathfindAlgorithms.visualize(
                algorithm: model.selectedPathAlg,
                gridd: grid.nodeTypes,
                startti: grid.starti,
                starttj: grid.startj,
                finishi: grid.finishi,
                finishj: grid.finishj,
                onShowClosedNode: (int i, int j){
                  grid.addNode(i, j, Brush.closed);
                },
                onShowOpenNode: (int i, int j) {
                  grid.addNode(i, j, Brush.open);
                },
                speed: (){
                  return model.speed;
                },
                onDrawPath: (Node lastNode,int c) {
                  popupmodel.operations = c;
                  if(model.stop){
                    setState(() {
                      _color6 = Colors.lightGreen[500];
                    });
                    enableBottomButtons();
                    return true;
                  }
                  grid.drawPath(lastNode);
                  return false;
                },
                onFinished: () {
                  setState(() {
                    isRunning = false;
                    _color6 = Colors.lightGreen[500];
                  });
                  enableBottomButtons();
                }
              );
            },
            items: <AnimatedButtonPopUpItem>[
              AnimatedButtonPopUpItem(
                child: Text("A*",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.pAlgColor1),),
                onPressed: () {
                  model.setActivePAlgorithm(1);
                },
              ),
              AnimatedButtonPopUpItem(
                child: Text("Dijkstra",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.pAlgColor2),),
                onPressed: () {
                  model.setActivePAlgorithm(2);
                },
              ),
              AnimatedButtonPopUpItem(
                child: Text("DFS",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.pAlgColor3),),
                onPressed: () {
                  model.setActivePAlgorithm(3);
                },
              ),
              AnimatedButtonPopUpItem(
                child: Text("BFS",textAlign: TextAlign.center,style: TextStyle(fontSize: 16, color: model.pAlgColor4),),
                onPressed: () {
                  model.setActivePAlgorithm(4);
                },
              ),
            ],
          );
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
                    width: 130,
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
                      model.stop = false;
                      setState(() {
                        setActiveButton(3);
                        isRunning = true;
                        _color5 = Colors.redAccent;
                      });
                      disableBottomButtons();
                      grid.generateBoard(
                        callback: (){
                          if (model.stop) {
                            setState(() {
                              isRunning = false;
                              _color5 = Colors.white;
                            });
                            enableBottomButtons();
                            return true;
                          }
                          return false;
                        },
                        function: model.selectedAlg,
                        onFinished: (){
                          setState(() {
                            isRunning = false;
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
                  // setState(() {
                  //   _color4 = Colors.redAccent;
                  //   _disabled4 = true;
                  //   _disabled5 = true;
                  //   _disabled6 = true;
                  // });
                  grid.clearBoard(
                    onFinished: () {
                      setState(() {
                        _disabled4 = false;
                        _disabled5 = false;
                        _disabled6 = false;
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
      body: Stack(
        children: <Widget>[
          Selector<PopUpModel, Brush>(
            selector: (context,model) => model.selectedBrush,
            builder: (_,brush,__){
              return grid.gridWidget(
                onTapNode: (i,j) {
                  grid.clearPaths();
                  if (drawTool) {
                    if (brush == Brush.wall) {
                      grid.addNode(i, j, Brush.wall);
                    }else{
                      grid.hoverSpecialNode(i, j, brush);
                    }
                  }else{
                    grid.removeNode(i, j, 1);
                  }
                },
                onDragNode: (i, j, k, l, t) {
                  if (drawTool) {
                    if (brush != Brush.wall) {
                      grid.hoverSpecialNode(k, l,brush);
                    }else{
                      grid.addNode(k, l, brush);
                    }
                  }else{
                    grid.removeNode(k, l, 1);
                  }
                },
                onDragNodeEnd: () {
                  if (brush != Brush.wall && drawTool) {
                    grid.addSpecialNode(brush);
                  }
                },
              );
            },
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Selector<PopUpModel, int>(
              selector: (context, model) => model.operations,
              builder: (_,operations,__){
                return Text('Operations: ${operations.toString()}',style: TextStyle(backgroundColor: Colors.white.withOpacity(0.6)),);
              }
            ),
          ),
          AnimatedPositioned(
            left: MediaQuery.of(context).size.width/2-23,
            bottom: isRunning ? 15 : -50,
            duration: Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.pause,color:Colors.black),
              mini: true,
              onPressed: (){
                setState(() {
                  isRunning = false;
                });
                popupmodel.stop = true;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<PopUpModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Speed of Algorithms'),
            subtitle: Text(
              (){
                switch (model.speed) {
                  case 400:
                    return "Slow";
                    break;
                  case 10:
                    return "Fast";
                    break;
                  default:
                    return "Average";
                }
              }()
            ),
            trailing: Selector<PopUpModel,int>(
              selector: (context,model) => model.speed,
              builder: (_,speed,__){
                return Container(
                  width: 200,
                  child: Slider.adaptive(
                    activeColor: Colors.lightBlue,
                    min: 10,
                    max: 400,
                    divisions: 2,
                    value: speed.toDouble() * -1 + 410,
                    onChanged: (val){
                      model.speed = val.toInt() * -1 + 410;
                    },
                  ),
                );
              }
            ),
          ),
          ListTile(
            title: Text('Dark Theme'),
            trailing: Switch.adaptive(
              onChanged: (state){
                if (state) {
                  model.brightness = Brightness.dark;
                }else{
                  model.brightness = Brightness.light;
                }
              },
              value: ((){
                if (model.brightness == Brightness.light) {
                  return false;
                }
                return true;
              }()),
            ),
          )
        ],
      ),
    );
  }
}

