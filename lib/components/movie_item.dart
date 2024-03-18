import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:notebash_app/models/movie.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieItem extends StatelessWidget {
  final void Function() onTap;
  final Movie movie;

  const MovieItem({super.key, required this.onTap, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).hoverColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(movie.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text(movie.year.toString(),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              Text(movie.genre, style: Theme.of(context).textTheme.bodyMedium!),
              const SizedBox(height: 10),
              Linkify(
                onOpen: (link) async {
                  if (!await launchUrl(Uri.parse(link.url))) {
                    throw Exception('Could not launch ${link.url}');
                  }
                },
                text: movie.link,
                options: const LinkifyOptions(humanize: false),
              )
            ],
          ),
        ),
      ),
    );
  }
}
