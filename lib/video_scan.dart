import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VideoItem {
  final String path;
  final String name;
  final int size;
  VideoItem({required this.path, required this.name, required this.size});
}

final List<String> _videoExts = [
  '.mp4', '.mkv', '.avi', '.mov', '.webm', '.3gp', '.flv', '.wmv', '.m4v', '.ts'
];

bool isVideoFile(String path) {
  final ext = p.extension(path).toLowerCase();
  return _videoExts.contains(ext);
}

/// 遍历标准媒体目录，收集本地视频文件。
/// 在 Android 11+ 的 scoped storage 下，对某些目录无权限会抛异常，已忽略。
Future<List<VideoItem>> scanVideos() async {
  final List<VideoItem> out = [];
  final Set<String> seen = {};

  final List<Directory> roots = [];

  // 通过应用私有外部目录反推内置存储根 /storage/emulated/0
  try {
    final ext = await getExternalStorageDirectory();
    if (ext != null) {
      final idx = ext.path.indexOf('Android');
      if (idx > 0) {
        roots.add(Directory(ext.path.substring(0, idx)));
      }
    }
  } catch (_) {
    // ignore
  }

  // 直接尝试常见顶层媒体目录（即便上面的推断失败也能兜底）
  const extra = ['Movies', 'DCIM', 'Download', 'Pictures', 'Video'];
  for (final e in extra) {
    final d = Directory('/storage/emulated/0/$e');
    if (d.existsSync()) roots.add(d);
  }

  final uniqueRoots = <Directory>[];
  final rootSeen = <String>{};
  for (final d in roots) {
    if (rootSeen.add(d.path)) uniqueRoots.add(d);
  }

  for (final dir in uniqueRoots) {
    _scanDir(dir, 0, 4, seen, out);
  }

  out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return out;
}

void _scanDir(Directory dir, int depth, int maxDepth, Set<String> seen,
    List<VideoItem> out) {
  if (depth > maxDepth) return;
  List<FileSystemEntity> ents;
  try {
    ents = dir.listSync(followLinks: false);
  } on FileSystemException {
    return; // 无权限或不可访问，跳过
  }
  for (final ent in ents) {
    if (ent is Directory) {
      _scanDir(ent, depth + 1, maxDepth, seen, out);
    } else if (ent is File && isVideoFile(ent.path)) {
      if (seen.add(ent.path)) {
        int size = 0;
        try {
          size = ent.lengthSync();
        } catch (_) {}
        out.add(VideoItem(
          path: ent.path,
          name: p.basename(ent.path),
          size: size,
        ));
      }
    }
  }
}
