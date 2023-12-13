import 'package:flutter/material.dart';

import 'scope.dart';
import 'v_builder.dart';

typedef WidgetBuilderFunction<T> = Widget Function(
  BuildContext context,
  T value,
  Widget? child,
);

class VScope<T> extends StatelessWidget {
  VScope({
    super.key,
    required this.notifier,
    required Widget Function(T value) builder,
    this.sharedResource = false,
    this.resourceTag = '',
  }) : builder = ((context, value, child) => builder(value));

  const VScope.child({
    super.key,
    required this.notifier,
    required this.builder,
    this.sharedResource = false,
    this.resourceTag = '',
  });

  final ValueNotifier<T> notifier;
  final WidgetBuilderFunction<T> builder;
  final bool sharedResource;
  final String resourceTag;

  static void Function(String notifier, String state)? logStateChange;

  @override
  Widget build(BuildContext context) {
    notifier.addListener(
      () => logStateChange?.call(
        notifier.runtimeType.toString(),
        notifier.value.toString(),
      ),
    );
    return Scope(
      dispose: notifier.dispose,
      resourceTag: resourceTag,
      sharedResource: sharedResource,
      child: VBuilder(
        builder: builder,
        valueListenable: notifier,
      ),
    );
  }
}
