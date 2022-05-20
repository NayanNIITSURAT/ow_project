import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/listing.dart';

class ListingProvider with ChangeNotifier {
  ListingResponse listingData = ListingResponse(
    totalItems: 0,
    listings: [],
    totalPages: 0,
    currentPage: -1,
  );

  set hideListing(int id) {
    listingData.hideListing = id;
    listingDataForMe.hideListing = id;
    notifyListeners();
  }

  set toggleLike(int id) {
    listingData.toggleLike = id;
    listingDataForMe.toggleLike = id;
    notifyListeners();
  }

  set comment(int id) {
    listingDataForMe.addComment = id;
    listingData.addComment = id;
    notifyListeners();
  }

  set unfollowUser(User user) {
    listingData.unfollowUser = user;
    listingDataForMe.unfollowUser = user;
    notifyListeners();
  }

  set clearData(_) {
    listingData = ListingResponse(
      totalItems: 0,
      listings: [],
      totalPages: 0,
      currentPage: -1,
    );
    listingDataForMe = ListingResponse(
      totalItems: 0,
      listings: [],
      totalPages: 0,
      currentPage: -1,
    );
    notifyListeners();
  }

  ListingProvider();
  // var _showFavs = false;
  Status _listingStatus = Status.Idle;

  List<Listing> get items {
    return [...listingData.listings];
  }

  Status get listingStatus {
    return _listingStatus;
  }

  Future<Map<String, dynamic>> getListings({bool refresh: false}) async {
    // UserPreferences().unHideAllListing();
    if (_listingStatus != Status.Processing)
      try {
        _listingStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          listingData = await fetchListings(0);
        } else {
          if (listingData.totalPages != listingData.currentPage)
            listingData.setListingsData =
                await fetchListings(listingData.currentPage + 1);
        }
        _listingStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _listingStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _listingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  ListingResponse listingDataForMe = ListingResponse(
    totalItems: 0,
    listings: [],
    totalPages: 0,
    currentPage: -1,
  );
  Status _listingForMeStatus = Status.Idle;

  List<Listing> get itemsForMe {
    return [...listingDataForMe.listings];
  }

  Status get listingForMeStatus {
    return _listingForMeStatus;
  }

  Future<Map<String, dynamic>> getListingsForMe({bool refresh: false}) async {
    // UserPreferences().unHideAllListing();
    if (_listingForMeStatus != Status.Processing)
      try {
        _listingForMeStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          listingDataForMe = await fetchListings(0, type: 'following');
        } else {
          if (listingDataForMe.totalPages != listingDataForMe.currentPage)
            listingDataForMe.setListingsData = await fetchListings(
                listingDataForMe.currentPage + 1,
                type: 'following');
        }
        _listingForMeStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _listingForMeStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _listingForMeStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  Future<Map<String, dynamic>> getUserListings(
      {bool refresh: false, required String username}) async {
    if (_listingStatus != Status.Processing)
      try {
        _listingStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          listingData = await fetchListings(0);
        } else {
          if (listingData.totalPages != listingData.currentPage)
            listingData.setListingsData =
                await fetchListings(listingData.currentPage + 1);
        }
        _listingStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
          'listingData': listingData
        };
      } catch (error) {
        _listingStatus = Status.Failed;
        notifyListeners();
        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _listingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  Future<Map<String, dynamic>> addListing(NewListing listing) async {
    _listingStatus = Status.Adding;
    notifyListeners();
    try {
      final newListing = await createListing(listing);
      listingData.newListing = newListing;
      listingDataForMe.newListing = newListing;

      _listingStatus = Status.Completed;
      notifyListeners();

      return {
        'message': 'Listing created',
        'status': true,
        'data': newListing,
      };
    } catch (error) {
      print("the error is $error here");

      _listingStatus = Status.Failed;
      notifyListeners();

      return {'message': error.toString(), 'status': false};
    }
  }

  Future<Map<String, dynamic>> updateListing(
      String caption, int listingId) async {
    _listingStatus = Status.Updating;
    notifyListeners();
    try {
      final updatedListing = await patchListing(caption, listingId);
      listingData.updatedListing = updatedListing;

      _listingStatus = Status.Completed;
      notifyListeners();

      return {
        'message': 'Post updated',
        'status': true,
        'data': updatedListing,
      };
    } catch (error) {
      print("the error is $error here");

      _listingStatus = Status.Failed;
      notifyListeners();

      return {'message': error.toString(), 'status': false};
    }
  }

  set removeListing(int listingId) => listingData.removeListing = listingId;
}
