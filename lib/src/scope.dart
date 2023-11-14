import 'package:flutter/material.dart';

class Scope extends StatefulWidget {
  const Scope({
    super.key,
    required this.dispose,
    required this.child,
  });

  final VoidCallback dispose;
  final Widget child;

  @override
  State<Scope> createState() => _ScopeState();
}

class _ScopeState extends State<Scope> {
  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
