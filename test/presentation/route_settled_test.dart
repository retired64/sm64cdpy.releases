import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/presentation/widgets/route_settled.dart';

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    return RouteSettledBuilder(
      builder: (context, settled) => Text(settled ? 'settled' : 'animating'),
    );
  }
}

void main() {
  testWidgets('reports the route as unsettled until its push completes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                PageRouteBuilder<void>(
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (_, _, _) => const _Probe(),
                  transitionsBuilder: (_, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('animating'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('settled'), findsOneWidget);
  });
}
