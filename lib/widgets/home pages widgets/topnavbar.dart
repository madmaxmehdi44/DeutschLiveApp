import 'package:flutter/material.dart';

import 'package:deutschliveapp/services/routing.dart';
import 'package:deutschliveapp/widgets/home%20pages%20widgets/topnavbutton.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({
    super.key,
    required this.focusedIndex,
    required this.updateFocus,
    required this.isTV,
  });

  final int focusedIndex;
  final Function(int) updateFocus;
  final bool isTV;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TopNavButton(
            label: "عضویت",
            index: 0,
            focusedIndex: focusedIndex,
            updateFocus: updateFocus,
            isTV: isTV,
            onSelect: goToContactPage,
          ),
          TopNavButton(
            label: "زنـده",
            index: 1,
            focusedIndex: focusedIndex,
            updateFocus: updateFocus,
            isTV: isTV,
            onSelect: goToChannelListPage,
          ),
          TopNavButton(
            label: "لیست",
            index: 2,
            focusedIndex: focusedIndex,
            updateFocus: updateFocus,
            isTV: isTV,
            onSelect: goToFavoritesPage,
          ),
        ],
      ),
    );
  }
}
