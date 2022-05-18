import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';


final headers = Global.jsonHeaders;
Future<Map<String, dynamic>> createComment(
    String message, int commentableId, CommentableType type,
    {int? parentId}) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await put(
    Uri.parse(AppUrlV2.commentsBaseUrl +
        '/${commentableType(type)}/$commentableId${parentId != null ? "/$parentId" : ""}'),
    headers: headers,
    body: jsonEncode({'message': message}),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<CommentResponse> fetchComments(
    CommentableType type, int commentableId, int page,
    {int? parentId}) async {
  print(parentId);
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.commentsBaseUrl +
        '/${commentableType(type)}/$commentableId/${parentId != null ? '$parentId/' : ""}$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  if (response.statusCode == 200)
    return CommentResponse.fromJson(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}
