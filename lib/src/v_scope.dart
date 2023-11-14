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
  }) : builder = ((context, value, child) => builder(value));

  const VScope.child({
    super.key,
    required this.notifier,
    required this.builder,
  });

  final ValueNotifier<T> notifier;
  final WidgetBuilderFunction<T> builder;

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
      child: VBuilder(
        builder: builder,
        valueListenable: notifier,
      ),
    );
  }
}
