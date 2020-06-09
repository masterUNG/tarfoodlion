import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/screens/main_rider.dart';
import 'package:tarfoodlion/screens/main_shop.dart';
import 'package:tarfoodlion/screens/main_user.dart';
import 'package:tarfoodlion/screens/signIn.dart';
import 'package:tarfoodlion/screens/signup.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';
//สร้างหน้าใหม่ทุกครั้ง stl fulwidget ลบcontainer ใส่ scafold

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

//ถ้าโปรเจคทำงานจะทำงานตาข้างล่าง
class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    checkPrference();
  }

  Future checkPrference() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String chooseType = preferences.getString('ChooseType');
      if (chooseType != null && chooseType.isNotEmpty) {
        if (chooseType == 'User') {
          routeToService(MainUser());
        } else if (chooseType == 'Shop') {
          routeToService(MainShop());
        } else if (chooseType == 'Rider') {
          routeToService(MainRider());
        } else {
          normalDialog(context, 'Error UserType');
        }
      }
    } catch (e) {}
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: showDrawer(),
    );
  }

//listview เลยจอ scrholl ได้เลื่อนขึ้นเลื่อนลง
//useraccout ใช้โชว์ DrawHeader ได้เลย
  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHeadDrawer(),
            signIn(),
            signUp(),
          ],
        ),
      );

  ListTile signIn() {
    return ListTile(
      leading: Icon(Icons.android),
      title: Text('Sign In'),
      onTap: () {
        Navigator.pop(
            context); //เวลาไปหน้่ singIn แล้วกดกลับจะไม่โชว์ drawer เพราะตอนแรกกดจาก drawer
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignIn());
        Navigator.push(context, route);
      },
    );
  }

  ListTile signUp() {
    return ListTile(
      leading: Icon(Icons.android),
      title: Text('Sign Up'),
      onTap: () {
        Navigator.pop(
            context); //เวลาไปหน้่ singIn แล้วกดกลับจะไม่โชว์ drawer เพราะตอนแรกกดจาก drawer
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignUp());
        Navigator.push(context, route);
      },
    );
  }

  UserAccountsDrawerHeader showHeadDrawer() {
    return UserAccountsDrawerHeader(
        decoration: MyStyle().myBoxDecoration('bravo.jpg'),
        currentAccountPicture: MyStyle().showLogo(), //ใส่ logo ตรง drawheadere
        accountName: Text('Guest'),
        accountEmail: Text('Please Log in'));
  }
}
