import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifier_utils/notifier_utils.dart';

void main() {
  group('Scope tests', () {
    testWidgets(
      'Disposes non-tagged Scope properly',
      (tester) async {
        var disposeCalled = false;
        await tester.pumpWidget(
          Scope(
            dispose: () => disposeCalled = true,
            child: const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        expect(disposeCalled, true);
      },
    );

    testWidgets(
      'Does not dispose when two widgets reference same value',
      (tester) async {
        var disposeCalled = false;
        await tester.pumpWidget(
          Scope(
            dispose: () => disposeCalled = true,
            sharedResource: true,
            child: const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          Scope(
            dispose: () => disposeCalled = true,
            sharedResource: true,
            child: const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();

        expect(disposeCalled, false);
      },
    );
    testWidgets(
      'Disposes when both values are out of scope',
      (tester) async {
        var disposeCalled = false;
        await tester.pumpWidget(
          Scope(
            dispose: () => disposeCalled = true,
            sharedResource: true,
            child: const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(
          Scope(
            dispose: () => disposeCalled = true,
            sharedResource: true,
            child: const SizedBox(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        expect(disposeCalled, true);
      },
    );
  });
}
