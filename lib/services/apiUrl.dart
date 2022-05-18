const liveURL = 'https://api.the-owlette.com';
const localURL = 'http://192.168.88.11:9000';

const curURL = liveURL;

class AppUrl {
  // static const String localBaseURL = "http://192.168.88.14:9000/api";

  static const String baseURL = curURL;

  // Auth Urls
  static const String authBaseUrl = baseURL + '/auth';
  static const String loginUrl = authBaseUrl + '/login';
  static const String registerUrl = authBaseUrl + '/register';
  static const String changePasswordUrl = authBaseUrl + '/change_password';
  static const String forgotPassword = authBaseUrl + "/forgot-password";
  static const String resetPass = authBaseUrl + "/reset-password";
  static const String verifyOtp = authBaseUrl + "/verify-otp";
  static const String problem = authBaseUrl + "/reportProblem";

  // Listing Urls
  static const String listingBaseUrl = baseURL + '/listings';
  static const String hashTagUrl = listingBaseUrl + '/hashtag';
  static const String createListingUrl = listingBaseUrl + '/create';
  static const String searchListingUrl = listingBaseUrl + '/search';
  // static const String listingUrl = listingBaseUrl + '/listings';

  // Image Url
  static const String listingImageBaseUrl = baseURL + '/listing/';
  static const String profileImageBaseUrl = baseURL + '/profile/';

  // User Url
  static const String userBaseUrl = baseURL + '/users';
  static const String topFollowingUrl = userBaseUrl + '/top-following';
  static const String userFollowingUrl = userBaseUrl + '/following';
  static const String hashTag = userBaseUrl + '/hashtag';

  // Utils Url
  static const String utilsBaseUrl = baseURL + '/utility';
  static const String dbSearchUrl = utilsBaseUrl + '/search';
}

class AppUrlV2 {
  static const String baseURL = curURL + '/v2';

  // Auth Urls
  static const String authBaseUrl = baseURL + '/auth';
  static const String loginUrl = authBaseUrl + '/login';
  static const String registerUrl = authBaseUrl + '/register';
  static const String changePasswordUrl = authBaseUrl + '/change_password';
  static const String forgotPassword = authBaseUrl + "/forgot-password";
  static const String resetPass = authBaseUrl + "/reset-password";
  static const String verifyOtp = authBaseUrl + "/verify-otp";

  // Listing Urls
  static const String listingBaseUrl = baseURL + '/listings';
  static const String hashTagUrl = listingBaseUrl + '/hashtag';
  static const String createListingUrl = listingBaseUrl + '/create';
  static const String searchListingUrl = listingBaseUrl + '/search';
  // static const String listingUrl = listingBaseUrl + '/listings';

  // Image Url
  static const String listingImageBaseUrl = baseURL + '/listing/';
  static const String profileImageBaseUrl = baseURL + '/profile/';

  // User Url
  static const String userBaseUrl = baseURL + '/users';
  static const String topFollowingUrl = userBaseUrl + '/top-following';
  static const String hashTag = userBaseUrl + '/hashtag';

  // Utils Url
  static const String utilsBaseUrl = baseURL + '/utility';
  static const String dbSearchUrl = utilsBaseUrl + '/search';

  // Comment Url
  static const String commentsBaseUrl = baseURL + '/comments';

  // Like Url
  static const String likeBaseUrl = baseURL + '/like';
}

class AppUrlV3 {
  static const String baseURL = curURL + '/v3';

  // Auth Urls
  static const String authBaseUrl = baseURL + '/auth';
  static const String loginUrl = authBaseUrl + '/login';
  static const String registerUrl = authBaseUrl + '/register';
  static const String problem = authBaseUrl + "/reportProblem";

  // Listing Urls
  static const String listingBaseUrl = baseURL + '/listings';

  // Image Url

  // User Url

  // Utils Url
}
