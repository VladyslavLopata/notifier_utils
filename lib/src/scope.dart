import 'package:flutter/material.dart';

class Scope extends StatefulWidget {
  const Scope({
    super.key,
    required this.dispose,
    required this.child,
    this.sharedResource = false,
    this.resourceTag = '',
  });

  final VoidCallback dispose;
  final Widget child;
  final bool sharedResource;
  final String resourceTag;

  @override
  State<Scope> createState() => _ScopeState();
}

class _ScopeState extends State<Scope> {
  static final Map<String, int> _resourceCounter = {};

  @override
  void initState() {
    super.initState();
    if (widget.sharedResource) {
      final resourceCount = _resourceCounter[widget.resourceTag] ??= 0;
      _resourceCounter[widget.resourceTag] = resourceCount + 1;
    }
  }

  void _disposeNonShared() {
    widget.dispose();
  }

  void _disposeShared() {
    assert(
      _resourceCounter[widget.resourceTag] != null,
      'Resource counter for ${widget.resourceTag} cannot be null.',
    );

    var count = _resourceCounter[widget.resourceTag]!;
    count -= 1;
    _resourceCounter[widget.resourceTag] = count;

    if (count == 0) {
      widget.dispose();
      _resourceCounter.remove(widget.resourceTag);
    }
  }

  @override
  void dispose() {
    if (widget.sharedResource) {
      _disposeShared();
    } else {
      _disposeNonShared();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
