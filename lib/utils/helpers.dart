import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: error ? Colors.red : null,
      content: Text(
        message,
        style: error
            ? Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Colors.white)
            : null,
      ),
    ),
  );
}
