import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class VideoStorageError implements Exception {
  final String message;
  VideoStorageError(this.message);
  
  @override
  String toString() => 'VideoStorageError: $message';
}

class VideoStorageService {
  Future<String> _getVideoSavePath() async {
    try {
      if (Platform.isAndroid) {
        // Get the external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw VideoStorageError('Could not access storage');
        }

        // Create path to Movies/ReelAI
        final String moviesPath = directory.path.replaceAll(RegExp(r'/Android/.*$'), '/Movies');
        final String appFolder = '$moviesPath/ReelAI';
        
        // Create directory if it doesn't exist
        final dir = Directory(appFolder);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        return appFolder;
      } else {
        // For other platforms, use app documents directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String videoDirectory = path.join(appDir.path, 'Videos');
        await Directory(videoDirectory).create(recursive: true);
        return videoDirectory;
      }
    } catch (e) {
      throw VideoStorageError('Error getting save path: $e');
    }
  }

  Future<String> saveVideo(String sourcePath) async {
    try {
      final String saveDir = await _getVideoSavePath();
      final String fileName = 'ReelAI_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String savePath = path.join(saveDir, fileName);
      
      // Copy video to final location
      await File(sourcePath).copy(savePath);
      
      return savePath;
    } catch (e) {
      throw VideoStorageError('Failed to save video: $e');
    }
  }

  Future<void> deleteVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Warning: Could not delete video: $e');
    }
  }

  Future<void> cleanupTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = await tempDir.list().where((entity) => 
        entity is File && path.extension(entity.path) == '.mp4'
      ).toList();
      
      for (final file in tempFiles) {
        try {
          await file.delete();
        } catch (e) {
          debugPrint('Warning: Could not delete temporary file: $e');
        }
      }
    } catch (e) {
      debugPrint('Warning: Could not cleanup temporary files: $e');
    }
  }
} 