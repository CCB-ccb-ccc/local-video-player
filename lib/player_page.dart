import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'video_scan.dart';

class PlayerPage extends StatefulWidget {
  final VideoItem video;
  const PlayerPage({super.key, required this.video});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _showControls = true;
  bool _fullscreen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.path));
    _controller.addListener(_onUpdate);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _ready = true);
        _controller.play();
        WakelockPlus.enable();
      }
    }).catchError((e) {
      if (mounted) setState(() => _error = e.toString());
    });
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() => _fullscreen = !_fullscreen);
    if (_fullscreen) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _controlsOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        color: Colors.black38,
        child: Center(
          child: IconButton(
            iconSize: 64,
            color: Colors.white,
            icon: Icon(_controller.value.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _videoArea() {
    final video = VideoPlayer(_controller);
    if (_fullscreen) {
      return Expanded(
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(child: video),
              if (_showControls) _controlsOverlay(),
            ],
          ),
        ),
      );
    }
    final ratio = _controller.value.aspectRatio;
    return AspectRatio(
      aspectRatio: ratio > 0 ? ratio : 16 / 9,
      child: Stack(
        children: [
          video,
          if (_showControls) _controlsOverlay(),
        ],
      ),
    );
  }

  Widget _progressBar() {
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    final maxSec = dur.inSeconds > 0 ? dur.inSeconds.toDouble() : 1.0;
    final posSec = pos.inSeconds.toDouble().clamp(0.0, maxSec);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Text(_fmt(pos)),
          Expanded(
            child: Slider(
              value: posSec,
              max: maxSec,
              onChanged: (v) =>
                  _controller.seekTo(Duration(seconds: v.toInt())),
            ),
          ),
          Text(_fmt(dur)),
          IconButton(
            icon: Icon(_fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _fullscreen ? null : AppBar(title: Text(widget.video.name)),
      body: !_ready
          ? Center(
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          const Text('无法播放该视频',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            )
          : Column(
              children: [
                _videoArea(),
                if (!_fullscreen) _progressBar(),
              ],
            ),
    );
  }
}
