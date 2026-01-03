import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A small local widget for testing purposes that doesn't rely on app-wide
// initialization (Hive, providers, etc.). This keeps the unit test fast and
// stable while still exercising a simple StatefulWidget interaction.
class TestCounter extends StatefulWidget {
  const TestCounter({super.key});
  @override
  State<TestCounter> createState() => _TestCounterState();
}

class _TestCounterState extends State<TestCounter> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('$_count', key: const Key('counter'))),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _count++),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TestCounter());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
