import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  final String title;
  final String placeholder;

  InputDialog({this.title, this.placeholder = ''});

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
      ),
      actions: [
        FlatButton(
          child: const Text('Debug'),
          onPressed: () {
            Navigator.pop(context, 'Foram consumidos 844MB do pacote de internet de 6,50GB. Valido ate 24/11/2019.');
          },
        ),
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.pop<String>(
              context,
              controller.text,
            );
          },
        ),
      ],
    );
  }
}
