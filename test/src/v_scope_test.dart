import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifier_utils/notifier_utils.dart';

class MockNotifier<T> extends ValueNotifier<T> {
  MockNotifier(super.value);
  var isDisposed = false;
  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

void main() {
  tearDown(() {
    VScope.logStateChange = null;
  });
  group(
    'VScope tests',
    () {
      testWidgets(
        'Notifier changes state',
        (tester) async {
          final notifier = ValueNotifier(false);
          const falseKey = Key('false');
          const trueKey = Key('true');
          await tester.pumpWidget(
            VScope(
              notifier: notifier,
              builder: (state) => state
                  ? const SizedBox(
                      key: trueKey,
                    )
                  : const SizedBox(
                      key: falseKey,
                    ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(falseKey), findsOneWidget);
          expect(find.byKey(trueKey), findsNothing);
          notifier.value = true;
          await tester.pumpAndSettle();
          expect(find.byKey(falseKey), findsNothing);
          expect(find.byKey(trueKey), findsOneWidget);
        },
      );
      testWidgets(
        'Scope calls dispose',
        (tester) async {
          final notifier = MockNotifier(false);

          await tester.pumpWidget(
            VScope(notifier: notifier, builder: (_) => const SizedBox()),
          );
          await tester.pumpAndSettle();
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          expect(notifier.isDisposed, true);
        },
      );

      testWidgets(
        'Shared scope does not call dispose when one notifier still alive',
        (tester) async {
          final notifier = MockNotifier(false);

          await tester.pumpWidget(
            VScope(
              sharedResource: true,
              notifier: notifier,
              builder: (_) => const SizedBox(),
            ),
          );
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            VScope(
              sharedResource: true,
              notifier: notifier,
              builder: (_) => const SizedBox(),
            ),
          );
          await tester.pumpAndSettle();
          expect(notifier.isDisposed, false);
        },
      );

      testWidgets(
        'Shared scope calls dispose when last notifier is out of scope',
        (tester) async {
          final notifier = MockNotifier(false);

          await tester.pumpWidget(
            VScope(
              sharedResource: true,
              notifier: notifier,
              builder: (_) => const SizedBox(),
            ),
          );
          await tester.pumpAndSettle();
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          expect(notifier.isDisposed, true);
        },
      );

      testWidgets(
        'Maintains two scopes properly',
        (tester) async {
          final notifier1 = MockNotifier(false);
          final notifier2 = MockNotifier(false);

          const tag1 = 'n1';
          const tag2 = 'n2';

          await tester.pumpWidget(
            Column(
              children: [
                VScope(
                  sharedResource: true,
                  notifier: notifier1,
                  resourceTag: tag1,
                  builder: (_) => const SizedBox(),
                ),
                VScope(
                  sharedResource: true,
                  notifier: notifier2,
                  resourceTag: tag2,
                  builder: (_) => const SizedBox(),
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          await tester.pumpWidget(
            VScope(
              sharedResource: true,
              notifier: notifier1,
              resourceTag: tag1,
              builder: (_) => const SizedBox(),
            ),
          );
          await tester.pumpAndSettle();
          expect(notifier1.isDisposed, false);
          expect(notifier2.isDisposed, true);
        },
      );

      testWidgets(
        'Logs state changes',
        (tester) async {
          final notifier = ValueNotifier(false);
          var didLog = false;
          void onLog(String _, String __) => didLog = true;
          VScope.logStateChange = onLog;

          await tester.pumpWidget(
            VScope(notifier: notifier, builder: (_) => const SizedBox()),
          );
          expect(didLog, false);
          await tester.pumpAndSettle();
          notifier.value = true;
          await tester.pumpAndSettle();
          expect(didLog, true);
        },
      );
    },
  );
}
