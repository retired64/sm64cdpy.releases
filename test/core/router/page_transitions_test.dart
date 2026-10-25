import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sm64cdpy/core/router/page_transitions.dart';

void main() {
  test('app page uses short asymmetric durations', () {
    final page = buildAppTransitionPage(
      key: const ValueKey('page'),
      child: const SizedBox(),
    );

    expect(page, isA<CustomTransitionPage<void>>());
    expect(page.transitionDuration, appPageTransitionDuration);
    expect(page.reverseTransitionDuration, appPageReverseTransitionDuration);
    expect(
      page.transitionDuration,
      lessThan(const Duration(milliseconds: 250)),
    );
  });

  testWidgets('transition uses only lightweight fade and slide primitives', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => buildLightweightPageTransition(
            context,
            const AlwaysStoppedAnimation(0.5),
            const AlwaysStoppedAnimation(0),
            const Text('destination'),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-page-fade')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-page-slide')), findsOneWidget);
    expect(find.byType(RepaintBoundary), findsWidgets);
    expect(find.text('destination'), findsOneWidget);
  });

  testWidgets('system reduce-motion setting bypasses the transition', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) => buildLightweightPageTransition(
              context,
              const AlwaysStoppedAnimation(0.5),
              const AlwaysStoppedAnimation(0),
              const Text('destination'),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-page-fade')), findsNothing);
    expect(find.byKey(const ValueKey('app-page-slide')), findsNothing);
    expect(find.text('destination'), findsOneWidget);
  });
}
