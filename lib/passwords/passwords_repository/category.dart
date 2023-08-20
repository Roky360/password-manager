import 'package:flutter/material.dart';
import 'package:password_manager/passwords/encryption_service/encryption_service.dart';

class Category {
  String id;
  String name;
  CategoryColors color;

  static final Category _noneCategory = Category('', "No category", CategoryColors.grey);
  static final Category _emptyCategory = Category('', "", CategoryColors.values[0]);

  static Category get noneCategory => _noneCategory;

  static Category get empty => _emptyCategory;

  Category(this.id, this.name, this.color);

  Category.fromEncryptedJson(String id, Map<String, Object?> json)
      : this(
          id,
          EncryptionService().decryptData(json['name']! as String),
          CategoryColorsPacking.stringToEnum(json['color']! as String),
        );

  Map<String, dynamic> toEncryptedJson() {
    return {
      'name': EncryptionService().encryptData(name),
      'color': color.nameToString(),
    };
  }

  Category.fromJson(String id, Map<String, Object?> json)
      : this(
          id,
          json['name']! as String,
          CategoryColorsPacking.stringToEnum(json['color']! as String),
        );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.nameToString(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    CategoryColors? color,
  }) {
    return Category(
      id ?? this.id,
      name ?? this.name,
      color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum CategoryColors {
  red,
  blue,
  lightBlue,
  teal,
  yellow,
  orange,
  lime,
  green,
  magenta,
  purple,
  pink,
  grey,
}

extension CategoryColorsPacking on CategoryColors {
  static final Map<CategoryColors, Color> _catColorToMaterialColor = {
    CategoryColors.red: Colors.redAccent,
    CategoryColors.blue: Colors.blueAccent,
    CategoryColors.lightBlue: Colors.lightBlueAccent,
    CategoryColors.teal: Colors.teal,
    CategoryColors.yellow: Colors.yellow,
    CategoryColors.orange: Colors.orange,
    CategoryColors.lime: Colors.greenAccent,
    CategoryColors.green: Colors.green,
    CategoryColors.magenta: Colors.purpleAccent,
    CategoryColors.purple: Colors.deepPurpleAccent,
    CategoryColors.pink: Colors.pinkAccent,
    CategoryColors.grey: Colors.blueGrey,
  };

  Color? toMaterialColor() => _catColorToMaterialColor[this];

  String nameToString() => name;

  static CategoryColors stringToEnum(String s) =>
      CategoryColors.values.firstWhere((e) => e.name == s);
}
