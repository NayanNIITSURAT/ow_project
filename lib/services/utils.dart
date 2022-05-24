import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:owlet/Preferences/UserPreferences.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/user.dart';

class HttpException implements Exception {
  final String message;

  HttpException(this.message); // Pass your message in constructor.

  @override
  String toString() {
    return message;
  }
}

final headers = Global.jsonHeaders;

Future<String> get getToken async {
  User user = await UserPreferences().getUser;
  return user.token;
}

Future<int> get getuserid async {
  User user = await UserPreferences().getUser;
  return user.id;
}

Future<Map<String, dynamic>> searchDb(String query, int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.dbSearchUrl + '/$query/$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<HashTagResponse> searchTag(String query, int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.utilsBaseUrl +
        '/hashtag/${query.length > 0 ? query : 'null'}/$page'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return HashTagResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    print(data['message']);
    throw HttpException(data['message']);
  }
}

Future<dynamic> fetchIndustries() async {
  final response = await get(
    Uri.parse(AppUrlV2.utilsBaseUrl + '/industries'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<FlagResponse> fetchFlags(int page) async {
  final response = await get(
    Uri.parse(AppUrl.utilsBaseUrl + '/flags/$page'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return FlagResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<NotificationResponse> fetchNotifications(int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.utilsBaseUrl + '/notifications/$page'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return NotificationResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> toggleLike(
    RequestAction action, LikeableType type, int likeableId) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse(AppUrlV2.likeBaseUrl + '/${likeableType(type)}/$likeableId'),
    headers: headers,
    body: jsonEncode({
      'action': action == RequestAction.Follow ? 'like' : 'unlike',
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    print(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> view(ViewableType type, int viewableId) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await put(
    Uri.parse(AppUrlV2.userBaseUrl + '/view/${viewableType(type)}/$viewableId'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    print(response.body);
    throw HttpException(data['message']);
  }
}

Future<String> pingServer() async {
  final response = await get(
    Uri.parse(AppUrl.baseURL + '/ping'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return response.body;
  else
    throw HttpException('Unable to ping server');
}

Future<Map<String, dynamic>> on_off_notification(String onof) async {
  // late passbookmodel dataModel;
  final userid=await getuserid;
  try {
    final headers = Global.jsonHeaders;
    headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
    final response = await http.get(
      Uri.parse('${Appurlv4.notificationurl}?userId=$userid&value=$onof'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return <String, dynamic>{
        'isError': false,
        'response': jsonResponse,
      };
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return <String, dynamic>{
        'isError': true,
        'response': response,
      };
    }
  } catch (e) {
    print(e.toString());
    return <String, dynamic>{
      'isError': true,
      'response': "something went wrong",
    };
  }
}


Future<Map<String, dynamic>> on_off_private_ac(String onof) async {
  final userid=await getuserid;
  try {
    final headers = Global.jsonHeaders;
    headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
    final response = await http.get(
      Uri.parse('${Appurlv4.privateacurl}?userId=$userid&value=$onof'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return <String, dynamic>{
        'isError': false,
        'response': jsonResponse,
      };
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return <String, dynamic>{
        'isError': true,
        'response': response,
      };
    }
  } catch (e) {
    print(e.toString());
    return <String, dynamic>{
      'isError': true,
      'response': "something went wrong",
    };
  }
}
