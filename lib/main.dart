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
      child: MaterialApp(
        theme: ThemeData(
          buttonTheme: ButtonThemeData(minWidth: 50, height: 50)
        ),
        home: Scaffold(
          body: Visualizer()
        )
      ),
    );
  }
}