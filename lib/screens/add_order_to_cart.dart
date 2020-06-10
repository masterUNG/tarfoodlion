import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tarfoodlion/model/food_model.dart';
import 'package:tarfoodlion/model/order_sqlite_model.dart';
import 'package:tarfoodlion/model/user_model.dart';
import 'package:tarfoodlion/screens/show_cart.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/normal_dialog.dart';
import 'package:tarfoodlion/utility/sqlite_helper.dart';

class AddOrderToCart extends StatefulWidget {
  final FoodModel foodModel;
  AddOrderToCart({Key key, this.foodModel}) : super(key: key);

  @override
  _AddOrderToCartState createState() => _AddOrderToCartState();
}

class _AddOrderToCartState extends State<AddOrderToCart> {
  FoodModel foodModel;
  int amount = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    foodModel = widget.foodModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มราการอาหาร ไป ตระกล้า'),
      ),
      body: Stack(
        children: <Widget>[
          showContent(),
          controlCart(),
        ],
      ),
    );
  }

  Widget controlCart() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MyStyle().mySizeBox(),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 36.0,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        amount++;
                      });
                    },
                  ),
                  Text(
                    '$amount',
                    style: TextStyle(fontSize: 30.0, color: Colors.blue),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      size: 36.0,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (amount == 1) {
                        normalDialog(context, 'ไม่สามารถลดลงได้อีกแล้ว คะ');
                      } else {
                        setState(() {
                          amount--;
                        });
                      }
                    },
                  ),
                ],
              ),
              addOrderButton()
            ],
          ),
        ],
      );

  RaisedButton addOrderButton() {
    return RaisedButton(
      color: Colors.blue,
      onPressed: () => checkAndSaveSQLite(),
      child: Text(
        'เพิีมราการอาหารไปใน ตระกล้า',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future<Null> checkAndSaveSQLite() async {
    List<OrderSQLiteModel> orderSQLiteModels =
        await SQLiteHelper().readAllSQLite();

    String idShopFromSQLite = orderSQLiteModels.length == 0
        ? foodModel.idShop
        : orderSQLiteModels[0].idShop;
    if (idShopFromSQLite == foodModel.idShop) {
      saveOrderToSQLite();
    } else {
      normalDialog(context,
          'กรุณาเลือก รายการอาหาร จากร้าน ${orderSQLiteModels[0].nameShop} หรือ Order ไปก่อนคะ');
    }
  }

  Future<Null> saveOrderToSQLite() async {
    print('Work');
    String idShop = foodModel.idShop;
    String nameShop;

    String url =
        '${MyConstant().domain}/tarfood/getUserWhereId.php?isAdd=true&id=$idShop';
    Response response = await Dio().get(url);
    print('res ==>> $response');
    var result = json.decode(response.data);
    for (var map in result) {
      UserModel userModel = UserModel.fromJson(map);
      nameShop = userModel.nameShop;
    }

    print('idShop = $idShop, nameShop = $nameShop');

    int priceAint = int.parse(foodModel.price.trim());
    int sumAint = priceAint * amount;

    OrderSQLiteModel orderSQLiteModel = OrderSQLiteModel(
        idShop: idShop,
        nameShop: nameShop,
        nameFood: foodModel.name,
        price: foodModel.price,
        amount: amount.toString(),
        sum: sumAint.toString());

    await SQLiteHelper().insertValueToSQLite(orderSQLiteModel).then((value) {
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ShowCart(),
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    });
  }

  Column showContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            MyStyle().showTitle(foodModel.name),
          ],
        ),
        Container(
          child: Image.network(
            '${MyConstant().domain}${foodModel.pathImage}',
            fit: BoxFit.cover,
          ),
          margin: EdgeInsets.all(16.0),
          width: 250.0,
          height: 250.0,
        ),
        MyStyle().showTitleH2(foodModel.detail),
        MyStyle().showTitle('ราคา ${foodModel.price} บาท')
      ],
    );
  }
}
