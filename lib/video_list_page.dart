import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'video_scan.dart';
import 'player_page.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<VideoItem> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _requestPermission();
    await _scan();
  }

  Future<void> _requestPermission() async {
    // Android 13+ 用 READ_MEDIA_VIDEO；旧版本用 READ_EXTERNAL_STORAGE
    if (!await Permission.videos.isGranted) {
      await Permission.videos.request();
    }
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
    });
    final list = await scanVideos();
    if (mounted) {
      setState(() {
        _videos = list;
        _loading = false;
      });
    }
  }

  Future<void> _pick() async {
    // file_picker 12.x: pickFiles is a static method and returns List<PlatformFile>?
    // (no longer wrapped in FilePickerResult, and the .platform accessor is gone).
    final files = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (files.isNotEmpty) {
      final picked = files.map((f) {
        final path = f.path ?? '';
        final name = f.name;
        return VideoItem(path: path, name: name, size: 0);
      }).where((v) => v.path.isNotEmpty).toList();
      if (mounted) {
        setState(() {
          final existing = <String>{for (final v in _videos) v.path};
          for (final v in picked) {
            if (existing.add(v.path)) _videos.add(v);
          }
          _videos.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        });
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
    return '${(mb / 1024).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本地视频'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新扫描',
            onPressed: _scan,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('没有自动找到视频文件',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pick,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('选择视频文件'),
                      ),
                      const SizedBox(height: 8),
                      const Text('提示：Android 11+ 可能限制自动扫描，',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Text('用上方按钮从系统文件管理器选取即可',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _videos.length,
                  itemBuilder: (ctx, i) {
                    final v = _videos[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerPage(video: v)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Icon(Icons.movie,
                                      size: 56, color: Colors.white70),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                  if (v.size > 0)
                                    Text(_formatSize(v.size),
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pick,
        icon: const Icon(Icons.folder_open),
        label: const Text('选择视频'),
      ),
    );
  }
}
