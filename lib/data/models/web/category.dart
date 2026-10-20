enum CategoryType {
  income,
  expense,
}

class Category {
  int id = 0;

  late String name;
  late String icon;
  late String colorHex;
  late CategoryType type;
  bool isDefault = false;
  int? parentId;
}
