import 'package:flutter_test/flutter_test.dart';
import 'package:racepace/presentation/features/notes/notes_screen.dart';
import 'package:racepace/presentation/l10n/app_localizations.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('Notes screen shows placeholder', (tester) async {
    await tester.pumpWidget(
      buildTestApp(child: NotesScreen(onOpenSettings: () {})),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NotesScreen));
    final l10n = AppLocalizations.of(context);

    expect(find.text(l10n.notesPlaceholder), findsOneWidget);
  });
}
