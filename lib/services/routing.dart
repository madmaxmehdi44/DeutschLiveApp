import 'package:flutter/material.dart';

import 'package:deutschliveapp/pages/channelpage_iptv.dart';

import '../pages/home pages/channellistpage.dart';
import '../pages/home pages/contactpage.dart';
import '../pages/home pages/favoritespage.dart';
// import 'package:deutschliveapp/pages/channelpage_youtube.dart';

class NoAnimationRoute<T> extends MaterialPageRoute<T> {
  NoAnimationRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

void goToChannelListPage({required BuildContext context, required bool isTV}) {
  Navigator.push(
    context,
    NoAnimationRoute(
      builder: (context) => ChannelListPage(
        isTV: isTV,
      ),
    ),
  );
}

void goToFavoritesPage({required BuildContext context, required bool isTV}) {
  Navigator.push(
    context,
    NoAnimationRoute(
      builder: (context) => FavoritesPage(
        isTV: isTV,
      ),
    ),
  );
}

void goToContactPage({required BuildContext context, required bool isTV}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ContactPage(
        isTV: isTV,
      ),
    ),
  );
}

void goToChannelPageIPTV(
    {required BuildContext context, required int index, required bool isTV}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChannelPageIPTV(
        index: index,
        isTV: isTV,
      ),
    ),
  );
}

// goToChannelPageYouTube(
//     {required BuildContext context, required int index, required bool isTV}) {
//   Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => ChannelPageYouTube(
//                 index: index,
//                 isTV: isTV,
//               )));
// }
