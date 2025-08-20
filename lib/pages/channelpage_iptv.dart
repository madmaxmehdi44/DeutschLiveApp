import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:deutschliveapp/services/storage.dart';

class ChannelPageIPTV extends StatefulWidget {
  const ChannelPageIPTV({super.key, required this.index, required this.isTV});
  final int index;
  final bool isTV;

  @override
  State<ChannelPageIPTV> createState() => _ChannelPageIPTVState();
}

class _ChannelPageIPTVState extends State<ChannelPageIPTV>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  final _pip = SimplePip();
  late StorageProvider storageProvider;
  late int index;
  late bool isTV;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    index = widget.index;
    isTV = widget.isTV;
    storageProvider = StorageProvider();
    WakelockPlus.enable();
    _initializeVideo();
  }

  void _initializeVideo() {
    final channelList = storageProvider.storage.get('channelList');
    final channel = channelList[index];
    final String link = channel.link;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(link),
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
        _controller.play();
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.pause();
    _controller.dispose();
    WakelockPlus.disable();
    if (!isTV) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _enterPipMode();
    }
  }

  Future<void> _enterPipMode() async {
    final isAvailable = await SimplePip.isPipAvailable;
    if (isAvailable) {
      await _pip.enterPipMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _controlButton(Icons.play_arrow, () => _controller.play()),
                  _controlButton(Icons.pause, () => _controller.pause()),
                  _controlButton(Icons.picture_in_picture, _enterPipMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.white.withOpacity(0.1),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
