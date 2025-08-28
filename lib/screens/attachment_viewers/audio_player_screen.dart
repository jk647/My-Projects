import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../../constants/theme_color.dart';
import '../../constants/tap_feedback_helpers.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;
  final String fileName;

  const AudioPlayerScreen({
    super.key,
    required this.audioPath,
    required this.fileName,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  // Audio player controller
  AudioPlayer? _audioPlayer;
  
  // Player state
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  // Initialize audio player with event listeners
  Future<void> _initializeAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      
      // Listen to duration changes
      _audioPlayer!.onDurationChanged.listen((Duration duration) {
        setState(() {
          _duration = duration;
        });
      });

      // Listen to position changes
      _audioPlayer!.onPositionChanged.listen((Duration position) {
        setState(() {
          _position = position;
        });
      });

      // Listen to player state changes
       _audioPlayer!.onPlayerStateChanged.listen((PlayerState state) {
         setState(() {
           _isPlaying = state == PlayerState.playing;
         });
       });

      // Listen to playback completion
      _audioPlayer!.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });

      // Check if file exists
      final file = File(widget.audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: ${widget.audioPath}');
      }
      
      // Set audio source
      await _audioPlayer!.setSource(DeviceFileSource(widget.audioPath));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Play/pause audio
  Future<void> _playPause() async {
    if (_audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        // If position is at the end, restart from beginning
        if (_position >= _duration && _duration > Duration.zero) {
          await _audioPlayer!.seek(Duration.zero);
        }
        
        // Always use play() with the source for better compatibility
        await _audioPlayer!.play(DeviceFileSource(widget.audioPath));
      }
    } catch (e) {
      _showSnack("Error playing audio: $e", isError: true);
    }
  }

  // Stop audio playback
  Future<void> _stop() async {
    if (_audioPlayer == null) return;
    await _audioPlayer!.stop();
  }

  // Seek to specific position
  Future<void> _seekTo(Duration position) async {
    if (_audioPlayer == null) return;
    await _audioPlayer!.seek(position);
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  // Custom snackbar for user feedback
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: TapFeedbackHelpers.feedbackIconButton(
          context: context,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryYellow),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryYellow.withOpacity(0.3),
        ),
        title: Text(
          widget.fileName,
          style: GoogleFonts.poppins(
            color: AppColors.primaryYellow,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryYellow,
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white70,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load audio',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The audio file may be corrupted or in an unsupported format.',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Audio visualizer/icon
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryYellow,
                            width: 3,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              _isPlaying ? Icons.music_note : Icons.music_note_outlined,
                              color: AppColors.primaryYellow,
                              size: 64,
                            ),
                            if (_isPlaying)
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryYellow.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const CircularProgressIndicator(
                                  color: AppColors.primaryYellow,
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Progress slider
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryYellow,
                              inactiveTrackColor: Colors.grey[600],
                              thumbColor: AppColors.primaryYellow,
                              overlayColor: AppColors.primaryYellow.withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                            ),
                            child: Slider(
                              value: _duration.inMilliseconds > 0
                                  ? _position.inMilliseconds / _duration.inMilliseconds
                                  : 0.0,
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds: (value * _duration.inMilliseconds).round(),
                                );
                                _seekTo(newPosition);
                              },
                            ),
                          ),
                          
                          // Time display
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_position),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_duration),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stop button
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 2,
                              ),
                            ),
                            child: TapFeedbackHelpers.feedbackIconButton(
                              context: context,
                              onPressed: _stop,
                              icon: const Icon(Icons.stop, color: Colors.white70, size: 24),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white70.withValues(alpha: 0.3),
                            ),
                          ),
                          
                          const SizedBox(width: 40),
                          
                          // Play/Pause button
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryYellow.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: TapFeedbackHelpers.feedbackIconButton(
                              context: context,
                              onPressed: _playPause,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 40,
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

