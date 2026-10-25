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
      lessThanOrEqualTo(const Duration(milliseconds: 250)),
    );
  });

  test('important destinations use distinct but bounded profiles', () {
    final details = buildAppTransitionPage(
      key: const ValueKey('details'),
      child: const SizedBox(),
      style: AppPageTransitionStyle.modDetail,
    );
    final play = buildAppTransitionPage(
      key: const ValueKey('play'),
      child: const SizedBox(),
      style: AppPageTransitionStyle.play,
    );

    expect(details.transitionDuration, modDetailTransitionDuration);
    expect(play.transitionDuration, playTransitionDuration);
    expect(
      play.transitionDuration,
      lessThan(const Duration(milliseconds: 350)),
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
    expect(find.byKey(const ValueKey('app-page-scale')), findsOneWidget);
    final slide = tester.widget<SlideTransition>(
      find.byKey(const ValueKey('app-page-slide')),
    );
    expect(slide.position.value.dx, 0);
    expect(slide.position.value.dy, greaterThan(0));
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
