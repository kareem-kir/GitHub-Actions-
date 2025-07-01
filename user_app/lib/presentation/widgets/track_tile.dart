import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/models/track_model.dart';

class TrackTile extends StatelessWidget {
  final TrackModel track;
  final bool canAccess;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const TrackTile({
    Key? key,
    required this.track,
    required this.canAccess,
    required this.onTap,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Track Image
                track.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: track.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.music_note,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.music_note,
                          color: Theme.of(context).primaryColor,
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
                        color: Colors.white,
                      ),
                    ),
                
                // Lock Overlay for Premium Content
                if (!canAccess)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        title: Text(
          track.titleAr.isNotEmpty ? track.titleAr : track.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: canAccess 
              ? Theme.of(context).textTheme.titleMedium?.color
              : Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              track.artistAr.isNotEmpty ? track.artistAr : track.artist,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: canAccess 
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  track.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                if (!canAccess) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSubscriptionText(track.requiredSubscription),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Download Button
            IconButton(
              onPressed: onDownload,
              icon: Icon(
                Icons.download,
                color: canAccess 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              ),
              tooltip: 'تحميل',
            ),
            
            // Play Button
            IconButton(
              onPressed: onTap,
              icon: Icon(
                Icons.play_arrow,
                color: canAccess 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              ),
              tooltip: 'تشغيل',
            ),
          ],
        ),
        
        onTap: onTap,
      ),
    );
  }

  String _getSubscriptionText(String subscription) {
    switch (subscription) {
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      default:
        return 'مجاني';
    }
  }
}
