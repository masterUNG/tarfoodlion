import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/model/user_model.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';

class EditInfoShop extends StatefulWidget {
  @override
  _EditInfoShopState createState() => _EditInfoShopState();
}

class _EditInfoShopState extends State<EditInfoShop> {
  UserModel userModel;
  String nameShop, address, phone, urlPicture;
  Location location = Location();
  double lat, lng;
  final _picker = ImagePicker();
  File file;
  @override
  void initState() {
    super.initState();
    readCurrentInfo();

    location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude;
        lng = event.longitude;
        // print('lat = $lat, lng = $lng');
      });
    });
  }

  Future<Null> readCurrentInfo() async {
    //เช็คว่ามีตอนนี้ login ด้วย id อะไรอยู่
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id'); // ดึงค่า id ออกมา
    print('idShop ==>> $idShop');

    String url =
        '${MyConstant().domain}/tarfood/getUserWhereId.php?isAdd=true&id=$idShop'; //ดึงค่า id

    Response response = await Dio().get(url); //ดึงค่า id
    print('response ==>> $response');

    var result = json.decode(response.data); //ทำให้อ่านภาษาไทยได้
    print('response ==>> $result');

    for (var map in result) {
      // เป็น array เลยใช้ for in hashmap ตัดปีกกาวนรอบเดียวเอาค่า ทุกอย่างใน id
      print('map ==>> $map');
      setState(() {
        //อ่านข้อมูลมา
        userModel = UserModel.fromJson(map);
        nameShop = userModel.nameShop;
        address = userModel.address;
        phone = userModel.phone;
        urlPicture = userModel.urlPicture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userModel == null ? MyStyle().showProgress() : showContent(),
      appBar: AppBar(
        title: Text('ปรับปรุงรายละเอียดร้าน'),
      ),
    );
  }

  Widget showContent() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameShopForm(),
            addressForm(),
            phoneForm(),
            showImage(),
            lat == null ? MyStyle().showProgress() : showMap(),
            editButton(),
          ],
        ),
      );

  Widget editButton() => Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton.icon(
          color: MyStyle().primaryColor,
          onPressed: () => confirmDialog(),
          icon: Icon(Icons.edit),
          label: Text(
            'ปรับปรุง รายละเอียด',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('คุณแน่ใจว่าจะ ปรับปรุงรายละเอียดร้าน นะคะ ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlineButton(
                onPressed: () {
                  Navigator.pop(context);
                  editThread();
                },
                child: Text('Ok'),
              ),
              OutlineButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editThread() async {
    if (file != null) {
      Random random = Random();
      int i = random.nextInt(100000);
      String nameFile = 'editShop$i.jpg';

      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);
      String urlUpload = '${MyConstant().domain}/tarfood/saveShop.php';
      await Dio().post(urlUpload, data: formData).then((value) async {
        urlPicture = '/tarfood/Shop/$nameFile';

        await editValueMySQL();
      });
    } else {
      editValueMySQL();
    }
  }

  Future editValueMySQL() async {
    String id = userModel.id;
    // print('id = $id');

    String url =
        '${MyConstant().domain}/tarfood/editUserWhereId.php?isAdd=true&id=$id&NameShop=$nameShop&Address=$address&Phone=$phone&UrlPicture=$urlPicture&Lat=$lat&Lng=$lng';

    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      Navigator.pop(context);
    } else {
      normalDialog(context, 'ไม่สามารถอัพเดทไม่ได้ กรุณาลองใหม่');
    }
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId('myMarker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
            title: 'ร้านอยู่ที่นี่', snippet: 'Lat =$lat, Lng = $lng'),
      )
    ].toSet();
  }

  Container showMap() {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16.0,
    );

    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 250,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: currentMarker(),
      ),
    );
  }

  Widget showImage() => Container(
        margin: EdgeInsetsDirectional.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => chooseImage(ImageSource.camera),
            ),
            Container(
              width: 250.0,
              height: 200.0,
              child: file == null
                  ? Image.network('${MyConstant().domain}$urlPicture')
                  : Image.file(file),
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () => chooseImage(ImageSource.gallery),
            ),
          ],
        ),
      );

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var pickedFile = await _picker.getImage(
        source: source,
        maxHeight: 800.0,
        maxWidth: 800.0,
      );
      setState(() {
        file = File(pickedFile.path);
      });
    } catch (e) {}
  }

  Widget nameShopForm() => Row(
        //ใช้ Row เพื่อให้มันอยู่ตรงกลาง
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            //ใช้ container เพื่อปรับขนาด
            margin: EdgeInsets.only(top: 16.0), //ไม่ให้ชิดขอบบน top คือขอบบน
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => nameShop = value,
              initialValue: nameShop, //โชว์ชื่อร้านเดิมก่อน
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อของร้าน',
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        //ใช้ Row เพื่อให้มันอยู่ตรงกลาง
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            //ใช้ container เพื่อปรับขนาด
            margin: EdgeInsets.only(top: 16.0), //ไม่ให้ชิดขอบบน
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => address = value,
              initialValue: address, //โชว์ชื่อร้านเดิมก่อน
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ที่อยู่ของร้าน',
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        //ใช้ Row เพื่อให้มันอยู่ตรงกลาง
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            //ใช้ container เพื่อปรับขนาด
            margin: EdgeInsets.only(top: 16.0), //ไม่ให้ชิดขอบบน
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => phone = value,
              initialValue: phone, //โชว์ชื่อร้านเดิมก่อน
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'เบอร์ติดต่อร้านของร้าน',
              ),
            ),
          ),
        ],
      );
}
