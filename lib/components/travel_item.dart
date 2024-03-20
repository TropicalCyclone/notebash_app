import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notebash_app/models/travel.dart';

class TravelItem extends StatelessWidget {
  final void Function() onTap;
  final Travel travel;

  const TravelItem({super.key, required this.onTap, required this.travel});

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
              Text(travel.destination,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(_formatDay(travel.travelDate),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDay(DateTime date) {
  return DateFormat('EE MMM dd, yyyy').format(date);
}
