import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> showCustomDialog(
  BuildContext context,
  String theTitle,
  String theDiscreption,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          title: Text(theTitle),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  SelectableText(theDiscreption),
                ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('common.close')),
            )
          ],
        );
      });
}
