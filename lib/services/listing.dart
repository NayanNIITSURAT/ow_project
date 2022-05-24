import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:http/http.dart' as http;
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/helpers/helpers.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/services/apiUrl.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

class NewListing {
  List<File> images;
  String caption;

  NewListing({
    required this.images,
    required this.caption,
  });

  Future<List<MultipartFile>> multipartFileimages() async {
    List<MultipartFile> imagesList = [];
    for (int i = 0; i < images.length; i++)
      imagesList.add(await fileToMultipart(images[i], 'listingImages'));

    return imagesList;

    //   var stream = new http.ByteStream(Stream.castFrom(images[0].openRead()));
    //   // get file length
    //   var length = await images[0].length();
    //   var multipartFile = new http.MultipartFile('myFile', stream, length,
    //       filename: basename(images[0].path));

    //   return multipartFile;
  }
}

final headers = Global.jsonHeaders;

Future<ListingResponse> fetchListings(int page, {String? type}) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.listingBaseUrl +
        '/feeds/${type != null ? type + '/' : ''}$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return ListingResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Listing> fetchListing(int id) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.listingBaseUrl + '/$id'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return Listing.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<ListingResponse> fetchUserListings(int page, String? username) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.listingBaseUrl + '/feeds/${username ?? 'user'}/$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return ListingResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<InitData> fetchInitData(String type) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV3.listingBaseUrl + '/init/$type'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return InitData.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    print(data);
    throw HttpException(data['message']);
  }
}

Future<Map<String, dynamic>> fetchHashTagListings(String tag, int page) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await get(
    Uri.parse(AppUrlV2.hashTagUrl + '/$tag/$page'),
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

Future<Listing> createListing(NewListing newListing) async {
  var uri = Uri.parse(AppUrl.listingBaseUrl);
  http.MultipartRequest request = http.MultipartRequest('PUT', uri)
    ..headers.addAll(
      {
        HttpHeaders.authorizationHeader: 'Bearer ${await getToken}',
        ...Global.jsonHeaders
      },
    )
    ..fields['caption'] = newListing.caption
    ..files.addAll(await newListing.multipartFileimages());

  final httpResponse = await request.send();
  final response = await Response.fromStream(httpResponse);

  if (response.statusCode == 201) {
    final res = jsonDecode(response.body);
    return Listing.fromJson(res);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<Listing> patchListing(String caption, int id) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await patch(
    Uri.parse(AppUrl.listingBaseUrl + '/$id'),
    headers: headers,
    body: jsonEncode({'caption': caption}),
  );

  if (response.statusCode == 200) {
    var res = jsonDecode(response.body);
    return Listing.fromJson(res);
  } else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<dynamic> deleteListing(int listingId) async {
  headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  final response = await delete(
    Uri.parse(AppUrl.listingBaseUrl + '/$listingId'),
    headers: headers,
  );

  if (response.statusCode == 200)
    return jsonDecode(response.body);
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}

Future<ListingResponse> searchListingsTable(String query, int page) async {
  final response = await get(
    Uri.parse(AppUrl.searchListingUrl + '/$query/$page'),
    headers: headers,
  );
  // print(jsonDecode(response.body).toString());
  // print('Basic ${await getToken}');

  if (response.statusCode == 200)
    return ListingResponse.fromJson(jsonDecode(response.body));
  else {
    var data = jsonDecode(response.body);
    throw HttpException(data['message']);
  }
}
