import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

class Flag {
  final String name;
  final int id;

  Flag({required this.name, required this.id});

  factory Flag.fromJson(Map<String, dynamic> json) {
    return Flag(
      name: json['name'],
      id: json['id'],
    );
  }
}

class NewFlag {
  int flagId;
  int listingId;
  String? reason;

  NewFlag({
    required this.flagId,
    required this.listingId,
    this.reason,
  });
}

class FlagProvider with ChangeNotifier {
  Status _flagStatus = Status.Idle;
  Status _flagingStatus = Status.Idle;

  FlagResponse flagData = FlagResponse(
    totalItems: 0,
    flags: [],
    totalPages: 0,
    currentPage: -1,
  );

  FlagProvider() {
    if (flagData.totalItems < 1) getFlags(refresh: true);
  }

  // var _showFavs = false;

  List<Flag> get items {
    return [...flagData.flags];
  }

  Status get flagStatus {
    return _flagStatus;
  }

  Status get flagingStatus {
    return _flagingStatus;
  }

  Future<Map<String, dynamic>> getFlags({bool refresh: false}) async {
    if (_flagStatus != Status.Processing)
      try {
        _flagStatus = Status.Processing;
        notifyListeners();
        flagData.setFlagsData =
            await fetchFlags(refresh ? 0 : flagData.currentPage + 1);

        _flagStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _flagStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _flagStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  Future<dynamic> flagPost(NewFlag newFlag) async {
    _flagingStatus = Status.Processing;
    notifyListeners();
    try {
      final res = await flagListing(newFlag);
      var result = {
        'status': true,
        'message': res['message'],
      };

      _flagingStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      _flagingStatus = Status.Failed;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }
}
