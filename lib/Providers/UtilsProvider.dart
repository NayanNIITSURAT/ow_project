import 'package:flutter/material.dart';
import 'package:owlet/Providers/Auth.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/models/HttpResponse.dart';
import 'package:owlet/models/Listing.dart';
import 'package:owlet/models/User.dart';
import 'package:owlet/services/listing.dart';
import 'package:owlet/services/user.dart';
import 'package:owlet/services/utils.dart';

class UtilsProvider with ChangeNotifier {
  User? _currentSellerProfile;
  Status _searchStatus = Status.Idle;
  Status _hashTagStatus = Status.Idle;
  Status _listingStatus = Status.Idle;
  Status _sellerListingStatus = Status.Idle;
  Status _userStatus = Status.Idle;
  Status _sellerStatus = Status.Idle;
  String _searchQuery = '';

  UtilsProvider() {
    searchAll('null');
  }

  ListingResponse sellerListingData = ListingResponse(
    totalItems: 0,
    listings: [],
    totalPages: 0,
    currentPage: -1,
  );

  set toggleLike(int id) {
    sellerListingData.toggleLike = id;
    notifyListeners();
  }

  List<Listing> get sellerListing {
    return [...sellerListingData.listings];
  }

  get sellerListingStatus {
    return _sellerListingStatus;
  }

  set updateSellerListingsData(ListingResponse newData) {
    if (sellerListingData.currentPage + 1 == newData.currentPage) {
      sellerListingData = ListingResponse(
        listings: [
          ...sellerListingData.listings,
          ...newData.listings,
        ],
        totalItems: newData.totalItems,
        totalPages: newData.totalPages,
        currentPage: newData.currentPage,
      );
    }
    _sellerListingStatus = Status.Completed;
    notifyListeners();
  }

  set refreshSellerListingsData(ListingResponse newData) {
    sellerListingData = ListingResponse(
      listings: newData.listings,
      totalItems: newData.totalItems,
      totalPages: newData.totalPages,
      currentPage: newData.currentPage,
    );
    _sellerListingStatus = Status.Completed;
    notifyListeners();
  }

  set hideListing(int id) {
    sellerListingData.hideListing = id;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getUserListings({bool refresh: false}) async {
    if (_sellerListingStatus != Status.Processing)
      try {
        _sellerListingStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          sellerListingData =
              await fetchUserListings(0, _currentSellerProfile!.username);
        } else {
          if (sellerListingData.totalPages != sellerListingData.currentPage)
            sellerListingData.setListingsData = await fetchUserListings(
                sellerListingData.currentPage + 1,
                _currentSellerProfile!.username);
        }
        _sellerListingStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
          'listingData': sellerListingData
        };
      } catch (error) {
        _sellerListingStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _sellerListingStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  /* --------------------------------------------------------- */
  // Global Search Section
  /* --------------------------------------------------------- */

  Status get searchStatus {
    return _searchStatus;
  }

  String get searchQuery {
    return _searchQuery;
  }

  Future<Map<String, dynamic>> searchAll(String query) async {
    if (_searchStatus != Status.Processing) {
      _searchQuery = query;
      try {
        _searchStatus = Status.Processing;
        notifyListeners();
        final res = await searchDb(
            (query.length < 1 ? 'null' : query).toLowerCase(), 0);

        userSearchResult = UserResponse.fromJson(res['users']);
        tagSearchResult = HashTagResponse.fromJson(res['hashtags']);
        listingSearchResult = ListingResponse.fromJson(res['listings']);

        _searchStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _searchStatus = Status.Failed;
        notifyListeners();

        print(error.toString());

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    } else {
      _searchStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }

  /* --------------------------------------------------------- */
  // Hashtags Section
  /* --------------------------------------------------------- */

  HashTagResponse tagSearchResult = HashTagResponse(
    totalItems: 0,
    tags: [],
    totalPages: 0,
    currentPage: -1,
  );
  Status get hashTagStatus {
    return _hashTagStatus;
  }

  List<HashTag> get hashtags {
    return [...tagSearchResult.tags];
  }

  set updateTagsData(HashTagResponse newData) {
    if (tagSearchResult.currentPage + 1 == newData.currentPage) {
      tagSearchResult = HashTagResponse(
        tags: [
          ...tagSearchResult.tags,
          ...newData.tags,
        ],
        totalItems: newData.totalItems,
        totalPages: newData.totalPages,
        currentPage: newData.currentPage,
      );
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> searchHashtags({bool refresh: false}) async {
    if (_hashTagStatus != Status.Processing)
      try {
        _hashTagStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          tagSearchResult = await searchTag(_searchQuery.toLowerCase(), 0);
        } else {
          if (tagSearchResult.totalPages > tagSearchResult.currentPage)
            tagSearchResult.updateTagsData = await searchTag(
                _searchQuery.toLowerCase(), tagSearchResult.currentPage + 1);
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

  /* --------------------------------------------------------- */
  // Listings Section
  /* --------------------------------------------------------- */

  ListingResponse listingSearchResult = ListingResponse(
    totalItems: 0,
    listings: [],
    totalPages: 0,
    currentPage: -1,
  );
  Status get listingStatus {
    return _listingStatus;
  }

  List<Listing> get listings {
    return [...listingSearchResult.listings];
  }

  Future<Map<String, dynamic>> searchListings({bool refresh: false}) async {
    if (_listingStatus != Status.Processing)
      try {
        _listingStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          listingSearchResult =
              await searchListingsTable(_searchQuery.toLowerCase(), 0);
        } else {
          if (listingSearchResult.totalPages > listingSearchResult.currentPage)
            listingSearchResult.setListingsData = await searchListingsTable(
                _searchQuery.toLowerCase(),
                listingSearchResult.currentPage + 1);
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

  /* --------------------------------------------------------- */
  // Users Section
  /* --------------------------------------------------------- */
  UserResponse userSearchResult = UserResponse(
    totalItems: 0,
    users: [],
    totalPages: 0,
    currentPage: -1,
  );
  Status get userStatus {
    return _userStatus;
  }

  List<User> get users {
    return [...userSearchResult.users];
  }

  User? get currentSellerProfile {
    return _currentSellerProfile;
  }

  set updateUsersData(UserResponse newData) {
    if (listingSearchResult.currentPage + 1 == newData.currentPage) {
      userSearchResult = UserResponse(
        users: [
          ...userSearchResult.users,
          ...newData.users,
        ],
        totalItems: newData.totalItems,
        totalPages: newData.totalPages,
        currentPage: newData.currentPage,
      );
    }
    notifyListeners();
  }

  getCurrentSellerProfile(User user) async {
    if (currentSellerProfile == null ||
        user.username != currentSellerProfile!.username) {
      _sellerStatus = Status.Processing;
      notifyListeners();
      final res = await UserProvider().retrieveProfile(user.id.toString());
      currentSellerProfile = res['user'];
      _sellerStatus = Status.Completed;
      notifyListeners();
      getUserListings(refresh: true);
    }
  }

  getCurrentProfileFromUsername(String username) async {
    _sellerStatus = Status.Processing;
    notifyListeners();
    final res = await UserProvider().retrieveProfile(username);
    currentSellerProfile = res['user'];
    _sellerStatus = Status.Completed;
    notifyListeners();
    if (currentSellerProfile != null) {
      getUserListings(refresh: true);
    }
  }

  set currentSellerProfile(User? user) {
    _currentSellerProfile = user;
    sellerListingData = ListingResponse(
      totalItems: 0,
      listings: [],
      totalPages: 0,
      currentPage: -1,
    );
    notifyListeners();
  }

  get sellerStatus {
    return _sellerStatus;
  }

  Future<Map<String, dynamic>> retrieveSellerProfile(String username) async {
    _sellerStatus = Status.Processing;
    notifyListeners();
    try {
      currentSellerProfile = await getProfile(username);
      var result = {
        'status': true,
        'message': 'Login Successful',
        'user': currentSellerProfile
      };

      _sellerStatus = Status.Completed;
      notifyListeners();

      return result;
    } catch (error) {
      _sellerStatus = Status.Failed;
      notifyListeners();

      return {
        'status': false,
        'message': error.toString(),
        'data': error,
      };
    }
  }

  Future<Map<String, dynamic>> searchUsers({bool refresh: false}) async {
    if (_userStatus != Status.Processing)
      try {
        _userStatus = Status.Processing;
        notifyListeners();
        if (refresh) {
          userSearchResult =
              await searchUsersTable(_searchQuery.toLowerCase(), 0);
        } else {
          if (userSearchResult.totalPages > userSearchResult.currentPage)
            userSearchResult.updateUsersData = await searchUsersTable(
                _searchQuery.toLowerCase(), userSearchResult.currentPage + 1);
        }
        _userStatus = Status.Completed;
        notifyListeners();

        return {
          'status': true,
          'message': 'Fetching commpelted',
        };
      } catch (error) {
        _userStatus = Status.Failed;
        notifyListeners();

        return {
          'status': false,
          'message': error.toString(),
          'data': error,
        };
      }
    else {
      _userStatus = Status.Completed;
      return {
        'status': false,
        'message': 'Processing',
      };
    }
  }
}
