import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/my_constant.dart';
import '../utility/my_constant.dart';
import '../utility/my_style.dart';
import '../utility/normal_dialog.dart';
import '../utility/normal_dialog.dart';
import '../utility/normal_dialog.dart';

class AddFoodMenu extends StatefulWidget {
  @override
  _AddFoodMenuState createState() => _AddFoodMenuState();
}

class _AddFoodMenuState extends State<AddFoodMenu> {
  String name, price, detail, pathImage, idShop;
  File file;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    findIdShop();

  }

  Future<Null> findIdShop()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString('id');
    print('idShop = $idShop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มรายการอาหาร'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            groupImage(),
            MyStyle().mySizeBox(),
            nameForm(),
            MyStyle().mySizeBox(),
            priceForm(),
            MyStyle().mySizeBox(),
            detailForm(),
            MyStyle().mySizeBox(),
            saveButton()
          ],
        ),
      ),
    );
  }

  RaisedButton saveButton() => RaisedButton.icon(
      onPressed: () {
        if (file == null) {
          normalDialog(context, 'โปรดเลือกรูปภาพอาหาร คะ');
        } else if (name == null ||
            name.isEmpty ||
            price == null ||
            price.isEmpty ||
            detail == null ||
            detail.isEmpty) {
          normalDialog(context, 'โปรด กรอกให้ครบทุกช่อง');
        } else {
          addNewMenuToServer();
        }
      },
      icon: Icon(Icons.save),
      label: Text('บันทึก รายการอาหาร'));

  Future<Null> addNewMenuToServer() async {
    Random random = Random();
    int i = random.nextInt(1000000);
    String nameFile = 'foodMenu$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      String url = '${MyConstant().domain}/tarfood/saveFood.php';
      await Dio().post(url, data: formData).then((value)async {
        pathImage = '/tarfood/Food/$nameFile';
        print('pathImage = $pathImage');

        String urlGet = '${MyConstant().domain}/tarfood/addFoodMenu.php?isAdd=true&idShop=$idShop&Name=$name&Price=$price&Detail=$detail&PathImage=$pathImage';
        Response response = await Dio().get(urlGet);
        if (response.toString() == 'true') {
          Navigator.pop(context);
        } else {
          normalDialog(context, 'Please Try Again');
        }


      });
    } catch (e) {}
  }

  Container nameForm() {
    return Container(
      width: 250.0,
      child: TextField(
        onChanged: (value) => name = value.trim(),
        decoration: InputDecoration(
          labelText: 'ชื่ออาหาร',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Container priceForm() {
    return Container(
      width: 250.0,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) => price = value.trim(),
        decoration: InputDecoration(
          labelText: 'ราคาอาหาร',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Container detailForm() {
    return Container(
      width: 250.0,
      child: TextField(
        onChanged: (value) => detail = value.trim(),
        decoration: InputDecoration(
          labelText: 'รายละเอียดอาหาร',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Row groupImage() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => chooseImage(ImageSource.camera),
          ),
          Container(
            width: 250.0,
            height: 250.0,
            child: file == null
                ? Image.asset('images/food.png')
                : Image.file(file),
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: () => chooseImage(ImageSource.gallery),
          ),
        ],
      );

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }
}
