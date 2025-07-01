import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/music/music_bloc.dart';
import '../../../shared/models/track_model.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsBottomSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<MusicBloc, MusicState>(
        builder: (context, state) {
          if (state is TrackPlaying) {
            // Control rotation animation based on playing state
            if (state.isPlaying) {
              _rotationController.repeat();
            } else {
              _rotationController.stop();
            }
            
            return _buildPlayerContent(context, state.track, state.isPlaying, state.position, state.duration);
          }
          
          return const Center(
            child: Text('لا يوجد مقطع صوتي قيد التشغيل'),
          );
        },
      ),
    );
  }

  Widget _buildPlayerContent(
    BuildContext context,
    TrackModel track,
    bool isPlaying,
    Duration position,
    Duration duration,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          
          // Album Art
          GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: track.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: track.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Track Info
          Text(
            track.titleAr.isNotEmpty ? track.titleAr : track.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            track.artistAr.isNotEmpty ? track.artistAr : track.artist,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Progress Bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: duration.inMilliseconds > 0 
                    ? position.inMilliseconds.toDouble() 
                    : 0.0,
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    context.read<MusicBloc>().add(
                      SeekTrack(Duration(milliseconds: value.toInt())),
                    );
                  },
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDuration(duration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous Button
              IconButton(
                onPressed: () {
                  // TODO: Implement previous track
                },
                icon: const Icon(Icons.skip_previous),
                iconSize: 36,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              
              // Rewind Button
              IconButton(
                onPressed: () {
                  final newPosition = position - const Duration(seconds: 10);
                  context.read<MusicBloc>().add(
                    SeekTrack(newPosition < Duration.zero ? Duration.zero : newPosition),
                  );
                },
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              
              // Play/Pause Button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      context.read<MusicBloc>().add(PauseTrack());
                    } else {
                      context.read<MusicBloc>().add(ResumeTrack());
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Forward Button
              IconButton(
                onPressed: () {
                  final newPosition = position + const Duration(seconds: 10);
                  context.read<MusicBloc>().add(
                    SeekTrack(newPosition > duration ? duration : newPosition),
                  );
                },
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              
              // Next Button
              IconButton(
                onPressed: () {
                  // TODO: Implement next track
                },
                icon: const Icon(Icons.skip_next),
                iconSize: 36,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Additional Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement shuffle
                },
                icon: const Icon(Icons.shuffle),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement favorite
                },
                icon: const Icon(Icons.favorite_border),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement repeat
                },
                icon: const Icon(Icons.repeat),
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('تحميل'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement download
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('مشاركة'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement share
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('معلومات المقطع'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Show track info
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
