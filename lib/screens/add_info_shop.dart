import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';

class AddInfoShop extends StatefulWidget {
  @override
  _AddInfoShopState createState() => _AddInfoShopState();
}

class _AddInfoShopState extends State<AddInfoShop> {
  //Field
  double lat, lng;
  String nameShop, address, phone, urlImage;
  final _picker = ImagePicker();
  File file;

  @override
  void initState() {
    super.initState();
    findLatLng();
  }

  Future<Null> findLatLng() async {
    //ไม่มีreturn ค่ากลับจึงเป็น Null ทำหน้าที่get LatLngมาใส่ใน double laat,lng;
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    });
    print('lat = $lat, lng = $lng');
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      //ถ้าปิดpermissionอาจทำให้ หา mapไม่เจออาจเกิด error เลยใช้ try catch
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Information Shop'),
      ),
      body: SingleChildScrollView(
        //single ทำให้เลื่อนขึ้นเลื่อนลงได้
        child: Column(
          //เรียงจากบนลงล่างจึงใช้ column
          children: <Widget>[
            MyStyle().mySizeBox(),
            nameForm(),
            MyStyle().mySizeBox(),
            addressForm(),
            MyStyle().mySizeBox(),
            phoneForm(),
            MyStyle().mySizeBox(),
            groupImage(),
            MyStyle().mySizeBox(),
            lat == null ? MyStyle().showProgress() : showMap(),
            MyStyle().mySizeBox(),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton.icon(
        color: MyStyle().primaryColor,
        onPressed: () {
          if (nameShop == null ||
              nameShop.isEmpty ||
              address == null ||
              address.isEmpty ||
              phone == null ||
              phone.isEmpty) {
            normalDialog(context, 'กรุณากรอกทุกช่องคะ');
          } else if (file == null) {
            normalDialog(context, 'กรุณาเลือกรุปภาพด้วยคะ');
          } else {
            uploadImage();
          }
        },
        icon: Icon(Icons.save, color: Colors.white),
        label: Text(
          'Save Information',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<Null> uploadImage() async {//เก็บภาพขึ้น database
    Random random = Random();
    int i = random.nextInt(1000000);
    String nameImage = 'shop$i.jpg';

    String url =
        '${MyConstant().domain}/tarfood/saveShop.php'; //เปลี่ยนค่าใน คลาส my_constantได้ตลอด

    try {
      Map<String, dynamic> map = Map();
      map['file'] =
          await MultipartFile.fromFile(file.path, filename: nameImage);

      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((value) {
        print('Response ==>> $value');
        urlImage = '/tarfood/Shop/$nameImage';
        print('urlImage = $urlImage');
        editUserShop();
      });
    } catch (e) {}
  }

  Future<Null> editUserShop() async {//เพิ่มค่าไปเก็บใน api หรือแก้ค่าเก็บค่า userShopด
    SharedPreferences preferences = await SharedPreferences
        .getInstance(); //ดึงค่า id มาจาก authen จาก future<null> route to Servie จะเรียกค่ามาใช้ได้ตลอด
    String id = preferences.getString('id');
    String url =
        '${MyConstant().domain}/tarfood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlImage&Lat=$lat&Lng=$lng'; //นำค่าไปเก็บบน database

    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.pop(context);// ถ้าบันทึกข้อมูลได้ จะไปกลับไปหน้าโชว์ข้อมูล
      } else {
        normalDialog(context, 'กรุณาลองใหม่คะ ไม่สามารถบันทึกข้อมูลได้');
      }
    });
  }

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('ที่อยู่ของร้านธีเดช'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: 'ร้านของคุณ',
          snippet: 'ละติจูด = $lat, ลองติจูด = $lng',
        ),
      )
    ].toSet();
  }

  Container showMap() {
    LatLng latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16.0,
    );
    return Container(
      height: 300.0,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: myMarker(),
      ),
    );
  }

  Row groupImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.add_a_photo,
            size: 36.0,
          ),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          child: file == null
              ? Image.asset('images/picture.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(
            Icons.add_photo_alternate,
            size: 36.0,
          ),
          onPressed: () => chooseImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Future<Null> chooseImage(ImageSource imageSource) async {
    try {
      var pickedFile = await _picker.getImage(
        source: imageSource,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );
      setState(() {
        file = File(pickedFile.path);
      });
    } catch (e) {}
  }

  Widget nameForm() => Row(
        //ใส่ row เพื่อกำหนด mainAxis
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => nameShop = value.trim(),
              decoration: InputDecoration(
                labelText: "ชื่อร้านค้า",
                prefixIcon: Icon(Icons.account_box),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        //ใส่ row เพื่อกำหนด mainAxis
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => address = value.trim(),
              decoration: InputDecoration(
                labelText: "ที่อยู่ร้านค้า",
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        //ใส่ row เพื่อกำหนด mainAxis
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            child: TextField(
              onChanged: (value) => phone = value.trim(),
              keyboardType: TextInputType.phone, //ให้keybodarขึ้นตัวเลข
              decoration: InputDecoration(
                labelText: "เบอร์โทรศัพท์ร้านค้า",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
