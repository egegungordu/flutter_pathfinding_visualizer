import 'package:flutter/material.dart';
import 'package:flutter_2d_grid/animated_button_popup.dart';
import 'package:flutter_2d_grid/visualizer_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PopUpModel(),
      child: Selector<PopUpModel,Brightness>(
        selector: (context, model) => model.brightness,
        builder: (_,brightness,__){
          return  MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              brightness: brightness,
            ),
            home: Scaffold(
              body: Visualizer()
            )
          );
        },
      ),
    );
  }
}