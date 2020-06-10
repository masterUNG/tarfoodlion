class OrderSQLiteModel {
  int id;
  String idShop;
  String nameShop;
  String nameFood;
  String price;
  String amount;
  String sum;

  OrderSQLiteModel(
      {this.id,
      this.idShop,
      this.nameShop,
      this.nameFood,
      this.price,
      this.amount,
      this.sum});

  OrderSQLiteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idShop = json['idShop'];
    nameShop = json['NameShop'];
    nameFood = json['NameFood'];
    price = json['Price'];
    amount = json['Amount'];
    sum = json['Sum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idShop'] = this.idShop;
    data['NameShop'] = this.nameShop;
    data['NameFood'] = this.nameFood;
    data['Price'] = this.price;
    data['Amount'] = this.amount;
    data['Sum'] = this.sum;
    return data;
  }
}

