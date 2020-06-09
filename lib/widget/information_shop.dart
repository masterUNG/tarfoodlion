import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/model/user_model.dart';
import 'package:tarfoodlion/screens/add_info_shop.dart';
import 'package:tarfoodlion/screens/edit_info_shop.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';

class InformationShop extends StatefulWidget {
  @override
  _InformationShopState createState() => _InformationShopState();
}

class _InformationShopState extends State<InformationShop> {
  UserModel userModel;
  @override
  void initState() {
    super.initState();
    readDataUser();
  }

  Future<Null> readDataUser() async {
    SharedPreferences preferences =
        await SharedPreferences.getInstance(); //เอาข้อมูลมาจาก database
    String id = preferences.getString('id'); //ดึงค่า id ที่เก็บอยู่ใน database
    String url =
        '${MyConstant().domain}/tarfood/getUserWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      print('value = $value'); //โชว ข้อมูล id
      var result = json.decode(value.data);
      print('result = $result');
      for (var map in result) {
        setState(() {
          userModel = UserModel.fromJson(map);
        });
        print('nameShop = ${userModel.nameShop}');
        if (userModel.nameShop.isEmpty) {}
      }
    });
  }

  void routeToAddInfo() {
    Widget widget = userModel.nameShop.isEmpty
        ? AddInfoShop()
        : EditInfoShop(); //เช็คว่ามีข้อมูลร้านหรือยังถ้า empty ทำหลังเครื่องหมาย ?
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => widget, //จะเช็คว่า is empty หรือไม่
    );
    Navigator.push(context, materialPageRoute).then(
      (value) => readDataUser(),// .then คือ fresh แสดงค่าใหม่
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      //วัตถุวางทาบกันได้
      children: <Widget>[
        userModel == null
            ? MyStyle().showProgress()
            : userModel.nameShop.isEmpty
                ? showNoData(context)
                : showListInfoShop(),
        addAndEditButton(),
      ],
    );
  }

  Widget showListInfoShop() => Column(
        children: <Widget>[
          MyStyle().showTitleH2('รายละเอียดร้าน ${userModel.nameShop}'),
          showImage(),
          Row(
            children: <Widget>[
              MyStyle().showTitleH2('ที่อยู่ของร้าน'),
            ],
          ),
          Row(
            children: <Widget>[
              Text(userModel.address),
            ],
          ),
          MyStyle().mySizeBox(),
          showMap()
        ],
      );

  Container showImage() {
    return Container(
      width: 200.0,
      height: 200.0,
      child: Image.network('${MyConstant().domain}${userModel.urlPicture}'),
    );
  }

  Set<Marker> shopMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('shopID'),
        position: LatLng(
          double.parse(userModel.lat),
          double.parse(userModel.lng),
        ),
        infoWindow: InfoWindow(
            //infowinddow คือ คลิกแล้ว marker จะโชว์ค่า lat lng
            title: 'ตำแหน่งร้าน',
            snippet: 'ละติจูด ช ${userModel.lat},ลองติจูด = ${userModel.lng}'),
      ),
    ].toSet();
  }

  Widget showMap() {
    double lat = double.parse(userModel.lat);
    double lng = double.parse(userModel.lng);

    LatLng latLng = LatLng(lat, lng);
    CameraPosition position = CameraPosition(target: latLng, zoom: 16.0);
    return Expanded(
      //padding: EdgeInsets.all(10.0),
      //height: 300.0,
      child: GoogleMap(
        initialCameraPosition: position,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: shopMarker(),
      ),
    );
  }

  Widget showNoData(BuildContext context) {
    return MyStyle()
        .titleCenter(context, 'ยังไม่มี ข้อมูล กรุณา เพิ่มข้อมูลด้วย ค่ะ');
  }

  Row addAndEditButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 16.0,
                bottom: 16.0,
              ),
              child: FloatingActionButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    print('you click');
                    routeToAddInfo();
                  }),
            ),
          ],
        ),
      ],
    );
  }
}
