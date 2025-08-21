// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:deutschliveapp/models/channel.dart';
import 'package:deutschliveapp/services/dpadoption.dart';
import 'package:deutschliveapp/services/formatting.dart';

class ChannelListItem extends StatelessWidget {
  final String channelName;
  final Source source;
  final bool isFocused;
  final bool isFavoriteFocused;
  final Function() onChannelSelect;
  final Function() onFavoriteSelect;
  final Function(bool) onChannelFocus;
  final Function(bool) onFavoriteFocus;
  final Icon favoriteIcon;
  final String contactpage;

  const ChannelListItem({
    super.key,
    required this.channelName,
    required this.source,
    required this.isFocused,
    required this.isFavoriteFocused,
    required this.onChannelSelect,
    required this.onFavoriteSelect,
    required this.onChannelFocus,
    required this.onFavoriteFocus,
    required this.favoriteIcon,
    required this.contactpage,
  });

  @override
  Widget build(BuildContext context) {
    FormattingProvider formattingProvider = FormattingProvider();
    Color? channelColor =
        isFocused ? const Color.fromARGB(255, 236, 246, 100) : null;
    Color? starColor = isFavoriteFocused ? Colors.blue[300] : null;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: DpadOption(
              onSelect: onChannelSelect,
              onFocus: onChannelFocus,
              child: GestureDetector(
                onTap: onChannelSelect,
                child: Card(
                  color: channelColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            // child: formattingProvider.formatIcon(source),
                            child: Image.network(contactpage)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            channelName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: DpadOption(
            onSelect: onFavoriteSelect,
            onFocus: onFavoriteFocus,
            child: GestureDetector(
              onTap: onFavoriteSelect,
              child: Card(
                color: starColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                    child: favoriteIcon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
