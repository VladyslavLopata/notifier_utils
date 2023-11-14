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
        'Logs state changes',
        (tester) async {
          final notifier = ValueNotifier(false);
          var didLog = false;
          void onLog(String _) => didLog = true;
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
