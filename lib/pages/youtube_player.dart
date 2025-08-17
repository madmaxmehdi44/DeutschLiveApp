import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class YoutubePlayer extends StatefulWidget {
  final String videoUrl;

  const YoutubePlayer({
    super.key,
    required this.videoUrl,
  });

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isFullscreen = false;
  // ignore: prefer_typing_uninitialized_variables
  // late final _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(widget.videoUrl as Uri)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        // _startHideTimer();
      });
    _controller.addListener(() {
      setState(() {});
    });
  }

  // void _startHideTimer() {
  //   _hideControlsTimer?.cancel();
  //   _hideControlsTimer = Future.delayed(Duration(seconds: 4), () {
  //     if (mounted) setState(() => _showControls = false);
  //   });
  // }

  void toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }
    });
  }

  String formatDuration(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _showControls = !_showControls);
        // if (_showControls) _startHideTimer();
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _controller
              .seekTo(_controller.value.position - Duration(seconds: 10));
        } else {
          _controller
              .seekTo(_controller.value.position + Duration(seconds: 10));
        }
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (_controller.value.isBuffering)
            const Center(child: CircularProgressIndicator(color: Colors.red)),
          if (_showControls) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black38,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.redAccent,
              bufferedColor: Colors.white54,
              backgroundColor: Colors.black26,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                    // _startHideTimer();
                  });
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Lottie.asset(
                    _controller.value.isPlaying
                        ? 'assets/lottie/pause.json'
                        : 'assets/lottie/play.json',
                    repeat: false,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Ionicons.play_back, color: Colors.white),
                onPressed: () {
                  _controller.seekTo(
                      _controller.value.position - Duration(seconds: 10));
                  // _startHideTimer();
                },
              ),
              IconButton(
                icon: Icon(Ionicons.play_forward, color: Colors.white),
                onPressed: () {
                  _controller.seekTo(
                      _controller.value.position + Duration(seconds: 10));
                  // _startHideTimer();
                },
              ),
              Text(
                "${formatDuration(_controller.value.position)} / ${formatDuration(_controller.value.duration)}",
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: toggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
