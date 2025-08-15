import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ChannelPageIPTV extends StatefulWidget {
  const ChannelPageIPTV({super.key, required this.index, required this.isTV});

  final int index;
  final bool isTV;

  @override
  State<ChannelPageIPTV> createState() => _ChannelPageIPTVState();
}

class _ChannelPageIPTVState extends State<ChannelPageIPTV> {
  late StorageProvider storageProvider;
  late int index;
  late bool isTV;
  late VideoPlayerController _videoPlayerController;
  bool _appBarVisibility = true;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    isTV = widget.isTV;
    storageProvider = StorageProvider();
    WakelockPlus.enable();
    _setupVideoPlayerController();
  }

  void _setupVideoPlayerController() {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(storageProvider.storage.get('channelList')[index].link),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: true,
        webOptions: VideoPlayerWebOptions(
          allowContextMenu: true,
          allowRemotePlayback: true,
          controls: VideoPlayerWebOptionsControls.enabled(
            allowFullscreen: true,
            allowPictureInPicture: true,
            allowPlaybackRate: true,
            allowDownload: false,
          ),
        ),
      ),
      formatHint: VideoFormat.hls,
    )..initialize().then((_) {
        setState(() {});
        // _videoPlayerController.value = VideoPlayerValue(duration: Duration());
        _videoPlayerController.play();
      });
  }

  void _hideUnhideAppBar() {
    if (!isTV) {
      setState(() {
        _appBarVisibility = !_appBarVisibility;
        if (!_appBarVisibility) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
            SystemUiOverlay.top,
          ]);
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        }
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _videoPlayerController.pause();
    _videoPlayerController.dispose();
    // WakelockPlus.enable();
    if (!isTV) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (isTV)
          ? null
          : _appBarVisibility
              ? AppBar(
                  title: Text(storageProvider.storage
                      .get('channelList')[index]
                      .channelName),
                  titleTextStyle: const TextStyle(
                      color: Colors.black26, fontWeight: FontWeight.bold),
                  centerTitle: true,
                  backgroundColor: Colors.redAccent[900],
                  foregroundColor: Colors.black26,
                )
              : null,
      backgroundColor: Colors.black45,
      body: GestureDetector(
        onTap: _hideUnhideAppBar,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      // aspectRatio: _videoPlayerController.value.aspectRatio,
                      aspectRatio: 16.0 / 9.0,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : const CircularProgressIndicator.adaptive(),
          // VideoProgressIndicator(
          //   _videoPlayerController,
          //   allowScrubbing: true,
          //   colors: VideoProgressColors(
          //     backgroundColor: Colors.indigo,
          //     playedColor: Colors.pink,
          //   ),
          // ),
          // ],
          // ),
        ),
      ),
      bottomNavigationBar: (isTV)
          ? (MediaQuery.of(context).orientation == Orientation.landscape)
              ? null
              : null
          : (MediaQuery.of(context).orientation == Orientation.portrait)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    " ${storageProvider.storage.get('channelList')[index].channelName} پخش زنده ی شبکه ی",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : null,
    );
  }
}
