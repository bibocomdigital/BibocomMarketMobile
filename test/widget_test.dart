import 'package:bibomarketmobile/app.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('l’app démarre', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const BiboMarketApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Bibo'), findsWidgets);
  });
}
