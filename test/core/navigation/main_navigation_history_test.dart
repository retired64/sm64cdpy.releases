import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/navigation/main_navigation_history.dart';

void main() {
  group('MainNavigationHistory', () {
    test('does not duplicate consecutive main destinations', () {
      final history = MainNavigationHistory();
      history.record('/library');
      history.record('/library?view=recent');

      expect(history.entries, ['/library?view=recent']);
    });

    test('returns to the previous main destination', () {
      final history = MainNavigationHistory();
      history.record('/');
      history.record('/library');
      history.record('/player');

      final target = history.resolveBack('/player', secondary: false);

      expect(target?.location, '/library');
      expect(target?.pop, isTrue);
      history.commit(target!);
      expect(history.entries, ['/', '/library']);
    });

    test('a single non-home destination returns home before exiting', () {
      final history = MainNavigationHistory();
      history.record('/library');

      final target = history.resolveBack('/library', secondary: false);

      expect(target?.location, '/');
      expect(target?.pop, isFalse);
      history.commit(target!);
      expect(history.entries, ['/']);
    });

    test('home without history allows the app to exit', () {
      final history = MainNavigationHistory();

      expect(history.resolveBack('/', secondary: false), isNull);
    });

    test('a deep-linked main runs back through home', () {
      final history = MainNavigationHistory();

      final target = history.resolveBack('/library', secondary: false);

      expect(target?.location, '/');
      history.commit(target!);
      expect(history.resolveBack('/', secondary: false), isNull);
    });

    test('query parameters are preserved when going back', () {
      final history = MainNavigationHistory();
      history.record('/');
      history.record('/library?view=recent');
      history.record('/player');

      final target = history.resolveBack('/player', secondary: false);

      expect(target?.location, '/library?view=recent');
      history.commit(target!);
      expect(history.current, '/library?view=recent');
    });

    test(
      'secondary destinations resolve to their parent before main history',
      () {
        final history = MainNavigationHistory();
        history.record('/');
        history.record('/settings');

        final target = history.resolveBack(
          '/settings/permissions',
          secondary: true,
          fallbackParent: '/settings',
        );

        expect(target?.location, '/settings');
        expect(target?.pop, isFalse);
        history.commit(target!);
        expect(history.entries, ['/', '/settings']);
      },
    );

    test('history is bounded and drops the oldest destination', () {
      final history = MainNavigationHistory(maxEntries: 3);
      for (final location in ['/a', '/b', '/c', '/d', '/e']) {
        history.record(location);
      }

      expect(history.entries, ['/c', '/d', '/e']);
    });
  });
}
