import 'package:flutter/material.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'package:deutschliveapp/services/routing.dart';
import 'package:deutschliveapp/widgets/channellistitem.dart';
import 'package:deutschliveapp/widgets/homepageswidgets/topnavbar.dart';
import 'package:deutschliveapp/models/channel.dart';
import 'package:hive_flutter/hive_flutter.dart'; // اطمینان از ایمپورت مدل کانال

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({super.key, required this.isTV});
  final bool isTV;

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  final StorageProvider storageProvider = StorageProvider();
  late bool isTV;
  int _focusedIndex = 1;

  void _updateFocus(int newIndex) {
    if (mounted) {
      setState(() {
        _focusedIndex = newIndex;
      });
    }
  }

  Icon _favoriteIcon(String channelName) {
    final List<String> favorites = storageProvider.storage
        .get('favoritedChannelList', defaultValue: <String>[]).cast<String>();

    final bool isFavorited = favorites.contains(channelName);
    return Icon(
      isFavorited ? Icons.star : Icons.star_border,
      color: isFavorited
          ? Colors.indigo[900]
          : const Color.fromARGB(212, 189, 194, 38),
    );
  }

  void _favoriteChange(int index) async {
    final List<Channel> channelList = storageProvider.storage
        .get('channelList', defaultValue: <Channel>[]).cast<Channel>();

    final String selectedChannel = channelList[index].channelName;

    final List<String> favorites = storageProvider.storage
        .get('favoritedChannelList', defaultValue: <String>[]).cast<String>();

    if (favorites.contains(selectedChannel)) {
      favorites.remove(selectedChannel);
    } else {
      favorites.add(selectedChannel);
      favorites.sort();
    }

    await storageProvider.storage.put('favoritedChannelList', favorites);
    setState(() {});
  }

  void _goToChannel(int index) {
    goToChannelPageIPTV(context: context, index: index, isTV: isTV);
  }

  Future<void> _refreshChannelList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    isTV = widget.isTV;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      storageProvider.storage.listenable().addListener(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Channel> channelList = storageProvider.storage
        .get('channelList', defaultValue: <Channel>[]).cast<Channel>();

    return Scaffold(
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text('Kanalliste')),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshChannelList,
        color: Colors.indigo,
        backgroundColor: Colors.white,
        displacement: 10,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: TopNavBar(
                focusedIndex: _focusedIndex,
                updateFocus: _updateFocus,
                isTV: isTV,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final Channel channel = channelList[index];
                  final bool isChannelFocused = _focusedIndex == index + 3;
                  final bool isStarFocused =
                      _focusedIndex == index + 3 + channelList.length;

                  return ChannelListItem(
                    channelName: channel.channelName,
                    source: channel.source,
                    contactpage: channel.contactpage,
                    isFocused: isChannelFocused,
                    isFavoriteFocused: isStarFocused,
                    onChannelSelect: () => _goToChannel(index),
                    onFavoriteSelect: () => _favoriteChange(index),
                    onChannelFocus: (isFocused) {
                      if (isFocused) _updateFocus(index + 3);
                    },
                    onFavoriteFocus: (isFocused) {
                      if (isFocused) {
                        _updateFocus(index + 3 + channelList.length);
                      }
                    },
                    favoriteIcon: _favoriteIcon(channel.channelName),
                  );
                },
                childCount: channelList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
