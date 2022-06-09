import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/services/listing.dart';
import 'package:owlet/services/user.dart';

class HashTag extends ChangeNotifier {
  final String tag;
  bool iFollow;
  int totalListings;

  HashTag({required this.tag, this.iFollow = false, this.totalListings = 0});

  factory HashTag.fromJson(Map<String, dynamic> json) {
    return HashTag(
      tag: json['tag'].toLowerCase(),
      totalListings: json['totalListings'],
      iFollow: json['iFollow'] == 1,
    );
  }

  void toggleHashTagFollow() async {
    // print(tag);
    // print(hashTags);
    if (iFollow) {
      iFollow = false;
      notifyListeners();
      await toggleHashtag(RequestAction.UnFollow, tag);
    } else {
      iFollow = true;
      notifyListeners();
      await toggleHashtag(RequestAction.Follow, tag);
    }
  }
}

final initListingData = ListingResponse(
  totalItems: 0,
  listings: [],
  totalPages: 0,
  currentPage: -1,
);

class HashTagProvider with ChangeNotifier {
  HashTag _currentHashTag = HashTag(tag: '');
  Status _hashTagStatus = Status.Idle;

  ListingResponse listingData = initListingData;

  // var _showFavs = false;

  List<Listing> get items {
    return [...listingData.listings];
  }

  Status get hashTagStatus {
    return _hashTagStatus;
  }

  set toggleLike(int id) {
    listingData.toggleLike = id;
    notifyListeners();
  }

  toggleHashTagFollow() {
    _currentHashTag.toggleHashTagFollow();
    notifyListeners();
  }

  // var _showFavs = false;

  HashTag get tagData {
    return _currentHashTag;
  }

  Future setTagData(String tag) async {
    if (tag.toLowerCase() != _currentHashTag.tag.toLowerCase()) {
      listingData = initListingData;
      notifyListeners();
      _currentHashTag = HashTag(tag: tag);
      listingData = initListingData;
      notifyListeners();
      await getListings(hashtag: tag, refresh: true);
    }
  }

  Future<Map<String, dynamic>> getListings(
      {bool refresh: false, required String hashtag}) async{
    if (_hashTagStatus != Status.Processing)
      try {
        _hashTagStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          final res = await fetchHashTagListings(hashtag.toLowerCase(), 0);

          if (res['hashtag'] != null)
            _currentHashTag = HashTag.fromJson(res['hashtag']);
          listingData = ListingResponse.fromJson(res);
        } else {
          if (listingData.totalPages > listingData.currentPage) {
            final res = await fetchHashTagListings(
                hashtag.toLowerCase(), listingData.currentPage + 1);
            listingData.setListingsData = ListingResponse.fromJson(res);
          }
        }
        _hashTagStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _hashTagStatus = Status.Failed;
        notifyListeners();
        print("the error is $error");
        print(error);

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _hashTagStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }
}
