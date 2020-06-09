import 'package:flutter/material.dart';
import 'package:tarfoodlion/screens/home.dart';

//void main(){
//  runApp(MyApp());
//}  แบบเต็ม

main() => runApp(MyApp()); //แบบย่อ

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(primarySwatch: Colors.green),//เปลี่ยนสี appbar
      title: 'Tar Food ', //เปลี่ยนชื่อตรงเวลาจะปิดแอพ fluter demo
      home: Home(),
    );
  }
}
