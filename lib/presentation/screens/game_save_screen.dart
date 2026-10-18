import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/game_save_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/settings_expansion_group.dart';

const _courses = [
  'BOB',
  'WF',
  'JRB',
  'CCM',
  'BBH',
  'HMC',
  'LLL',
  'SSL',
  'DDD',
  'SL',
  'WDW',
  'TTM',
  'THI',
  'TTC',
  'RR',
  'BitDW',
  'BitFS',
  'BitS',
  'PSS',
  'CotMC',
  'TotWC',
  'VCutM',
  'WMotR',
  'SA',
  'Cake',
];
const _maxStars = [
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  1,
  1,
  1,
  2,
  1,
  1,
  1,
  1,
  1,
  0,
];

class GameSaveScreen extends ConsumerStatefulWidget {
  const GameSaveScreen({super.key});
  @override
  ConsumerState<GameSaveScreen> createState() => _GameSaveScreenState();
}

class _GameSaveScreenState extends ConsumerState<GameSaveScreen>
    with WidgetsBindingObserver {
  int _bank = 0;
  bool _loadScheduled = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed)
      unawaited(ref.read(gameSaveProvider.notifier).run());
  }

  Future<bool> _confirm(String action) async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(action),
            content: Text(l.saveFileConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.playerCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.playerApply),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _change(Map<String, dynamic> action) async {
    final snapshot = ref.read(gameSaveProvider).data;
    action = {
      'revision': snapshot?['revision'],
      'identity': snapshot?['identity'],
      ...action,
    };
    final l = AppLocalizations.of(context);
    final title = switch (action['action']) {
      'erase' => '${l.playerDelete} · ${'ABCD'[action['slot'] as int]}',
      'copy' => '${l.saveFileCopy} · ${'ABCD'[action['slot'] as int]} → ${'ABCD'[action['destination'] as int]}',
      'restore' => l.playerRestore,
      _ => l.playerApply,
    };
    if (!await _confirm(title) || !mounted) return;
    final ok = await ref.read(gameSaveProvider.notifier).run(action);
    if (mounted) _feedback(ok);
  }

  void _feedback(bool ok) {
    final l = AppLocalizations.of(context);
    if (ok) {
      AppSnackbar.success(context, message: l.saveFileDone);
    } else {
      final error = ref.read(gameSaveProvider).error;
      AppSnackbar.error(context, message: switch (error) {
        'conflict' => l.playerConflict,
        'installing' => l.gameModsInstalling,
        _ => l.saveFileError,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameSaveProvider);
    if (state.data == null && !state.busy && state.error == null && !_loadScheduled) {
      _loadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadScheduled = false;
        if (!mounted) return;
        final current = ref.read(gameSaveProvider);
        if (current.data == null && !current.busy && current.error == null) {
          unawaited(ref.read(gameSaveProvider.notifier).run());
        }
      });
    }
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    final slots = (state.data?['slots'] as List? ?? []).cast<Map>();
    final backups = (state.data?['backups'] as List? ?? []).cast<Map>();
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(gameSaveProvider.notifier).run();
      },
      child: CustomScrollView(
        slivers: [
          RetroPinnedAppBar(
            title: Text(l.saveFileTitle, style: retro.heading(size: 18)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Text(
                  l.saveFileHint,
                  style: retro.body(size: 13, color: retro.inkDim),
                ),
                const SizedBox(height: 12),
                if (state.busy) const LinearProgressIndicator(),
                if (state.error != null) ...[
                  Text(
                    state.error == 'missing'
                        ? l.saveFileMissing
                        : state.error == 'conflict'
                        ? l.playerConflict
                        : l.saveFileError,
                    style: retro.body(size: 14, color: retro.red),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: state.busy
                            ? null
                            : () => ref.read(gameSaveProvider.notifier).run(),
                        child: Text(l.playerRetry),
                      ),
                      TextButton(
                        onPressed: () => context.go('/settings'),
                        child: Text(l.settingsTitle),
                      ),
                    ],
                  ),
                ],
                if (state.data?['damaged'] == true)
                  Text(
                    l.saveFileError,
                    style: retro.body(color: retro.red, size: 14),
                  ),
                if (state.data != null) ...[
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text(l.saveFilePrimary)),
                      ButtonSegment(value: 1, label: Text(l.saveFileAlternate)),
                    ],
                    selected: {_bank},
                    onSelectionChanged: state.busy
                        ? null
                        : (v) => setState(() => _bank = v.first),
                  ),
                  const SizedBox(height: 16),
                  for (final slot in slots.where(
                    (s) => s['bank'] == _bank,
                  )) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: retro.settingsPanel(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ABCD'[slot['slot'] as int],
                                style: retro.heading(
                                  size: 28,
                                  color: retro.accentText,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  slot['empty'] == true
                                      ? l.saveFileEmpty
                                      : '${slot['total']} ★',
                                  style: retro.heading(size: 20),
                                ),
                              ),
                              if (slot['valid'] != true)
                                Tooltip(
                                  message: l.saveFileUnsigned,
                                  child: const Icon(Icons.info_outline),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: ((slot['total'] as num).toDouble() / 120)
                                .clamp(0, 1),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.tune),
                                label: Text(l.saveFileProgress),
                                onPressed: state.busy
                                    ? null
                                    : () async {
                                        final change =
                                            await showModalBottomSheet<
                                              Map<String, dynamic>
                                            >(
                                              context: context,
                                              isScrollControlled: true,
                                              useSafeArea: true,
                                              builder: (_) =>
                                                  _SaveEditor(slot: slot),
                                            );
                                        if (change != null && mounted)
                                          await _change({
                                            'revision': state.data?['revision'],
                                            'identity': state.data?['identity'],
                                            ...change,
                                          });
                                      },
                              ),
                              PopupMenuButton<int>(
                                enabled: !state.busy,
                                icon: const Icon(Icons.copy_outlined),
                                tooltip: l.saveFileCopy,
                                itemBuilder: (_) => [
                                  for (var i = 0; i < 4; i++)
                                    if (i != slot['slot'])
                                      PopupMenuItem(
                                        value: i,
                                        child: Text(
                                          '${l.saveFileCopy} → ${'ABCD'[i]}',
                                        ),
                                      ),
                                ],
                                onSelected: (destination) => _change({
                                  'revision': state.data?['revision'],
                                  'identity': state.data?['identity'],
                                  'action': 'copy',
                                  'slot': slot['slot'],
                                  'destination': destination,
                                }),
                              ),
                              IconButton(
                                tooltip: l.playerDelete,
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: retro.red,
                                ),
                                onPressed: state.busy
                                    ? null
                                    : () => _change({
                                        'revision': state.data?['revision'],
                                        'identity': state.data?['identity'],
                                        'action': 'erase',
                                        'slot': slot['slot'],
                                      }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l.saveFileBackup),
                    onPressed: state.busy
                        ? null
                        : () async {
                            final ok = await ref
                                .read(gameSaveProvider.notifier)
                                .run({'action': 'backup'});
                            if (mounted) _feedback(ok);
                          },
                  ),
                  const SizedBox(height: 14),
                ],
                if (backups.isNotEmpty)
                  ExpansionTile(
                    title: Text(l.saveFileBackups),
                    children: [
                      for (final backup in backups)
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(
                            MaterialLocalizations.of(context).formatMediumDate(
                              DateTime.fromMillisecondsSinceEpoch(
                                backup['time'] as int,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            TimeOfDay.fromDateTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                backup['time'] as int,
                              ),
                            ).format(context),
                          ),
                          trailing: IconButton(
                            tooltip: l.playerRestore,
                            icon: const Icon(Icons.restore),
                            onPressed: state.busy
                                ? null
                                : () => _change({
                                    'revision': state.data?['revision'],
                                    'identity': state.data?['identity'],
                                    'action': 'restore',
                                    'backup': backup['id'],
                                  }),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveEditor extends StatefulWidget {
  const _SaveEditor({required this.slot});
  final Map slot;
  @override
  State<_SaveEditor> createState() => _SaveEditorState();
}

class _SaveEditorState extends State<_SaveEditor> {
  late final List<int> stars = List<int>.from(widget.slot['stars'] as List);
  late final List<int> coins = List<int>.from(widget.slot['coins'] as List);
  late final List<bool> cannons = List<bool>.from(
    widget.slot['cannons'] as List,
  );
  late int castle = (widget.slot['flags'] as int) >> 24 & 31;
  late int unlocks = (widget.slot['flags'] as int) & 0x10ffff;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    return FractionallySizedBox(
      heightFactor: .92,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${l.saveFileProgress} · ${'ABCD'[widget.slot['slot'] as int]}',
                    style: retro.heading(size: 18),
                  ),
                ),
                IconButton(
                  tooltip: l.playerCancel,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.star),
                    label: Text(l.saveFileComplete),
                    onPressed: () => setState(() {
                      for (var i = 0; i < 25; i++)
                        stars[i] = (1 << _maxStars[i]) - 1;
                      for (var i = 0; i < 15; i++) cannons[i] = true;
                      castle = 31;
                      unlocks = 0x10ffff;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: l.saveFileClearStars,
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => setState(() {
                    for (var i = 0; i < 25; i++) stars[i] = 0;
                    castle = 0;
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (var i = 0; i < 24; i++)
                  ExpansionTile(
                    title: Text(
                      l.saveFileCourseNames.split('|')[i],
                      style: retro.heading(size: 16),
                    ),
                    subtitle: Text(_courses[i]),
                    trailing: Text(
                      '${stars[i].toRadixString(2).replaceAll('0', '').length}/${_maxStars[i]} ★',
                    ),
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          for (var n = 0; n < _maxStars[i]; n++)
                            FilterChip(
                              label: Text('${n + 1} ★'),
                              selected: stars[i] & (1 << n) != 0,
                              onSelected: (_) =>
                                  setState(() => stars[i] ^= 1 << n),
                            ),
                        ],
                      ),
                      if (i < 15) ...[
                        SwitchListTile(
                          title: Text(l.saveFileCannon),
                          value: cannons[i],
                          onChanged: (v) => setState(() => cannons[i] = v),
                        ),
                        Row(
                          children: [
                            Text('${l.saveFileCoins} ${coins[i]}'),
                            Expanded(
                              child: Slider(
                                value: coins[i].toDouble(),
                                min: 0,
                                max: 255,
                                divisions: 255,
                                onChanged: (v) =>
                                    setState(() => coins[i] = v.round()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ExpansionTile(
                  title: Text(l.saveFileCastle),
                  children: [
                    Wrap(
                      spacing: 6,
                      children: [
                        for (var i = 0; i < 5; i++)
                          FilterChip(
                            label: Text(
                              i < 3 ? 'Toad ${i + 1}' : 'MIPS ${i - 2}',
                            ),
                            selected: castle & (1 << i) != 0,
                            onSelected: (_) => setState(() => castle ^= 1 << i),
                          ),
                      ],
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(l.saveFileUnlocks),
                  children: [
                    for (final item in [
                      (1, l.saveFileWing),
                      (2, l.saveFileMetal),
                      (3, l.saveFileVanish),
                      (4, l.saveFileKey1),
                      (5, l.saveFileKey2),
                      (6, l.saveFileBasement),
                      (7, l.saveFileUpstairs),
                      (9, l.saveFileMoat),
                    ])
                      SwitchListTile(
                        title: Text(item.$2),
                        value: unlocks & (1 << item.$1) != 0,
                        onChanged: (_) =>
                            setState(() => unlocks ^= 1 << item.$1),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l.playerApply),
                  onPressed: () => Navigator.pop(context, {
                    'action': 'edit',
                    'slot': widget.slot['slot'],
                    'bank': widget.slot['bank'],
                    'stars': stars,
                    'coins': coins,
                    'cannons': cannons,
                    'castle': castle,
                    'unlocks': unlocks,
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
