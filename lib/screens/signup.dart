import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //Explicit
  String chooseType, name, user, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: ListView(
        //list view กำหนดความกว้างเท่าไรก็เท่ากับ listview
        padding: EdgeInsets.all(
            30.0), //กำหนดให้โลโก้ไม่ชิดขอบแต่ละด้านห่างจากโทรสับ30.0
        children: <Widget>[
          myLogo(),
          MyStyle().mySizeBox(),
          showAppName(),
          MyStyle().mySizeBox(),
          nameForm(),
          MyStyle().mySizeBox(),
          userForm(),
          MyStyle().mySizeBox(),
          passWordForm(),
          MyStyle().mySizeBox(),
          MyStyle().showTitleH2('ชนิดของสมาชิก :'),
          MyStyle().mySizeBox(),
          userRadio(),
          shopRadio(),
          riderRadio(),
          MyStyle().mySizeBox(),
          registerButton(),
        ],
      ),
    );
  }

  Widget userRadio() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  //ทำให้จุดฟ้าในวงกลม
                  value: 'User',
                  groupValue: chooseType,
                  onChanged: (value) {
                    setState(() {
                      chooseType = value;
                    });
                  },
                ),
                Text(
                  'ผู้ส่งอาหาร',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
            ),
          ),
        ],
      );

  Widget shopRadio() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  //ทำให้จุดฟ้าในวงกลม
                  value: 'Shop',
                  groupValue: chooseType,
                  onChanged: (value) {
                    setState(() {
                      chooseType = value;
                    });
                  },
                ),
                Text(
                  'เจ้าของร้านอาหาร',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
              
            ),
          ),
        ],
      );

  Widget riderRadio() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  //ทำให้จุดฟ้าในวงกลม
                  value: 'Rider',
                  groupValue: chooseType,
                  onChanged: (value) {
                    setState(() {
                      chooseType = value;
                    });
                  },
                ),
                Text(
                  'ส่งอาหาร',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
            ),
          ),
        ],
      );

  Widget nameForm() => Row(
        mainAxisAlignment:
            MainAxisAlignment.center, //ใส่ row เพื่อปรับให้ได้250
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => name = value.trim(),
              //obscureText: true ทำให้เป็น star
              decoration: InputDecoration(
                //drcoration รับค่าจาก keyboard
                prefixIcon: Icon(
                  Icons.face,
                  color: MyStyle().darkColor,
                ),
                labelStyle: TextStyle(color: MyStyle().darkColor),
                labelText: 'Name :',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: MyStyle()
                            .darkColor)), //ทำให้ textfield เป็น ขอบสี่เหลี่ยมส่วน enable คือยังไม่กด keybpadr focus คือกดแล้ว
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyStyle().primaryColor)),
              ),
            ),
          ),
        ],
      );

  Widget userForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => user = value.trim(),
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
          ),
        ],
      );

  Widget passWordForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => password = value.trim(),
              //obscureText: true ทำให้เป็น star
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
          ),
        ],
      );

  Widget registerButton() => Container(
        width: 250.0,
        child: RaisedButton(
          color: MyStyle().darkColor,
          onPressed: () {
            print(
                'name = $name, password =$password, user=$user, choostype=$chooseType');
            if (name == null ||
                name.isEmpty ||
                user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty) {
              print('have space');
              normalDialog(context, 'มีช่องว่าง กรุณากรอกทุกช่อง');
            } else if (chooseType == null) {
              normalDialog(context, 'โปรดเลือกชนิดของผู้สมัคร');
            } else {
              checkUser();
             
            }
          },
          child: Text(
            'Regiser',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Future<Null> checkUser()async{//กัน สมาขิกซ้ำกัน
        String url ='${MyConstant().domain}/tarfood/getUserWhereUser.php?isAdd=true&User=$user';
        try {
          Response response = await Dio().get(url);
          if (response.toString() =='null') {
            registerThread();
            
          } else {
            normalDialog(context, 'User นี่ $user มีคนใช้แล้วกรุณาสมัครใหม่');
          }
        } catch (e) {
        }

      }
      
      
      Future<Null> registerThread()async{
        String url='${MyConstant().domain}/tarfood/addUser.php?isAdd=true&Name=$name&User=$user&Password=$password&ChooseType=$chooseType';


        try {
          Response response = await Dio().get(url);
          print('res = $response');
          if (response.toString() == 'true') {
            Navigator.pop(context);
          } else {
            normalDialog(context, 'ไม่สามรถสมัครได้ กรุณาลองใหม่คะ');
          }
        } catch (e) {
        }

      }

  Row showAppName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        MyStyle().showTitle('Tar Food'),
      ],
    );
  }

  Widget myLogo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MyStyle().showLogo(),
        ],
      );
}
