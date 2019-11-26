import 'package:flutter/material.dart';

class BoxedText extends StatelessWidget {
  final Widget child;
  final double height;

  BoxedText({@required this.child, @required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: this.height,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: this.child,
      ),
    );
  }
}
