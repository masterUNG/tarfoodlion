import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/model/food_model.dart';
import 'package:tarfoodlion/screens/add_food_menu.dart';

import '../utility/my_constant.dart';
import '../utility/my_constant.dart';
import '../utility/my_style.dart';
import '../utility/my_style.dart';
import '../utility/my_style.dart';

class ListFoodMenuShop extends StatefulWidget {
  @override
  _ListFoodMenuShopState createState() => _ListFoodMenuShopState();
}

class _ListFoodMenuShopState extends State<ListFoodMenuShop> {
  String idShop;
  List<FoodModel> foodModels = List();
  bool status = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readAllFood();
  }

  Future<Null> readAllFood() async {

    if (foodModels.length != 0 ) {
      foodModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString('id');
    print('idShop = $idShop');

    // idShop = '123';

    String url =
        '${MyConstant().domain}/tarfood/getFoodWhereIdShop.php?isAdd=true&idShop=$idShop';
    Response response = await Dio().get(url);
    print('res ==>> $response');

    if (response.toString() != 'null') {

       var result = json.decode(response.data);
      print('result = $result');
      for (var map in result) {
        FoodModel foodModel = FoodModel.fromJson(map);
        setState(() {
          foodModels.add(foodModel);
          status = false;
        });
      }
      
    }

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        status ? Center(child: Text('ยังไม่มีเมนูอาหาร เลย'),) : showContent() ,
        addFoodMenu(),
      ],
    );
  }

  Widget showContent() {
    return foodModels.length == 0
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: foodModels.length,
            itemBuilder: (context, index) => showListFood(index),
          );
  }

  Widget showListFood(int index) => Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.4,
            padding: EdgeInsets.all(8.0),
            child: Image.network(
              '${MyConstant().domain}${foodModels[index].pathImage}',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.4,
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MyStyle().showTitleH2(foodModels[index].name),
                  ],
                ),
               MyStyle().showTitle('ราคา ${foodModels[index].price} บาท'),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(foodModels[index].detail),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  Widget addFoodMenu() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => AddFoodMenu(),
                    );
                    Navigator.push(context, route).then((value) => readAllFood());
                  },
                  child: Icon(Icons.add),
                ),
              ),
            ],
          ),
        ],
      );
}
