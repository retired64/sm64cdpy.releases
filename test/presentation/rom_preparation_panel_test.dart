import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/rom_preparation.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/rom_preparation_provider.dart';
import 'package:sm64cdpy/presentation/widgets/rom_preparation_panel.dart';
import 'package:sm64cdpy/services/rom_preparation_service.dart';

class _PreparedService extends RomPreparationService {
  _PreparedService();
  final controller = StreamController<RomPreparationState>.broadcast();
  final prepared = const RomPreparationState(
    phase: RomPreparationPhase.prepared,
    operationId: 'fixture',
    revision: 3,
    inputName: 'My original cartridge dump with a long name.v64',
    sourceFormat: 'v64',
    processedBytes: 8388608,
    totalBytes: 8388608,
    canExport: true,
    initialized: true,
  );
  @override
  Stream<RomPreparationState> get events => controller.stream;
  @override
  Future<RomPreparationState> snapshot() async => prepared;
  @override
  Future<RomPreparationState> export() async => prepared;
  @override
  Future<RomPreparationState> discard() async => prepared;
  @override
  Future<RomPreparationState> pickAndPrepare() async => prepared;
  @override
  Future<RomPreparationState> cancel() async => prepared;
}

void main() {
  for (final design in AppThemeCatalog.designs) {
    testWidgets('prepared panel fits low-end layout in ${design.id}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = _PreparedService();
      addTearDown(service.controller.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [romPreparationServiceProvider.overrideWithValue(service)],
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: RetroTheme.materialTheme(false, design: design),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: RomPreparationPanel(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Guardar copia .z64'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('prepared panel fits 320 px with enlarged Spanish text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _PreparedService();
    addTearDown(service.controller.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [romPreparationServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(false),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: RomPreparationPanel(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Guardar copia .z64'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
