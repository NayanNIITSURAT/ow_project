import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:owlet/Providers/GlobalProvider.dart';
import 'package:owlet/Providers/HashTagProvider.dart';
import 'package:owlet/Providers/Listing.dart';
import 'package:owlet/Providers/User.dart';
import 'package:owlet/Providers/UtilsProvider.dart';
import 'package:owlet/Widgets/ListingsListView.dart';
import 'package:owlet/constants/constants.dart';
import 'package:owlet/constants/palettes.dart';
import 'package:owlet/enum.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

final formatter = NumberFormat('#,###,000');

bool hasHashtag(String text) {
  final RegExp hashRegex = RegExp(r"" + "( #)(\\w+)");
  return hashRegex.hasMatch(text.replaceAll("\n", " "));
}

Future<http.MultipartFile> fileToMultipart(File file, String name) async {
  var stream = new http.ByteStream(Stream.castFrom(file.openRead()));
  var length = await file.length();
  var multipartFile = new http.MultipartFile(
    name,
    stream,
    length,
    filename: basename(file.path),
  );
  return multipartFile;
}

TextSpan formatHashTags(
  String text,
  Function(String hashTag) onTapHashTag,
  Function(String atMention) onTapMention,
) {
  final List<InlineSpan> textSpans = [];
  text = " " + text;

  int start = 0;
  loop(String text, String regex) {
    final RegExp hashRegex = RegExp(r"" + "$regex(\\w+)");
    final Iterable<Match> matches = hashRegex.allMatches(text);

    // text = text.substring(1);

    for (final Match match in matches) {
      textSpans.add(TextSpan(text: text.substring(start, match.start)));
      textSpans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => match.group(2)!.length > 0
                ? match.group(1) == '#'
                    ? onTapHashTag(match.group(2)!)
                    : onTapMention(match.group(2)!)
                : null,
            child: '${match.group(1)}${match.group(2)}'
                .text
                .size(Global.fontSize)
                .lineHeight(1)
                .color(Palette.primaryColor)
                .make(),
          ),
        ),
      );
      start = match.end;
    }
  }

  loop(text, "( @|#)");

  textSpans.add(TextSpan(text: text.substring(start, text.length)));
  return TextSpan(children: textSpans);
}

void handleTagAtInput(
  String text, {
  Function(String hashTag)? onTapHashTag,
  Function(String atMention)? onTapMention,
}) {
  loop(String text, String regex) {
    final RegExp hashRegex = RegExp(r"" + "$regex(\\w+)");

    var lastWord = text.split('pattern').last;
    final _lwm = hashRegex.firstMatch(lastWord);
    if (_lwm != null && _lwm.group(2)!.length > 0)
      _lwm.group(1) == '#'
          ? onTapHashTag!(_lwm.group(2)!)
          : onTapMention!(_lwm.group(2)!);
  }

  loop(text, "( @|#)");
}

void launchURL(String url) async =>
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

Future<void> customLaunch(String command) async {
  if (await canLaunch(command)) {
    await launch(command);
  } else {
    print(' could not launch $command');
  }
}

final ChangeNotifier Function(BuildContext, ListingProviderType) getProvider =
    (context, providerType) {
  switch (providerType) {
    case ListingProviderType.SELLER:
    case ListingProviderType.SEARCHLISTING:
      return Provider.of<UtilsProvider>(context);

    case ListingProviderType.LISTING:
      return Provider.of<ListingProvider>(context);

    case ListingProviderType.HASHTAG:
      return Provider.of<HashTagProvider>(context);

    case ListingProviderType.USER:
      return Provider.of<UserProvider>(context);
  }
};

ListingViewData Function(dynamic, ListingProviderType) getListingData =
    (provider, type) {
  switch (type) {
    case ListingProviderType.SELLER:
      return ListingViewData(
        listings: provider.sellerListing,
        refresh: () => provider.getUserListings(refresh: true),
        load: provider.getUserListings,
      );

    case ListingProviderType.LISTING:
      return ListingViewData(
        listings: provider.items,
        refresh: () => provider.getListings(refresh: true),
        load: provider.getListings,
      );

    case ListingProviderType.HASHTAG:
      return ListingViewData(
        listings: provider.items,
        refresh: () =>
            provider.getListings(refresh: true, hashtag: provider.tagData.tag),
        load: () => provider.getListings(hashtag: provider.tagData.tag),
      );

    case ListingProviderType.USER:
      return ListingViewData(
        listings: provider.listings,
        refresh: () => provider.getListings(refresh: true),
        load: provider.getListings,
      );

    case ListingProviderType.SEARCHLISTING:
      return ListingViewData(
        listings: provider.listings,
        refresh: () => provider.searchListings(refresh: true),
        load: provider.searchListings,
      );
  }
  ;
};

String numFormatter(int num) {
  if (num > 999 && num < 1000000)
    return (num / 1000).toStringAsFixed(1) +
        'k'; // convert to K for number from > 1000 < 1 million
  else if (num > 1000000)
    return (num / 1000000).toStringAsFixed(1) +
        'm'; // convert to M for number from > 1 million
  else
    return '$num'; // if value < 1000, nothing to do
}

String timeAgo(String timestamp) {
  final year = int.parse(timestamp.substring(0, 4));
  final month = int.parse(timestamp.substring(5, 7));
  final day = int.parse(timestamp.substring(8, 10));
  final hour = int.parse(timestamp.substring(11, 13));
  final minute = int.parse(timestamp.substring(14, 16));

  final DateTime videoDate = DateTime(year, month, day, hour, minute);
  final int diffInHours = DateTime.now().difference(videoDate).inHours;

  String timeAgo = '';
  String timeUnit = '';
  int timeValue = 0;

  if (diffInHours < 1) {
    final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
    timeValue = diffInMinutes;
    timeUnit = 'min';
  } else if (diffInHours < 24) {
    timeValue = diffInHours;
    timeUnit = 'hr';
  } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
    timeValue = (diffInHours / 24).floor();
    timeUnit = 'd';
  } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
    timeValue = (diffInHours / (24 * 7)).floor();
    timeUnit = 'w';
  } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
    timeValue = (diffInHours / (24 * 30)).floor();
    timeUnit = 'M';
  } else {
    timeValue = (diffInHours / (24 * 365)).floor();
    timeUnit = 'yr';
  }

  timeAgo = timeValue.toString() + ' ' + timeUnit;
  timeAgo += timeValue > 1 ? 's' : '';

  return timeValue > 0 ? timeAgo + '' : 'just now';
}

commentableType(CommentableType type) {
  switch (type) {
    case CommentableType.LISTING:
      return 'listing';
    case CommentableType.REEL:
      return 'reel';
    case CommentableType.STORY:
      return 'story';
    default:
      return null;
  }
}

likeableType(LikeableType type) {
  switch (type) {
    case LikeableType.LISTING:
      return 'listing';
    case LikeableType.REEL:
      return 'reel';
    case LikeableType.STORY:
      return 'story';
    case LikeableType.COMMENT:
      return 'comment';
    default:
      return null;
  }
}

viewableType(ViewableType type) {
  switch (type) {
    case ViewableType.LISTING:
      return 'listing';
    case ViewableType.REEL:
      return 'reel';
    case ViewableType.STORY:
      return 'story';
    case ViewableType.PROFILE:
      return 'profile';
    default:
      return null;
  }
}

String chatableType(ChatState status) => status == ChatState.SNEDING
    ? 'sending'
    : status == ChatState.SENT
        ? 'sent'
        : status == ChatState.DELIVERED
            ? 'delivered'
            : status == ChatState.SEEN
                ? 'seen'
                : 'sending';

degreeToAngle(double deg) => deg * pi / 180;

fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(int? r, int? g, int? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928
          ? value / 12.92
          : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) /
        luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}

/// Controller to sync playback between animated child (story) views. This
/// helps make sure when stories are paused, the animation (gifs/slides) are
/// also paused.
/// Another reason for using the controller is to place the stories on `paused`
/// state when a media is loading.
class StoryController {
  /// Stream that broadcasts the playback state of the stories.
  final playbackNotifier = BehaviorSubject<PlaybackState>();

  /// Notify listeners with a [PlaybackState.pause] state
  void pause() {
    playbackNotifier.add(PlaybackState.pause);
  }

  /// Notify listeners with a [PlaybackState.play] state
  void play() {
    playbackNotifier.add(PlaybackState.play);
  }

  void next() {
    playbackNotifier.add(PlaybackState.next);
  }

  void previous() {
    playbackNotifier.add(PlaybackState.previous);
  }

  /// Remember to call dispose when the story screen is disposed to close
  /// the notifier stream.
  void dispose() {
    playbackNotifier.close();
  }
}

class SwipeController {
  /// Stream that broadcasts the swipe action for pages.
  final swipeActionNotifier = BehaviorSubject<SwipeAction>();

  void next() {
    swipeActionNotifier.add(SwipeAction.next);
  }

  void previous() {
    swipeActionNotifier.add(SwipeAction.previous);
  }

  StreamSubscription<SwipeAction> Function(void Function(SwipeAction)?,
      {bool? cancelOnError,
      void Function()? onDone,
      Function? onError}) get addListener => swipeActionNotifier.listen;

  /// Remember to call dispose when the story screen is disposed to close
  /// the notifier stream.
  void dispose() {
    swipeActionNotifier.close();
  }
}
