import 'package:owlet/Providers/Package.dart';

class Subscription {
  final int id;
  final String status;
  final bool autorenew;
  final DateTime createdAT;
  final Package package;
  Subscription({
    required this.id,
    required this.status,
    required this.autorenew,
    required this.createdAT,
    required this.package,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      status: json['status'],
      autorenew: json['autorenew'],
      createdAT: json['createdAT'],
      package: Package.fromJson(json['package']),
    );
  }

  set package(Package package) => package = package;
}
