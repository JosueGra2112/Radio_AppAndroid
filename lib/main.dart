import 'package:flutter/material.dart';
import 'screens/radio_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
    Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radio App',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: RadioListScreen(),
    );
  }
  }