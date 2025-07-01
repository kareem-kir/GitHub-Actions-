import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../bloc/music/music_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../widgets/track_tile.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/track_model.dart';
import '../../../shared/models/user_model.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  CategoryModel? category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (category == null) {
      category = ModalRoute.of(context)?.settings.arguments as CategoryModel?;
      if (category != null) {
        context.read<MusicBloc>().add(LoadTracks(category!.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(
          child: Text('لم يتم العثور على القسم'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Category Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category!.nameAr.isNotEmpty ? category!.nameAr : category!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  category!.imageUrl.isNotEmpty
                    ? Image.network(
                        category!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
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
                      ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Category Description
          if (category!.descriptionAr.isNotEmpty || category!.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category!.descriptionAr.isNotEmpty 
                    ? category!.descriptionAr 
                    : category!.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          // Tracks List
          BlocBuilder<MusicBloc, MusicState>(
            builder: (context, musicState) {
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  if (musicState is MusicLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (musicState is TracksLoaded) {
                    if (musicState.tracks.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off,
                                size: 64,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد مقاطع صوتية في هذا القسم',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    UserModel? user;
                    if (userState is UserLoaded) {
                      user = userState.user;
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = musicState.tracks[index];
                          final canAccess = user?.canAccessContent(
                            SubscriptionStatus.values.firstWhere(
                              (e) => e.name == track.requiredSubscription,
                              orElse: () => SubscriptionStatus.free,
                            ),
                          ) ?? false;

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: TrackTile(
                                  track: track,
                                  canAccess: canAccess,
                                  onTap: () => _handleTrackTap(context, track, canAccess),
                                  onDownload: () => _handleTrackDownload(context, track, canAccess),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: musicState.tracks.length,
                      ),
                    );
                  } else if (musicState is MusicError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              musicState.message,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<MusicBloc>().add(LoadTracks(category!.id));
                              },
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTrackTap(BuildContext context, TrackModel track, bool canAccess) {
    if (!canAccess) {
      _showSubscriptionDialog(context);
      return;
    }

    context.read<MusicBloc>().add(PlayTrack(track));
    Navigator.of(context).pushNamed('/player');
  }

  void _handleTrackDownload(BuildContext context, TrackModel track, bool canAccess) {
    if (!canAccess) {
      _showSubscriptionDialog(context);
      return;
    }

    context.read<MusicBloc>().add(DownloadTrack(track));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بدء تحميل: ${track.titleAr.isNotEmpty ? track.titleAr : track.title}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اشتراك مطلوب'),
          content: const Text(
            'هذا المحتوى متاح للمشتركين فقط. يرجى ترقية اشتراكك للوصول إلى جميع المقاطع الصوتية.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/subscription');
              },
              child: const Text('ترقية الاشتراك'),
            ),
          ],
        );
      },
    );
  }
}
