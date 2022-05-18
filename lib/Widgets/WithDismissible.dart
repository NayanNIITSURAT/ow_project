import 'package:flutter/material.dart';

class WithDismissible extends StatelessWidget {
  const WithDismissible({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.down,
      key: const Key('key'),
      onDismissed: (_) => Navigator.pop(context),
      child: child,
    );
  }
}
