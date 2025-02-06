// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';

// class VideoTrimmerScreen extends StatefulWidget {
//   final String videoPath;
//   final Duration maxDuration;

//   const VideoTrimmerScreen({
//     super.key,
//     required this.videoPath,
//     required this.maxDuration,
//   });

//   @override
//   State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
// }

// class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;
//   bool _isSaving = false;
//   Duration _startPosition = Duration.zero;
//   Duration _endPosition = Duration.zero;
//   Duration _currentPosition = Duration.zero;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.file(File(widget.videoPath));
      
//       await _controller.initialize();
//       if (!mounted) {
//         await _controller.dispose();
//         return;
//       }
      
//       setState(() {
//         _endPosition = _controller.value.duration;
//         _isInitialized = true;
//       });

//       _controller.addListener(() {
//         if (!mounted) return;
        
//         final position = _controller.value.position;
//         setState(() {
//           _currentPosition = position;
//           if (position >= _endPosition) {
//             _controller.pause();
//             _controller.seekTo(_startPosition);
//             _isPlaying = false;
//           }
//         });
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error initializing video: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       rethrow;
//     }
//   }

//   Future<void> _saveVideo() async {
//     if (!mounted) return;
    
//     try {
//       setState(() {
//         _isSaving = true;
//       });

//       // Validate selection
//       final selectedDuration = _endPosition - _startPosition;
//       if (selectedDuration > widget.maxDuration) {
//         if (!mounted) return;
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Please select a duration under ${widget.maxDuration.inMinutes} minutes'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // For now, we'll return the original path since we're not actually trimming
//       // In a real implementation, you'd want to use FFmpeg or similar to trim the video
//       if (!mounted) return;
//       Navigator.of(context).pop(widget.videoPath);
//     } catch (e) {
//       if (!mounted) return;
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error saving video: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   Future<void> _togglePlayPause() async {
//     if (!mounted) return;
    
//     setState(() {
//       if (_isPlaying) {
//         _controller.pause();
//       } else {
//         _controller.seekTo(_startPosition);
//         _controller.play();
//       }
//       _isPlaying = !_isPlaying;
//     });
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return "$minutes:$seconds";
//   }

//   @override
//   void dispose() {
//     _controller.pause();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Trim Video'),
//         actions: [
//           TextButton(
//             onPressed: _isSaving ? null : _saveVideo,
//             child: _isSaving
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : const Text(
//                   'Save',
//                   style: TextStyle(color: Colors.white),
//                 ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _formatDuration(_startPosition),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   Text(
//                     _formatDuration(_endPosition),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             Slider(
//               value: _currentPosition.inMilliseconds.toDouble(),
//               min: 0,
//               max: _controller.value.duration.inMilliseconds.toDouble(),
//               onChanged: (value) {
//                 if (!mounted) return;
//                 final newPosition = Duration(milliseconds: value.toInt());
//                 setState(() {
//                   _currentPosition = newPosition;
//                 });
//                 _controller.seekTo(newPosition);
//               },
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.flag_outlined),
//                   color: Colors.white,
//                   onPressed: () {
//                     if (!mounted) return;
//                     setState(() {
//                       _startPosition = _currentPosition;
//                     });
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                   iconSize: 40,
//                   color: Colors.white,
//                   onPressed: _togglePlayPause,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.flag),
//                   color: Colors.white,
//                   onPressed: () {
//                     if (!mounted) return;
//                     setState(() {
//                       _endPosition = _currentPosition;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// } 