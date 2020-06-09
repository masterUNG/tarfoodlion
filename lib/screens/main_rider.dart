import 'package:flutter/material.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/signout_process.dart';

class MainRider extends StatefulWidget {
  @override
  _MainRiderState createState() => _MainRiderState();
}

class _MainRiderState extends State<MainRider> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Rider'),actions: <Widget>[IconButton(icon: Icon(Icons.exit_to_app), onPressed: ()=>signOutProcess(context))]
      ),
      drawer: showDrawer(),
    );
  }


  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHead(),
          ],
        ),
      );

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('rider.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text('Name Login'),
      accountEmail: Text('Login'),
    );
  }



  
}
