import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/enum.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/Story.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/utils.dart';

class NewStory {
  File? mediaFile;
  String content;
  StoryType type;
  String? caption;
  int? duration;

  NewStory({
    this.mediaFile,
    required this.content,
    required this.type,
    this.caption,
    this.duration,
  });

  Future<MultipartFile> get multipartFile async =>
      await fileToMultipart(mediaFile!, 'story');
}

Future<Story> createStory(NewStory newStory) async {
  // int byteCount = 0;
  // Stream<List<int>> stream2 = stream.transform(
  //   new StreamTransformer.fromHandlers(
  //     handleData: (data, sink) {
  //       byteCount += data.length;
  //       print(byteCount);
  //       sink.add(data);
  //     },
  //     handleError: (error, stack, sink) {},
  //     handleDone: (sink) {
  //       sink.close();
  //     },
  //   ),
  // );
  var uri = Uri.parse(AppUrlV2.userBaseUrl + '/story');
  MultipartRequest request = MultipartRequest('PUT', uri)
    ..headers.addAll(
      {
        HttpHeaders.authorizationHeader: 'Bearer ${await getToken}',
        ...Global.jsonHeaders
      },
    )
    ..fields['type'] = newStory.type == StoryType.IMAGE
        ? 'image'
        : newStory.type == StoryType.VIDEO
            ? 'video'
            : 'text'
    ..fields['content'] = newStory.content;
  if (newStory.caption != null)
    request..fields['caption'] = newStory.caption ?? '';
  if (newStory.duration != null)
    request..fields['duration'] = newStory.duration.toString();

  // if (newStory.mediaFile != null)
  //   request..files.add(await newStory.multipartFile);

  final httpResponse = await request.send();
  final response = await Response.fromStream(httpResponse);

  if (response.statusCode == 200)
    return Story.fromJson(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<List<User>> fetchUsersStoru() async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.userBaseUrl + '/story'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());

  if (response.statusCode == 200) {
    var users = List.from(jsonDecode(response.body))
        .map((e) => User.fromJson(e))
        .toList();
    return users;
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}