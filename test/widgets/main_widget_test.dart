import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namer_app/favorites_page.dart';
import 'package:namer_app/generator_page.dart';
import 'package:namer_app/main.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders MyApp', (WidgetTester tester) async {
      setupApp();
      await tester.pumpAndSettle();
      expect(find.byType(MyApp), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('can navigate between pages', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial page
      expect(find.byType(GeneratorPage), findsOneWidget);
      expect(find.byType(FavoritesPage), findsNothing);

      // Tap on the favorites tab
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Verify favorites page is shown
      expect(find.byType(GeneratorPage), findsNothing);
      expect(find.byType(FavoritesPage), findsOneWidget);

      // Tap on the home tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify generator page is shown again
      expect(find.byType(GeneratorPage), findsOneWidget);
      expect(find.byType(FavoritesPage), findsNothing);
    });
  });
}
