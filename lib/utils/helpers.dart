import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

Future<bool> tryGrantPermission() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return true;
  }

  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.manageExternalStorage.request();
  }
  return status.isGranted;
}
