import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:owlet/Providers/Flag.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';
import 'package:path/path.dart';

enum RequestAction { Follow, UnFollow }

Future<MultipartFile> multipartFileimage(File image, String name) async {
  var stream = new http.ByteStream(Stream.castFrom(image.openRead()));
  var length = await image.length();
  var multipartFile = new http.MultipartFile(
    name,
    stream,
    length,
    filename: basename(image.path),
  );
  return multipartFile;
}

final headers = Global.jsonHeaders;

Future<UserResponse> fetchUserFollowing(
    int id, int page, FollowType type, String? q) async {
  final fetchType = type == FollowType.FOLLOWING ? 'following' : 'followers';

  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.userBaseUrl +
        '/$fetchType/$id/$page' +
        (q != null ? '?q=$q' : '')),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());

  if (response.statusCode == 200)
    return UserResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> updateUser(Map<String, String> data) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await patch(
    Uri.parse(AppUrl.userBaseUrl),
    headers: headers,
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> confirmUser(Map<String, String> data) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await patch(
    Uri.parse(AppUrlV2.userBaseUrl + '/confirm'),
    headers: headers,
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> loanApply(Map<String, String> data) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse(AppUrlV2.userBaseUrl + '/loan/application'),
    headers: headers,
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> verifyProfile(
    Map<String, dynamic> data, File cert) async {
  var uri = Uri.parse(AppUrlV2.userBaseUrl + '/verify');
  http.MultipartRequest request = http.MultipartRequest('PUT', uri)
    ..headers.addAll(
      {
        HttpHeaders.authorizationHeader: 'Bearer ${await getToken}',
        ...Global.jsonHeaders
      },
    )
    ..fields['name'] = data['name'].toString()
    ..fields['publications'] = data['publications'].toString()
    ..fields['industryId'] = data['industryId'].toString()
    ..files.add(await multipartFileimage(cert, 'certificate'));

  final httpResponse = await request.send();
  final response = await Response.fromStream(httpResponse);

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> updateAvatar(File avatar) async {
  final avartar = await multipartFileimage(avatar, 'profile');
  var uri = Uri.parse(AppUrl.userBaseUrl + '/avatar');
  http.MultipartRequest request = http.MultipartRequest('PUT', uri)
    ..headers.addAll(
      {
        HttpHeaders.authorizationHeader: 'Bearer ${await getToken}',
        ...Global.jsonHeaders
      },
    )
    ..fields['caption'] = 'newListing.caption'
    ..files.add(avartar);

  final httpResponse = await request.send();
  final response = await Response.fromStream(httpResponse);
  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> toggleFollow(RequestAction action, int userId) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrl.userBaseUrl +
        (action == RequestAction.Follow
            ? '/follow/$userId'
            : '/unfollow/$userId')),
    headers:headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> blockUser(int userId) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrl.userBaseUrl + ('/block/$userId')),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> toggleHashtag(RequestAction action, String hashtag) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrl.hashTag +
        (action == RequestAction.Follow
            ? '/follow/$hashtag'
            : '/unfollow/$hashtag')),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<UserResponse> searchUsersTable(String query, int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.userBaseUrl + '/search/$query/$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return UserResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<User> getProfile(String username) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.userBaseUrl + '/$username'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> flagListing(NewFlag flagData) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await post(
    Uri.parse(AppUrl.userBaseUrl + '/flag/listing/${flagData.listingId}'),
    headers: headers,
    body: jsonEncode(<String, dynamic>{
      "listingId": flagData.listingId,
      "flagId": flagData.flagId,
      "reason": flagData.reason,
    }),
  );

  if (response.statusCode == 201) {
    final res = jsonDecode(response.body);
    return res;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
    // return data;
  }
}

Future<Map<String, dynamic>> sendEmailOtp(String type) async {
  final response = await post(
    Uri.parse(AppUrlV2.userBaseUrl + '/confirm/email'),
    headers: headers,
    body: jsonEncode(<String, String>{
      "type": type,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> sendSmsOtp(String type) async {
  final response = await post(
    Uri.parse(AppUrlV2.userBaseUrl + '/confirm/phone'),
    headers: headers,
    body: jsonEncode(<String, String>{
      "type": type,
    }),
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> fetchChats(int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.userBaseUrl + ('/chats/$page')),
    headers: headers,
  );

  if (response.statusCode == 200)
    return ChatResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}
