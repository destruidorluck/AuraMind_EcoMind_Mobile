import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/core/constants/app_route.dart';
import 'package:flutter_app/core/network/api_client.dart';
import 'package:flutter_app/core/storage/local_storage.dart';
import 'package:flutter_app/core/theme/aura_theme.dart';
import 'package:flutter_app/features/app_data/app_data_repository.dart';
import 'package:flutter_app/features/music/music_repository.dart';
import 'package:flutter_app/features/shared/model_codecs.dart';
import 'package:flutter_app/models/aura_models.dart';
import 'package:flutter_app/screens/views/aura_views.dart';
import 'package:flutter_app/services/aura_ble_service.dart';
import 'package:flutter_app/services/aura_notification_service.dart';
import 'package:flutter_app/state/aura_controller.dart';
import 'package:flutter_app/state/aura_scope.dart';
import 'package:flutter_app/widgets/aura_persistent_media_player.dart';

void main() {
  test('music payload accepts audio_url aliases and control actions', () {
    final snakeCase = MusicPlaybackData.fromJson({
      'title': 'Jazz',
      'audio_url': 'https://example.test/audio',
    });
    final camelCase = MusicPlaybackData.fromJson({
      'title': 'MPB',
      'audioUrl': 'https://example.test/audio-2',
    });

    expect(snakeCase.audioUrl, 'https://example.test/audio');
    expect(camelCase.audioUrl, 'https://example.test/audio-2');
    expect(MusicRepository.actionFromPayload({'action': 'next'}), 'next');
    expect(
      MusicRepository.actionFromPayload({'action': 'previous'}),
      'previous',
    );
    expect(MusicRepository.actionFromPayload({'action': 'stop'}), 'stop');
  });

  test('Aura chat sends the current music context', () async {
    SharedPreferences.setMockInitialValues({});
    final api = ApiClient(
      baseUrl: 'https://example.ngrok-free.dev',
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final clientContext = body['client_context'] as Map<String, dynamic>;
        final music = clientContext['music'] as Map<String, dynamic>;
        expect(music['active'], isTrue);
        expect(music['is_playing'], isTrue);
        expect(music['video_id'], 'video-123');
        expect(music['audio_url'], 'https://example.test/audio');
        return http.Response(
          jsonEncode({'success': true, 'response': 'Certo.'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final controller = AuraController(apiClient: api)
      ..doNotDisturb = true
      ..currentMedia = AuraMedia(
        title: 'Jazz',
        artist: 'Aura',
        source: 'youtube',
        audioUrl: 'https://example.test/audio',
        imageUrl: '',
        videoId: 'video-123',
        isPlaying: true,
      );

    await controller.sendAuraMessage('qual musica esta tocando?');

    expect(controller.auraConversationMessages.last.body, 'Certo.');
    controller.dispose();
  });

  testWidgets('home renders clean empty state for a new account', (
    tester,
  ) async {
    final controller = AuraController()
      ..isLoggedIn = true
      ..route = AuraRoute.home;

    await tester.pumpWidget(
      AuraScope(
        controller: controller,
        child: MaterialApp(
          theme: auraDarkTheme,
          home: const Scaffold(body: AuraRouteView(route: AuraRoute.home)),
        ),
      ),
    );

    expect(find.text('Casa Inteligente'), findsOneWidget);
    expect(find.text('Adicionar dispositivo'), findsWidgets);
    expect(find.text('Leonardo'), findsNothing);
    controller.dispose();
  });

  testWidgets('timer counts down and stopwatch records a lap', (tester) async {
    final controller = AuraController()
      ..isLoggedIn = true
      ..alarmMode = 'timers';
    controller.addTimer('00:00:03', 'Teste');

    await tester.pumpWidget(
      AuraScope(
        controller: controller,
        child: MaterialApp(
          theme: auraDarkTheme,
          home: const Scaffold(body: AlarmsView()),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:00:02'), findsWidgets);

    controller.setAlarmMode('cronometro');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Volta'));
    await tester.pumpAndSettle();
    expect(controller.stopwatch.laps, isNotEmpty);
    expect(controller.stopwatch.laps.first, greaterThanOrEqualTo(1));
    controller.dispose();
  });

  test(
    'app data repository persists lists, notes, alarms and timers locally',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorage.create();
      final repository = AuraAppDataRepository(storage);
      const userId = '00000000-0000-0000-0000-000000000001';

      await repository.save(
        userId,
        lists: [
          AuraList(
            id: 'list-1',
            title: 'Compras',
            items: [AuraListItem(id: 'item-1', text: 'Cafe', checked: false)],
          ),
        ],
        notes: [AuraNote(id: 'note-1', title: 'Nota', preview: 'Texto')],
        alarms: [
          AuraAlarm(id: 'alarm-1', time: '08:00', label: 'Todos', active: true),
        ],
        timers: [
          AuraTimerItem(
            id: 'timer-1',
            duration: '00:05:00',
            label: 'Foco',
            active: false,
          ),
        ],
        reminders: {},
        accounts: [
          AuraAccount(
            id: userId,
            name: 'Lucas',
            role: 'Proprietário',
            email: 'lucas@auramind.app',
          ),
          AuraAccount(
            id: 'member-1',
            name: 'Leo',
            role: 'Administrador',
            email: 'leo@auramind.app',
          ),
        ],
        activities: [],
        notifications: [],
        networks: [],
        skills: [],
        selectedWorldClockId: 'br-sp',
      );

      final loaded = await repository.load(
        userId,
        ownerEmail: 'lucas@auramind.app',
      );
      expect(loaded.lists.single.title, 'Compras');
      expect(loaded.notes.single.preview, 'Texto');
      expect(loaded.alarms.single.time, '08:00');
      expect(loaded.timers.single.totalSeconds, 300);
      expect(loaded.accounts.single.id, 'member-1');
    },
  );

  test('Aura chat works without logged user and keeps backend reply', () async {
    SharedPreferences.setMockInitialValues({});
    final api = ApiClient(
      baseUrl: 'https://unlimited-sharpness-fondue.ngrok-free.dev',
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], isNull);
        expect(request.headers['ngrok-skip-browser-warning'], 'true');
        if (request.url.path == '/api/chat') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['message'], 'oi aura');
          return http.Response(
            jsonEncode({'success': true, 'response': 'Oi, Lucas.'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 404);
      }),
    );
    final controller = AuraController(apiClient: api)..doNotDisturb = true;

    await controller.sendAuraMessage('oi aura');

    expect(controller.auraConversationMessages, hasLength(2));
    expect(controller.auraConversationMessages.first.body, 'oi aura');
    expect(controller.auraConversationMessages.last.body, 'Oi, Lucas.');
    controller.dispose();
  });

  test('profile name and email stay on local account after editing', () {
    final controller = AuraController();
    controller.login(email: 'lucas@auramind.app', name: 'Lucas');

    final account = controller.currentAccount!;
    controller.updateAccount(
      account.id,
      name: 'Lucas Tome',
      email: 'lucas.tome@auramind.app',
    );

    expect(controller.currentAccount!.name, 'Lucas Tome');
    expect(controller.currentAccount!.email, 'lucas.tome@auramind.app');
    expect(controller.activeUserId, account.id);
    controller.dispose();
  });

  test('repeated local login keeps a single deterministic owner', () {
    final controller = AuraController();

    controller.login(email: 'lucas@auramind.app', name: 'Lucas');
    controller.login(email: 'lucas@auramind.app', name: 'Lucas Tome');

    expect(controller.accounts, hasLength(1));
    expect(controller.currentAccount!.id, 'local-aura-user');
    expect(controller.currentAccount!.name, 'Lucas Tome');
    controller.dispose();
  });

  test(
    'authenticated session migrates legacy data and removes duplicate owner',
    () async {
      final legacyOwner = AuraAccount(
        id: 'legacy-owner',
        name: 'Lucas antigo',
        role: 'Proprietário',
        email: 'lucas@auramind.app',
      );
      final member = AuraAccount(
        id: 'member-1',
        name: 'Leo',
        role: 'Administrador',
        email: 'leo@auramind.app',
      );
      final legacyList = AuraList(
        id: 'list-legacy',
        title: 'Dados preservados',
        items: [],
      );
      final canonicalOwner = AuraAccount(
        id: '00000000-0000-0000-0000-000000000001',
        name: 'Lucas',
        role: 'Proprietário',
        email: 'lucas@auramind.app',
      );
      SharedPreferences.setMockInitialValues({
        'user:legacy-owner:accounts': jsonEncode([
          ModelCodecs.accountToJson(legacyOwner),
          ModelCodecs.accountToJson(member),
        ]),
        'user:legacy-owner:lists': jsonEncode([
          ModelCodecs.listToJson(legacyList),
        ]),
        'user:00000000-0000-0000-0000-000000000001:accounts': jsonEncode([
          ModelCodecs.accountToJson(canonicalOwner),
        ]),
        'user:00000000-0000-0000-0000-000000000001:lists': '[]',
      });
      final api = ApiClient(
        baseUrl: 'https://example.test',
        httpClient: MockClient(
          (_) async => http.Response(
            jsonEncode({'ok': true}),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      final controller = AuraController(apiClient: api);

      await controller.onAuthenticatedSession(
        userId: '00000000-0000-0000-0000-000000000001',
        email: 'lucas@auramind.app',
        name: 'Lucas Tome',
      );
      await controller.onAuthenticatedSession(
        userId: '00000000-0000-0000-0000-000000000001',
        email: 'lucas@auramind.app',
        name: 'Lucas Tome',
      );

      expect(
        controller.accounts.where(
          (account) => account.role.toLowerCase().contains('propriet'),
        ),
        hasLength(1),
      );
      expect(
        controller.currentAccount!.id,
        '00000000-0000-0000-0000-000000000001',
      );
      expect(
        controller.accounts.any((account) => account.id == 'member-1'),
        isTrue,
      );
      expect(controller.lists.single.title, 'Dados preservados');
      controller.dispose();
    },
  );

  testWidgets('home jazz shortcut sends a real Aura chat message', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final requestedPaths = <String>[];
    final api = ApiClient(
      baseUrl: 'https://unlimited-sharpness-fondue.ngrok-free.dev',
      httpClient: MockClient((request) async {
        requestedPaths.add(request.url.path);
        if (request.url.path == '/api/chat') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['message'], 'Tocar jazz');
          return http.Response(
            jsonEncode({'success': true, 'response': 'Vou tocar jazz.'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 404);
      }),
    );
    final controller = AuraController(apiClient: api)..doNotDisturb = true;

    await tester.pumpWidget(
      AuraScope(
        controller: controller,
        child: MaterialApp(
          theme: auraDarkTheme,
          home: const Scaffold(body: AuraRouteView(route: AuraRoute.home)),
        ),
      ),
    );

    await tester.tap(find.text('Tocar jazz'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 250)),
    );
    await tester.pump();

    expect(controller.route, AuraRoute.auraAsk);
    expect(requestedPaths, contains('/api/chat'));
    expect(controller.auraConversationMessages.first.body, 'Tocar jazz');
    expect(controller.auraConversationMessages.last.body, 'Vou tocar jazz.');
    controller.dispose();
  });

  test('device routines block duplicate time and allow edit/delete', () {
    final controller = AuraController();
    controller.devices.add(
      AuraDevice(
        id: 'device-1',
        name: 'EcoMind',
        room: 'Quarto',
        status: 'Ligado',
        active: true,
        type: AuraDeviceType.plug,
      ),
    );

    expect(
      controller.upsertRoutine('device-1', 'Hora de acordar', '07:00'),
      isNull,
    );
    expect(
      controller.upsertRoutine('device-1', 'Outra rotina', '07:00'),
      'Ja existe uma rotina nesse horario.',
    );

    final routine = controller.devices.single.routines.single;
    expect(
      controller.upsertRoutine(
        'device-1',
        'Hora de dormir',
        '07:00',
        routineId: routine.id,
      ),
      isNull,
    );
    expect(controller.devices.single.routines.single.title, 'Hora de dormir');

    controller.deleteRoutine('device-1', routine.id);
    expect(controller.devices.single.routines, isEmpty);
    controller.dispose();
  });

  testWidgets('delete confirmation keeps list when canceled', (tester) async {
    final controller = AuraController()
      ..isLoggedIn = true
      ..route = AuraRoute.moreLists
      ..addList('Compras');

    await tester.pumpWidget(
      AuraScope(
        controller: controller,
        child: MaterialApp(
          theme: auraDarkTheme,
          home: const Scaffold(body: ListsAndNotesView()),
        ),
      ),
    );

    await tester.drag(find.text('Compras'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Excluir lista?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(controller.lists, hasLength(1));
    expect(find.text('Compras'), findsOneWidget);
    controller.dispose();
  });

  test('EcoMind BLE matcher accepts current MicroPython device name', () {
    expect(AuraBleService.matchesEcoMindName('ECO MIND'), isTrue);
    expect(AuraBleService.matchesEcoMindName('EcoMind'), isTrue);
    expect(AuraBleService.matchesEcoMindName('AuraMind-EcoMind'), isTrue);
    expect(
      AuraBleService.matchesEcoMindName('Random device', advertisesUart: true),
      isTrue,
    );
  });

  test('EcoMind BLE encoder uses short protocol for frequent commands', () {
    expect(
      AuraBleService.encodeCommandForEcoMind({
        'cmd': 'state',
        'state': 'processing',
      }),
      ['S:processing'],
    );
    expect(
      AuraBleService.encodeCommandForEcoMind({'cmd': 'led', 'color': 'blue'}),
      ['L:blue'],
    );
    expect(AuraBleService.encodeCommandForEcoMind({'cmd': 'backend_health'}), [
      'BH',
    ]);
    expect(
      AuraBleService.encodeCommandForEcoMind({
        'cmd': 'brightness',
        'value': 70,
      }),
      ['B:70'],
    );
    expect(AuraBleService.encodeCommandForEcoMind({'cmd': 'ping'}), [
      '{"cmd":"ping"}',
    ]);
  });

  test('group codec preserves Supabase image path and display URL', () {
    final group = ModelCodecs.groupFromJson({
      'id': 'group-1',
      'owner_id': 'user-1',
      'name': 'Familia',
      'invite_code': 'aura-123',
      'image_url': 'https://example.com/group.jpg',
      'image_path': 'user-1/groups/group-1/avatar.jpg',
      'member_ids': ['contact-1'],
    });

    expect(group.imageAsset, 'https://example.com/group.jpg');
    expect(group.imagePath, 'user-1/groups/group-1/avatar.jpg');

    final json = ModelCodecs.groupToJson(group);
    expect(json['image_asset'], 'https://example.com/group.jpg');
    expect(json['image_path'], 'user-1/groups/group-1/avatar.jpg');
  });

  test('EcoMind BLE encoder frames long JSON under 20 byte writes', () {
    final frames = AuraBleService.encodeCommandForEcoMind({
      'cmd': 'wifi_connect',
      'ssid': 'De_Lupaa2,4GHz',
      'password': 'senha-grande-para-testar-o-frame',
    });

    expect(frames.length, greaterThan(1));
    expect(
      frames.map((frame) => utf8.encode(frame).length),
      everyElement(lessThanOrEqualTo(AuraBleService.writePayloadLimit)),
    );
    expect(frames.first, startsWith('#1/'));

    final encoded = frames
        .map((frame) => frame.substring(frame.indexOf(':') + 1))
        .join();
    final decoded = jsonDecode(utf8.decode(base64Decode(encoded)));
    expect(decoded['cmd'], 'wifi_connect');
    expect(decoded['ssid'], 'De_Lupaa2,4GHz');
  });

  test('alarms and timers register native schedules', () async {
    AuraNotificationService.debugScheduledAlerts.clear();
    final controller = AuraController();

    controller.addAlarm('07:30', 'Todos', name: 'Hora de acordar');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(
      AuraNotificationService.debugScheduledAlerts.where(
        (item) => item['kind'] == 'alarm',
      ),
      isNotEmpty,
    );

    controller.addTimer('00:01:00', 'Cha');
    controller.toggleTimer(controller.timers.single.id);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(
      AuraNotificationService.debugScheduledAlerts.where(
        (item) => item['kind'] == 'timer',
      ),
      isNotEmpty,
    );

    controller.deleteAlarm(controller.alarms.single.id);
    controller.deleteTimer(controller.timers.single.id);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(AuraNotificationService.debugScheduledAlerts, isEmpty);
    controller.dispose();
  });

  test(
    'Aura chat tries to send EcoMind state and continues disconnected',
    () async {
      SharedPreferences.setMockInitialValues({});
      final api = ApiClient(
        baseUrl: 'https://unlimited-sharpness-fondue.ngrok-free.dev',
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/chat') {
            return http.Response(
              jsonEncode({'success': true, 'response': 'Tudo certo.'}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('{}', 404);
        }),
      );
      final controller = AuraController(apiClient: api)..doNotDisturb = true;

      await controller.sendAuraMessage('oi');

      expect(controller.auraConversationMessages, hasLength(2));
      expect(controller.esp32BleStatus, contains('LED fisico'));
      expect(
        controller.esp32BleLog.join('\n'),
        contains('estado "processing"'),
      );
      controller.dispose();
    },
  );

  test('music without logged user surfaces backend failure', () async {
    SharedPreferences.setMockInitialValues({});
    final requestedPaths = <String>[];
    final api = ApiClient(
      baseUrl: 'https://unlimited-sharpness-fondue.ngrok-free.dev',
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], isNull);
        requestedPaths.add(request.url.path);
        return http.Response(
          jsonEncode({
            'success': true,
            'response': 'Nao encontrei uma musica tocavel.',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final controller = AuraController(apiClient: api)..doNotDisturb = true;

    await controller.playMusicFromPrompt('Tocar jazz relaxante');

    expect(requestedPaths, contains('/api/chat'));
    expect(requestedPaths, contains('/api/music/next'));
    expect(controller.musicErrorMessage, isNotEmpty);
    expect(controller.currentMedia.isPlaying, isFalse);
    controller.dispose();
  });

  testWidgets('settings screens render with active mini player', (
    tester,
  ) async {
    final routes = [
      AuraRoute.moreConfigDeviceSettings,
      AuraRoute.moreConfigDisplay,
      AuraRoute.profilePrivacy,
    ];

    for (final route in routes) {
      final controller = AuraController()
        ..isLoggedIn = true
        ..route = route
        ..currentMedia = AuraMedia(
          title: 'Best Relaxing Jazz Classics',
          artist: 'Jazz Compilation 2025',
          imageUrl: '',
          isPlaying: true,
          videoId: 'dQw4w9WgXcQ',
          youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        );
      controller.devices.add(
        AuraDevice(
          id: 'device-1',
          name: 'Lampada da sala',
          room: 'Sala',
          status: 'Ligado',
          active: true,
          type: AuraDeviceType.light,
          supportsColor: true,
          supportsDimming: true,
          value: 70,
        ),
      );
      controller.selectedDeviceId = 'device-1';

      await tester.pumpWidget(
        AuraScope(
          controller: controller,
          child: MaterialApp(
            theme: auraDarkTheme,
            home: AuraPersistentMediaPlayer(
              controller: controller,
              enableYoutubePlayer: false,
              child: Scaffold(body: AuraRouteView(route: route)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Best Relaxing Jazz Classics'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });

  testWidgets('support feedback legal and permissions routes render', (
    tester,
  ) async {
    final routes = [
      AuraRoute.moreSupport,
      AuraRoute.moreFeedback,
      AuraRoute.moreConfigPermissions,
      AuraRoute.legalTerms,
      AuraRoute.legalPrivacy,
    ];

    for (final route in routes) {
      final controller = AuraController()
        ..isLoggedIn = true
        ..route = route;

      await tester.pumpWidget(
        AuraScope(
          controller: controller,
          child: MaterialApp(
            theme: auraDarkTheme,
            home: Scaffold(body: AuraRouteView(route: route)),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });
}
