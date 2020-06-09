class FoodModel {
  String id;
  String idShop;
  String name;
  String price;
  String detail;
  String pathImage;

  FoodModel(
      {this.id,
      this.idShop,
      this.name,
      this.price,
      this.detail,
      this.pathImage});

  FoodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idShop = json['idShop'];
    name = json['Name'];
    price = json['Price'];
    detail = json['Detail'];
    pathImage = json['PathImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idShop'] = this.idShop;
    data['Name'] = this.name;
    data['Price'] = this.price;
    data['Detail'] = this.detail;
    data['PathImage'] = this.pathImage;
    return data;
  }
}

