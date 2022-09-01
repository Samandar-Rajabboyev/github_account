import 'package:flutter/material.dart';
import 'package:githun_account/pages/home_page.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
        fontFamily: 'Segoe ui',
      ),
      home: const HomePage(),
    );
  }
}
