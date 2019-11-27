import 'package:flutter/material.dart';

class LoadingSheet extends StatelessWidget {
  final Widget title;
  final VoidCallback onHide;

  const LoadingSheet({this.title, this.onHide});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 16,
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.75),
          ),
        ),
        title: this.title ?? const Text('Loading'),
        trailing: SizedBox(
          width: 64,
          child: FlatButton(
            padding: EdgeInsets.zero,
            child: const Text('Hide'),
            onPressed: this.onHide,
          ),
        ),
      ),
    );
  }
}
