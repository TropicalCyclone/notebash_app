import 'package:flutter/material.dart';
import 'package:notebash_app/models/book.dart';

class BookItem extends StatelessWidget {
  final void Function() onTap;
  final Book book;

  const BookItem({super.key, required this.onTap, required this.book});

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
                    child: Text(book.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text(book.yearPublished.toString(),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              Text(book.authors,
                  style: Theme.of(context).textTheme.bodyMedium!),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
