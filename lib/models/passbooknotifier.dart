import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class passbooknotifier extends ChangeNotifier {
  late Map<String, dynamic> pmodel;
  fetchData(context) async {
    pmodel = await getData(context);
    notifyListeners();
  }

  Future<Map<String, dynamic>> getData(context) async {
    // late passbookmodel dataModel;
    try {
      final response = await http.get(
          Uri.parse('https://api.the-owlette.com/v4/wallet/passbook?userId=1'));
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   dataModel = passbookmodel.fromJson(data);
      // }
      // else
      // {
      //   print("Something went wrong");
      // }
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
        'response': "noresponce",
      };
    }
  }
}
