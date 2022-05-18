import 'package:flutter/material.dart';

class Package {
  final int id;
  final String name;
  final int price;
  final int allowedImages;
  final List<String> features;

  Package({
    required this.id,
    required this.name,
    required this.price,
    this.allowedImages: 10,
    required this.features,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      features: json['features'],
    );
  }
}

class PackageProvider with ChangeNotifier {
  List<Package> _items = [
    Package(
      id: 0,
      name: 'Owlet Basic',
      price: 0,
      allowedImages: 3,
      features: [
        '2 Images per upload',
        'No Videos',
      ],
    ),
    Package(
      id: 0,
      name: 'Owlet Starter',
      price: 2000,
      allowedImages: 5,
      features: [
        'Per Week',
        'Incl. Owlet Basic',
        '5 Images per upload',
        '1 Video per upload',
        'Featured',
      ],
    ),
    Package(
      id: 0,
      name: 'Owlet Pro',
      price: 10000,
      allowedImages: 10,
      features: [
        'Per Month',
        'Incl. Owlet Starter',
        'Sticky post',
        '10 Images per upload',
        '5 Video per upload',
        'Featured',
      ],
    ),
  ];

  List<Package> get items {
    return _items;
  }
}
