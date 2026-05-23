import 'package:flutter/foundation.dart';
import 'categoryModel.dart';

class Productmodel {
  final int id;
  final String title;
  final String description;
  final double price;
  final Categorymodel category;
  final List<String> images;

  Productmodel({required this.id, required this.title, required this.description, required this.price, required this.category, required this.images});

}


