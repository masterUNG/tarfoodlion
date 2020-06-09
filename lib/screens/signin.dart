import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/model/user_model.dart';
import 'package:tarfoodlion/screens/main_rider.dart';
import 'package:tarfoodlion/screens/main_shop.dart';
import 'package:tarfoodlion/screens/main_user.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //Field
  String user, password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignIn'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: <Color>[Colors.white, Colors.yellow.shade800],
            radius: 1.0,
            center: Alignment(0, -0.3),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            //ทำให้มัน scroll ได้และไม่ overflow pixel
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, //ใส่center ให้อยู่ตรงกลางส่วน column เรียงบนลงล่าง mainAxisSize.min ไม่ให้ชิดคอบบน
              children: <Widget>[
                MyStyle().showLogo(),
                MyStyle().mySizeBox(),
                MyStyle().showTitle('Tar Food'),
                MyStyle().mySizeBox(),
                userForm(),
                MyStyle().mySizeBox(),
                passWordForm(),
                MyStyle().mySizeBox(),
                loginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginButton() => Container(
        width: 250.0,
        child: RaisedButton(
          color: MyStyle().darkColor,
          onPressed: () {
            if (user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty) {
              normalDialog(context, 'มีช่องว่างค่ะ กรุณากรอกให้ครบค่ะ');
            } else {
              checkAuthen();
              print('fuck');
            }
          },
          child: Text(
            'Login',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> checkAuthen() async {
    String url =
        '${MyConstant().domain}/tarfood/getUserWhereUser.php?isAdd=true&User=$user';
    try {
      Response response = await Dio().get(url);
      print('res =$response'); //ถ้ามีข้อมูลใน mysql จะปริ้นค่าออกมา

      var result = json.decode(response.data);//แก้ไขให้user ภาษาไทยไม่เป็น ภาษาต่างด่าว 
      print('result = $result');
      for(var map in result){
        UserModel userModel = UserModel.fromJson(map);
        //use.model getค่า passwordใน mysqlง่าย
        if (password == userModel.password) {
          String chooesType = userModel.chooseType;
          if (chooesType == 'User') {
            routeToService(MainUser(),userModel);
          } else if (chooesType == 'Shop') {
            routeToService(MainShop(),userModel);
          } else if (chooesType =='Rider') {
            routeToService(MainRider(),userModel);
          } else {
            normalDialog(context, 'Error');
          }
        } else {
          normalDialog(context, 'Password ผิดค่ะ กรุราลองใหม่ค่ะ');
        }
      }


    } catch (e) {}
  }

  Future<Null> routeToService(Widget myWidget,UserModel userModel)async {//เมื่อ thread ทำงานเสร็จจะไม่ return ค่า จึงเป็น Null
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('id', userModel.id);
    preferences.setString('ChooseType', userModel.chooseType);
    preferences.setString('Name', userModel.name);
    

    MaterialPageRoute route = MaterialPageRoute(builder: (context) => myWidget,);//route ไปหน้าต่างๆๆ
    Navigator.pushAndRemoveUntil(context, route, (route) => false);

  }

  Widget userForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) =>
              user = value.trim(), //onchang เมือกดจะรับค่ามาและเซ็ทค่า
          decoration: InputDecoration(
            //drcoration รับค่าจาก keyboard
            prefixIcon: Icon(
              Icons.account_box,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'User :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: MyStyle()
                        .darkColor)), //ทำให้ textfield เป็น ขอบสี่เหลี่ยมส่วน enable คือยังไม่กด keybpadr focus คือกดแล้ว
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );

  Widget passWordForm() => Container(
        //obscureText: true ทำให้เป็น star
        width: 250.0,
        child: TextField(
          onChanged: (value) =>
              password = value.trim(),
          decoration: InputDecoration(
            //drcoration รับค่าจาก keyboard
            prefixIcon: Icon(
              Icons.lock,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'Password :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: MyStyle()
                        .darkColor)), //ทำให้ textfield เป็น ขอบสี่เหลี่ยมส่วน enable คือยังไม่กด keybpadr focus คือกดแล้ว
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );
}
