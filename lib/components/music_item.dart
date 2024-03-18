import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:notebash_app/models/music.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicItem extends StatelessWidget {
  final void Function() onTap;
  final Music music;

  const MusicItem({super.key, required this.onTap, required this.music});

  @override
  Widget build(BuildContext context) {
    final fallBackImage = Image.asset(
      'assets/images/music.png',
      width: 80,
      height: 80,
    );

    return Material(
      color: Theme.of(context).hoverColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage.assetNetwork(
                  imageErrorBuilder: (context, error, stackTrace) =>
                      fallBackImage,
                  placeholderErrorBuilder: (context, error, stackTrace) =>
                      fallBackImage,
                  placeholder: 'assets/images/music.png',
                  image: music.albumArt,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(music.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(music.artist,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Linkify(
                      onOpen: (link) async {
                        if (!await launchUrl(Uri.parse(link.url))) {
                          throw Exception('Could not launch ${link.url}');
                        }
                      },
                      text: music.url,
                      options: const LinkifyOptions(humanize: false),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
