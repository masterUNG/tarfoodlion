import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tarfoodlion/model/food_model.dart';
import 'package:tarfoodlion/screens/detail_food_order.dart';

import '../model/user_model.dart';
import '../model/user_model.dart';
import '../model/user_model.dart';
import '../model/user_model.dart';
import '../utility/my_constant.dart';
import '../utility/my_constant.dart';
import '../utility/my_constant.dart';
import '../utility/my_style.dart';
import '../utility/normal_dialog.dart';

class ShowCardShop extends StatefulWidget {
  @override
  _ShowCardShopState createState() => _ShowCardShopState();
}

class _ShowCardShopState extends State<ShowCardShop> {
  List<UserModel> userModels = List();
  List<Widget> shopWidgets = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readShop();
  }

  Future<Null> readShop() async {
    String url =
        '${MyConstant().domain}/tarfood/getUserWhereChooseType.php?isAdd=true&ChooseType=Shop';
    Response response = await Dio().get(url);
    // print('res = $response');
    var result = json.decode(response.data);
    for (var map in result) {
      UserModel userModel = UserModel.fromJson(map);
      if (userModel.nameShop.isNotEmpty) {
        print('nameShop = ${userModel.nameShop}');

        setState(() {
          shopWidgets.add(shopWidget(userModel));
          userModels.add(userModel);
        });
      }
    }
  }

  Widget shopWidget(UserModel userModel) {
    return GestureDetector(
      onTap: () {
        print('You Click idShop ==>> ${userModel.id}');
        checkAndRoutToDetail(userModel.id);
      },
      child: Column(
        children: <Widget>[
          Container(
            width: 80.0,
            height: 80.0,
            child:
                Image.network('${MyConstant().domain}${userModel.urlPicture}'),
          ),
          Text(userModel.nameShop)
        ],
      ),
    );
  }

  Future<Null> checkAndRoutToDetail(String idShop) async {
    String url =
        '${MyConstant().domain}/tarfood/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';
    Response response = await Dio().get(url);
    print('res ===>> $response');
    if (response.toString() == 'null') {
      normalDialog(context, 'ร้านนี่ยังไม่มี เมนูอาหารเลย คะ');
    } else {
      var result = json.decode(response.data);
      List<FoodModel> foodModels = List();
      for (var map in result) {
        FoodModel foodModel = FoodModel.fromJson(map);
        foodModels.add(foodModel);
      }

     if (foodModels.length != 0) {
       print('foodModel.length = ${foodModels.length}');
        MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DetailFoodOrder(foodModels: foodModels,),
      );
      Navigator.push(context, route);
       
     }


    }
  }

  @override
  Widget build(BuildContext context) {
    return shopWidgets.length == 0
        ? MyStyle().showProgress()
        : GridView.extent(
            maxCrossAxisExtent: 120.0,
            children: shopWidgets,
          );
  }
}
