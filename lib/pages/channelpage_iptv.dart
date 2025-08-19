import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_widget_recorder/flutter_widget_recorder.dart';
// import 'package:flutter_widget_recorder_example/camera_screen.dart';
// import 'package:share_plus/share_plus.dart';

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
  final WidgetRecorderController _controllerScreenRecorder =
      WidgetRecorderController(targetFps: 30, isWithTicker: true);

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
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
              overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
    _controllerScreenRecorder.dispose();
    // WakelockPlus.enable();
    if (!isTV) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
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
                  foregroundColor: Colors.amberAccent,
                )
              : null,
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onTap: _hideUnhideAppBar,
          child: Center(
            child: SizedBox(height: 300,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: _videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        // aspectRatio: _videoPlayerController.value.aspectRatio,
                        aspectRatio:
                            (_appBarVisibility ? 11.6 / 11.5 : 16.2 / 7.475),
                        child: Stack(
                          fit: StackFit.passthrough,
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            VideoPlayer(_videoPlayerController)
                              ..controller.setVolume(0.7),
                          ],
                        ),
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
          ),
        ),
      ),
      floatingActionButton: (isTV)
          ? (MediaQuery.of(context).orientation == Orientation.landscape)
              ? null
              : null
          : (MediaQuery.of(context).orientation == Orientation.portrait)
              ? Text(
                  " ${storageProvider.storage.get('channelList')[index].channelName} پخش زنده ی شبکه ی",
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.redAccent),
                )
              : null,
    );
  }
}
