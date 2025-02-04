import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoTrimmerScreen extends StatefulWidget {
  final String videoPath;
  final Duration maxDuration;

  const VideoTrimmerScreen({
    super.key,
    required this.videoPath,
    this.maxDuration = const Duration(minutes: 3),
  });

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  Duration _startPosition = Duration.zero;
  Duration _endPosition = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    
    await _controller.initialize();
    _endPosition = _controller.value.duration;
    
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _controller.value.position;
          if (_currentPosition >= _endPosition) {
            _controller.pause();
            _controller.seekTo(_startPosition);
            _isPlaying = false;
          }
        });
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _controller.pause();
    } else {
      await _controller.seekTo(_startPosition);
      await _controller.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  Future<String?> _saveVideo() async {
    if (_isSaving) return null;
    
    setState(() => _isSaving = true);
    
    try {
      final Duration selectedDuration = _endPosition - _startPosition;
      if (selectedDuration > widget.maxDuration) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a shorter interval (max ${widget.maxDuration.inMinutes} minutes)'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // For now, we'll return the original path since we're not actually trimming
      // In a real implementation, you'd want to use FFmpeg or similar to trim the video
      return widget.videoPath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Trim Video'),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () async {
                    final path = await _saveVideo();
                    if (path != null && mounted) {
                      Navigator.of(context).pop(path);
                    }
                  },
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_startPosition),
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    _formatDuration(_endPosition),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Slider(
              value: _currentPosition.inMilliseconds.toDouble(),
              min: 0,
              max: _controller.value.duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.toInt());
                setState(() {
                  _currentPosition = newPosition;
                });
                _controller.seekTo(newPosition);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _startPosition = _currentPosition;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.flag),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _endPosition = _currentPosition;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
} 