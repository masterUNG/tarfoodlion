import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarfoodlion/model/order_sqlite_model.dart';
import 'package:tarfoodlion/screens/home.dart';
import 'package:tarfoodlion/utility/my_constant.dart';
import 'package:tarfoodlion/utility/my_style.dart';
import 'package:tarfoodlion/utility/sqlite_helper.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  List<OrderSQLiteModel> orderSQLiteModels = List();
  int totalSum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readOrder();
  }

  Future<Null> readOrder() async {
    // SQLiteHelper().clearSQLite();

    totalSum = 0;
    try {
      var object = await SQLiteHelper().readAllSQLite();

      setState(() {
        orderSQLiteModels = object;
        for (var model in orderSQLiteModels) {
          totalSum = totalSum + int.parse(model.sum);
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => orderThread(),
        child: Text('สั่งซื้อ'),
      ),
      appBar: AppBar(
        title: Text('ตระกล้าของฉัน'),
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () {
            backHome(context);
          },
        ),
      ),
      body: orderSQLiteModels.length == 0
          ? Center(
              child: Text('ยังไม่มีของใน ตระกล้า คะ'),
            )
          : showListFood(),
    );
  }

  void backHome(BuildContext context) {
     MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => Home(),
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Future<Null> orderThread() async {
    String idShop = orderSQLiteModels[0].idShop;
    String nameShop = orderSQLiteModels[0].nameShop;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    String nameUser = preferences.getString('Name');

    List<String> nameFoods = List();
    List<String> prices = List();
    List<String> amounts = List();
    List<String> sums = List();

    for (var model in orderSQLiteModels) {
      nameFoods.add(model.nameFood);
      prices.add(model.price);
      amounts.add(model.amount);
      sums.add(model.sum);
    }

    String nameFood = nameShop.toString();
    String price = prices.toString();
    String amount = amounts.toString();
    String sum = sums.toString();
    String url =
        '${MyConstant().domain}/tarfood/addOrder.php?isAdd=true&idShop=$idShop&NameShop=$nameShop&idUser=$idUser&NameUser=$nameUser&NameFood=$nameFood&Price=$price&Amount=$amount&Sum=$sum';

    await Dio().get(url).then((value)async {
      await SQLiteHelper().clearSQLite().then((value) {backHome(context);});
    });
  }

  Widget showListFood() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MyStyle().showTitle(orderSQLiteModels[0].nameShop),
            ],
          ),
          MyStyle().mySizeBox(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text('รายการอาหาร'),
              ),
              Expanded(
                flex: 1,
                child: Text('ราคา'),
              ),
              Expanded(
                flex: 1,
                child: Text('จำนวน'),
              ),
              Expanded(
                flex: 1,
                child: Text('รวม'),
              ),
            ],
          ),
          ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: orderSQLiteModels.length,
            itemBuilder: (context, index) => Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(orderSQLiteModels[index].nameFood),
                ),
                Expanded(
                  flex: 1,
                  child: Text(orderSQLiteModels[index].price),
                ),
                Expanded(
                  flex: 1,
                  child: Text(orderSQLiteModels[index].amount),
                ),
                Expanded(
                  flex: 1,
                  child: Text(orderSQLiteModels[index].sum),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      int id = orderSQLiteModels[index].id;
                      confirmDelete(id, orderSQLiteModels[index].nameFood);
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text('ค่าอาหารทั้งหมด = $totalSum บาท'),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> confirmDelete(int id, String nameFood) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('คุณต้องการลบ $nameFood จริงๆ หรือ ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  SQLiteHelper().deleteFoodWhereId(id);
                  readOrder();
                },
                child: Text('ยืนยันลบ'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> deleate(int idFood) async {}
}
