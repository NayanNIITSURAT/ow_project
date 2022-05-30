// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

import '../services/apiUrl.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  Product({
    required this.data,
  });

  List<Datum> data;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    required this.userId,
    required this.requesterId,
    required this.createdAt,
    required this.updatedAt,
    required this.requestedUser,
    required this.requesterUser,
  });

  int userId;
  int requesterId;
  DateTime createdAt;
  DateTime updatedAt;
  RequesteUser requestedUser;
  RequesteUser requesterUser;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        userId: json["userId"],
        requesterId: json["requesterId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        requestedUser: RequesteUser.fromJson(json["requestedUser"]),
        requesterUser: RequesteUser.fromJson(json["requesterUser"]),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "requesterId": requesterId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "requestedUser": requestedUser.toJson(),
        "requesterUser": requesterUser.toJson(),
      };
}

class Update {
  Update({
    required this.success,
    required this.message,
  });

  bool success;
  String message;

  factory Update.fromJson(Map<String, dynamic> json) => Update(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}

class RequesteUser {
  RequesteUser({
    required this.phone,
    required this.username,
    required this.avartar,
    required this.id,
    required this.email,
    required this.fullName,
    required this.fname,
    required this.lname,
    required this.password,
    required this.bio,
    required this.website,
    required this.private,
    required this.confirmed,
    required this.isAdmin,
    required this.confirmationToken,
    required this.lastQueryAt,
    required this.walletAmount,
    required this.isNotification,
    required this.isPrivate,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.countryIso,
  });

  String phone;
  String username;
  String avartar;
  int id;
  String email;
  String fullName;
  String fname;
  String lname;
  String password;
  dynamic bio;
  dynamic website;
  bool private;
  bool confirmed;
  bool isAdmin;
  String confirmationToken;
  DateTime lastQueryAt;
  int walletAmount;
  String isNotification;
  String isPrivate;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic deletedAt;
  String countryIso;

  factory RequesteUser.fromJson(Map<String, dynamic> json) => RequesteUser(
        phone: json["phone"],
        username: json["username"],
        // avartar: json["avartar"],
        avartar: AppUrl.profileImageBaseUrl + (json['avartar'] ?? 'avarta.jpg'),
        id: json["id"],
        email: json["email"],
        fullName: json["fullName"],
        fname: json["fname"] == null ? null : json["fname"],
        lname: json["lname"] == null ? null : json["lname"],
        password: json["password"],
        bio: json["bio"],
        website: json["website"],
        private: json["private"],
        confirmed: json["confirmed"],
        isAdmin: json["isAdmin"],
        confirmationToken: json["confirmation_token"],
        lastQueryAt: DateTime.parse(json["lastQueryAt"]),
        walletAmount:
            json["walletAmount"] == null ? null : json["walletAmount"],
        isNotification: json["isNotification"],
        isPrivate: json["isPrivate"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        deletedAt: json["deletedAt"],
        countryIso: json["countryIso"] == null ? null : json["countryIso"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "username": username,
        "avartar": avartar,
        "id": id,
        "email": email,
        "fullName": fullName,
        "fname": fname == null ? null : fname,
        "lname": lname == null ? null : lname,
        "password": password,
        "bio": bio,
        "website": website,
        "private": private,
        "confirmed": confirmed,
        "isAdmin": isAdmin,
        "confirmation_token": confirmationToken,
        "lastQueryAt": lastQueryAt.toIso8601String(),
        "walletAmount": walletAmount == null ? null : walletAmount,
        "isNotification": isNotification,
        "isPrivate": isPrivate,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "deletedAt": deletedAt,
        "countryIso": countryIso == null ? null : countryIso,
      };
}
