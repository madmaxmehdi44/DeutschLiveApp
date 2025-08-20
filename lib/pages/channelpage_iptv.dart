import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'dart:async';
import 'package:intl/intl.dart';

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
  bool _isLandscape = false;
  bool _showUI = true;
  Timer? _hideTimer;
  late Timer _clockTimer;
  String _clockText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    index = widget.index;
    isTV = widget.isTV;
    storageProvider = StorageProvider();
    WakelockPlus.enable();
    _initializeVideo();
    _startClock();
    _startHideTimer();
  }

  void _initializeVideo() {
    final channelList = storageProvider.storage.get('channelList');
    final channel = channelList[index];
    final String link = channel.link;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(link),
      formatHint: VideoFormat.hls,
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  void _startClock() {
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateClock();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final formatted = DateFormat('HH:mm:ss - yyyy/MM/dd').format(now);
    setState(() {
      _clockText = formatted;
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showUI = false;
      });
    });
  }

  void _handleTap() {
    if (!_showUI) {
      setState(() => _showUI = true);
      _startHideTimer();
    } else {
      _toggleOrientation();
    }
  }

  void _toggleOrientation() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
    setState(() {
      _isLandscape = !_isLandscape;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.pause();
    _controller.dispose();
    _clockTimer.cancel();
    _hideTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    final isReady = _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _handleTap,
          child: Stack(
            children: [
              Center(
                child: isReady
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),
              AnimatedOpacity(
                opacity: _showUI ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: [
                    Positioned(
                      top: _isLandscape ? 16 : 24,
                      left: _isLandscape ? 16 : 24,
                      child: _controlButton(Icons.arrow_back, () {
                        Navigator.of(context).pop();
                      }),
                    ),
                    Positioned(
                      bottom: _isLandscape ? 16 : 24,
                      left: _isLandscape ? 16 : 24,
                      right: _isLandscape ? 16 : 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _controlButton(
                              Icons.play_arrow, () => _controller.play()),
                          _controlButton(
                              Icons.pause, () => _controller.pause()),
                          _controlButton(
                              Icons.picture_in_picture, _enterPipMode),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: _isLandscape ? 60 : 80,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          _clockText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
