import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_route.dart';
import '../core/config/app_config.dart';
import '../core/errors/app_error.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../features/app_data/app_data_repository.dart';
import '../features/audio/audio_repository.dart';
import '../features/communication/communication_repository.dart';
import '../features/auth/auth_repository.dart';
import '../features/contacts/contacts_repository.dart';
import '../features/devices/devices_repository.dart';
import '../features/groups/groups_repository.dart';
import '../features/music/music_repository.dart';
import '../features/settings/settings_repository.dart';
import '../features/user/user_repository.dart';
import '../models/aura_models.dart';
import '../services/aura_ble_service.dart';
import '../services/aura_music_player_service.dart';
import '../services/aura_notification_service.dart';
import '../services/aura_platform_service.dart';
import '../services/aura_storage_service.dart';

enum AppInitStage {
  checkingSession,
  checkingBackend,
  loadingProfile,
  loadingSettings,
  loadingDevices,
  loadingContacts,
  ready,
  error,
}

enum AuraLightState { idle, listening, processing, responding, success, error }

class AuraController extends ChangeNotifier {
  static const String _localAuraUserId = 'local-aura-user';

  AuraController({String? initialLanguage, ApiClient? apiClient})
    : lang = initialLanguage ?? 'pt' {
    _apiClient = apiClient;
    _updateGreeting();
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateGreeting();
      notifyListeners();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickClock();
    });
    _bleLogSubscription = _bleService.messages.listen((message) {
      _appendEsp32Log(message);
    });
    _musicPlayerSubscription = _musicPlayer.snapshots.listen((snapshot) {
      currentMedia
        ..isPlaying = snapshot.playing
        ..position = snapshot.position
        ..duration = snapshot.duration == Duration.zero
            ? currentMedia.duration
            : snapshot.duration;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  LocalStorage? _localStorage;
  ApiClient? _apiClient;
  SettingsRepository? _settingsRepository;
  ContactsRepository? _contactsRepository;
  DevicesRepository? _devicesRepository;
  AudioRepository? _audioRepository;
  MusicRepository? _musicRepository;
  AuraAppDataRepository? _appDataRepository;
  CommunicationRepository? _communicationRepository;
  GroupsRepository? _groupsRepository;
  StreamSubscription<String>? _bleLogSubscription;
  StreamSubscription<AuraMusicPlayerSnapshot>? _musicPlayerSubscription;
  Timer? _persistDebounce;
  String _activeUserId = '';
  String _audioStatus = 'idle';
  XFile? _capturedAudio;
  final AuraBleService _bleService = AuraBleService();
  final AuraMusicPlayerService _musicPlayer = AuraMusicPlayerService();
  String _selectedBleDeviceId = '';
  String _pendingEcoMindWifiSsid = '';
  String esp32BleStatus = 'EcoMind desconectada';
  bool esp32BleBusy = false;
  final List<String> esp32BleLog = [];

  AppInitStage appInitStage = AppInitStage.checkingSession;
  String appInitMessage = 'Inicializando sessao...';
  String? appInitError;
  bool _appInitialized = false;

  bool isLoggedIn = false;
  bool isListening = false;
  String greeting = 'Olá';
  int currentTemp = 24;
  String weatherCondition = 'Tempo local';
  double precipitationMm = 0;
  int humidity = 0;
  double windSpeedKmh = 0;
  double weatherLatitude = 0;
  double weatherLongitude = 0;
  String location = 'São Paulo';
  String themeMode = 'dark';
  String lang;
  double appBrightness = 0.85;
  double deviceBrightness = 0.72;
  bool adaptiveBrightness = true;
  bool doNotDisturb = false;
  bool notificationDelivery = true;
  bool microphonePermission = false;
  bool cameraPermission = false;
  bool contactsPermission = false;
  bool notificationsPermission = false;
  bool callPhonePermission = false;
  bool smsPermission = false;
  bool callLogPermission = false;
  String activeSkill = '';
  String ringtone = 'Radar';
  String listMode = 'listas';
  String alarmMode = 'alarmes';
  AuraRoute route = AuraRoute.home;
  DateTime calendarMonth = _dateOnly(DateTime.now());
  DateTime selectedCalendarDate = _dateOnly(DateTime.now());

  String selectedDeviceId = '';
  String selectedContactId = '';
  String selectedGroupId = '';
  String selectedAccountId = '';
  String selectedListId = '';
  String selectedNoteId = '';
  String selectedAlarmId = '';
  String selectedWorldClockId = 'br-sp';
  AuraReminder? selectedReminder;
  DateTime? selectedReminderDate;
  AuraAlarm? ringingAlarm;
  AuraTimerItem? ringingTimer;
  final AuraStopwatchState stopwatch = AuraStopwatchState();
  String callingContact = '';
  String chatContact = '';
  String lastVoiceTranscript = '';
  String lastAuraReply = '';

  // Notifications and Privacy
  final List<AuraNotification> notifications = [];
  AuraPrivacy? userPrivacy;
  String selectedNotificationToneId = 'Radar';

  Timer? _listenTimer;
  Timer? _auraLightResetTimer;
  Timer? _greetingTimer;
  Timer? _clockTimer;
  DateTime? _lastBackAt;
  DateTime? _lastEcoMindMissingStateAt;
  AuraLightState _auraLightState = AuraLightState.idle;

  final List<AuraDevice> devices = [];

  final List<AuraContact> contacts = [];

  final List<AuraGroup> groups = [];

  final List<AuraCallSession> callSessions = [];

  final Map<String, List<AuraMessage>> _messageCache = {};
  AuraCallSession? activeCallSession;

  final List<AuraList> lists = [];

  final List<AuraNote> notes = [];

  final List<AuraAlarm> alarms = [];

  final List<AuraTimerItem> timers = [];

  final Map<DateTime, List<AuraReminder>> reminders = {};

  final List<AuraAccount> accounts = [];

  final List<AuraNetworkItem> wifiNetworks = [
    AuraNetworkItem(
      id: 'wifi-scan',
      name: 'Buscar redes Wi-Fi próximas',
      type: 'Wi-Fi',
      signal: 'Toque para atualizar',
      available: true,
    ),
    AuraNetworkItem(
      id: 'wifi-manual',
      name: 'Adicionar rede manualmente',
      type: 'Wi-Fi',
      signal: 'SSID e senha',
      available: true,
    ),
  ];

  final List<AuraNetworkItem> bluetoothDevices = [
    AuraNetworkItem(
      id: 'bt-scan',
      name: 'Buscar Bluetooth próximo',
      type: 'Bluetooth',
      signal: 'Toque para atualizar',
      available: true,
    ),
    AuraNetworkItem(
      id: 'bt-fallback',
      name: 'Parear dispositivo manualmente',
      type: 'Bluetooth',
      signal: 'Fallback quando o scan real não estiver disponível',
      available: true,
    ),
  ];

  final List<AuraNetworkItem> zigbeeHubs = [
    AuraNetworkItem(
      id: 'zigbee-hub',
      name: 'Adicionar hub Zigbee',
      type: 'Zigbee',
      signal: 'Necessário para sensores, lâmpadas e fechaduras Zigbee',
      available: true,
    ),
  ];

  final List<AuraNotificationTone> notificationTones = [
    AuraNotificationTone(
      id: 'Radar',
      title: 'Radar',
      description: 'Curto e discreto',
    ),
    AuraNotificationTone(
      id: 'Cristal',
      title: 'Cristal',
      description: 'Claro e suave',
    ),
    AuraNotificationTone(
      id: 'Aurora',
      title: 'Aurora',
      description: 'Melódico',
    ),
    AuraNotificationTone(id: 'Pulso', title: 'Pulso', description: 'Rápido'),
    AuraNotificationTone(
      id: 'Chime',
      title: 'Chime',
      description: 'Som clássico de app',
    ),
    AuraNotificationTone(
      id: 'Soft Bell',
      title: 'Soft Bell',
      description: 'Sino leve para alarmes',
    ),
    AuraNotificationTone(
      id: 'Deep Focus',
      title: 'Deep Focus',
      description: 'Grave e discreto',
    ),
    AuraNotificationTone(
      id: 'Chuva',
      title: 'Chuva',
      description: 'Textura suave para lembretes',
    ),
    AuraNotificationTone(
      id: 'Oceano',
      title: 'Oceano',
      description: 'Ondas leves para timers',
    ),
    AuraNotificationTone(
      id: 'Emergencia',
      title: 'Emergencia suave',
      description: 'Alerta mais forte sem ser agressivo',
    ),
    AuraNotificationTone(
      id: 'system',
      title: 'Toque do sistema',
      description: 'Escolher um alarme do celular',
      systemPicker: true,
    ),
  ];

  final List<AuraSkill> skills = [
    AuraSkill(
      id: 'spotify',
      title: 'Spotify',
      subtitle: 'Música e podcasts',
      icon: Icons.music_note_rounded,
      color: const Color(0xFF22C55E),
      connectUrl: 'https://accounts.spotify.com/',
    ),
    AuraSkill(
      id: 'youtube-music',
      title: 'YouTube Music',
      subtitle: 'Playlists, clipes e recomendações',
      icon: Icons.play_circle_fill_rounded,
      color: const Color(0xFFEF4444),
      connectUrl: 'https://music.youtube.com/',
    ),
    AuraSkill(
      id: 'apple-music',
      title: 'Apple Music',
      subtitle: 'Biblioteca e rádios',
      icon: Icons.library_music_rounded,
      color: const Color(0xFFFB7185),
      connectUrl: 'https://music.apple.com/',
    ),
    AuraSkill(
      id: 'ifood',
      title: 'iFood',
      subtitle: 'Pedidos por voz',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFF97316),
      connectUrl: 'https://www.ifood.com.br/',
    ),
    AuraSkill(
      id: 'smartthings',
      title: 'SmartThings',
      subtitle: 'Casa conectada',
      icon: Icons.hub_rounded,
      color: const Color(0xFF3B82F6),
      connectUrl: 'https://account.smartthings.com/',
    ),
    AuraSkill(
      id: 'home-assistant',
      title: 'Home Assistant',
      subtitle: 'Automação local avançada',
      icon: Icons.home_work_rounded,
      color: const Color(0xFF38BDF8),
      connectUrl: 'https://www.home-assistant.io/integrations/',
    ),
    AuraSkill(
      id: 'philips-hue',
      title: 'Philips Hue',
      subtitle: 'Luzes, cenas e cores',
      icon: Icons.lightbulb_rounded,
      color: const Color(0xFFFACC15),
      connectUrl: 'https://account.meethue.com/',
    ),
    AuraSkill(
      id: 'xbox',
      title: 'Xbox Cloud Gaming',
      subtitle: 'Jogos e controle por voz',
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFF16A34A),
      connectUrl: 'https://www.xbox.com/play',
    ),
    AuraSkill(
      id: 'geforce-now',
      title: 'GeForce NOW',
      subtitle: 'Jogos em nuvem',
      icon: Icons.gamepad_rounded,
      color: const Color(0xFF84CC16),
      connectUrl: 'https://play.geforcenow.com/',
    ),
  ];

  AuraMedia currentMedia = AuraMedia(
    title: 'Nenhuma mídia tocando',
    artist: 'Conecte Spotify, YouTube Music ou Apple Music',
    imageUrl: '',
    isPlaying: false,
  );
  String musicErrorMessage = '';
  final List<AuraMedia> recentlyPlayed = [];

  final List<AuraActivity> recentActivities = [];

  final List<AuraWorldClock> worldClocks = const [
    AuraWorldClock(
      id: 'br-sp',
      country: 'Brasil',
      city: 'São Paulo',
      utcOffsetMinutes: -180,
      latitude: -23.5505,
      longitude: -46.6333,
    ),
    AuraWorldClock(
      id: 'us-ny',
      country: 'Estados Unidos',
      city: 'Nova York',
      utcOffsetMinutes: -240,
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    AuraWorldClock(
      id: 'pt-lis',
      country: 'Portugal',
      city: 'Lisboa',
      utcOffsetMinutes: 60,
      latitude: 38.7223,
      longitude: -9.1393,
    ),
    AuraWorldClock(
      id: 'jp-tokyo',
      country: 'Japão',
      city: 'Tóquio',
      utcOffsetMinutes: 540,
      latitude: 35.6762,
      longitude: 139.6503,
    ),
    AuraWorldClock(
      id: 'gb-london',
      country: 'Reino Unido',
      city: 'Londres',
      utcOffsetMinutes: 60,
      latitude: 51.5072,
      longitude: -0.1276,
    ),
  ];

  bool get isAppReady => appInitStage == AppInitStage.ready;
  bool get isAppInitializing =>
      appInitStage != AppInitStage.ready && appInitStage != AppInitStage.error;
  bool get hasInitError => appInitStage == AppInitStage.error;
  bool get esp32BleConnected => _bleService.isReady;
  String get activeUserId => _activeUserId;
  String get audioStatus => _audioStatus;
  AuraLightState get auraLightState => _auraLightState;

  AuraDevice? get selectedDevice => findDevice(selectedDeviceId);
  AuraContact? get selectedContact =>
      contacts.where((c) => c.id == selectedContactId).firstOrNull;
  AuraGroup? get selectedGroup =>
      groups.where((group) => group.id == selectedGroupId).firstOrNull;
  AuraAccount? get selectedAccount =>
      accounts.where((account) => account.id == selectedAccountId).firstOrNull;
  AuraList? get selectedList =>
      lists.where((l) => l.id == selectedListId).firstOrNull;
  AuraNote? get selectedNote =>
      notes.where((n) => n.id == selectedNoteId).firstOrNull;
  AuraAlarm? get selectedAlarm =>
      alarms.where((a) => a.id == selectedAlarmId).firstOrNull;
  AuraAccount? get currentAccount =>
      accounts.where((item) => item.id == _activeUserId).firstOrNull ??
      accounts.firstOrNull;
  List<AuraMessage> get selectedConversationMessages =>
      selectedGroupId.trim().isNotEmpty
      ? _messageCache[_conversationKey(groupId: selectedGroupId)] ?? const []
      : _messageCache[_conversationKey(contactId: selectedContactId)] ??
            const [];
  List<AuraMessage> get auraConversationMessages =>
      _messageCache[_conversationKey(contactId: _auraConversationContactId)] ??
      const [];
  String get _storageUserId =>
      _activeUserId.isNotEmpty ? _activeUserId : _localAuraUserId;
  AuraWorldClock get selectedWorldClock =>
      worldClocks
          .where((item) => item.id == selectedWorldClockId)
          .firstOrNull ??
      worldClocks.first;
  AuraPrivacy get effectivePrivacy => userPrivacy ?? AuraPrivacy();
  List<AuraReminder> get selectedDateReminders =>
      reminders[_dateOnly(selectedCalendarDate)] ?? [];
  DateTime get today => _dateOnly(DateTime.now());
  String? get selectedDateHoliday => holidayFor(selectedCalendarDate);

  Future<void> initializeApp({bool force = false}) async {
    if (_appInitialized && !force) return;
    await _ensureDependencies();

    appInitError = null;
    _setInit(AppInitStage.checkingSession, 'Verificando sessao do usuario...');

    final user = _authRepository.currentUser;
    if (user == null) {
      isLoggedIn = false;
      _activeUserId = '';
      _setInit(AppInitStage.ready, 'Pronto');
      _appInitialized = true;
      return;
    }

    _activeUserId = user.id;
    await _loadProfileAndSession(user.id, user.email ?? '', '');

    _setInit(AppInitStage.checkingBackend, 'Checando backend...');
    final backendOk = await _checkBackendHealth();
    if (!backendOk) {
      appInitError =
          'Backend indisponivel: voz, IA e musica podem ficar limitadas.';
    }

    await _loadSettingsDevicesContacts();
    _setInit(AppInitStage.ready, 'Pronto');
    _appInitialized = true;
  }

  Future<void> _ensureDependencies() async {
    if (_localStorage != null) return;
    _localStorage = await LocalStorage.create();
    _apiClient ??= ApiClient(
      tokenProvider: () => _authRepository.currentAccessToken(),
    );
    _settingsRepository = SettingsRepository(_localStorage!);
    _contactsRepository = ContactsRepository(_localStorage!);
    _devicesRepository = DevicesRepository(_localStorage!);
    _audioRepository = AudioRepository(_apiClient!, _localStorage!);
    _musicRepository = MusicRepository(_apiClient!, _localStorage!);
    _appDataRepository = AuraAppDataRepository(_localStorage!);
    _communicationRepository = CommunicationRepository(_localStorage!);
    _groupsRepository = GroupsRepository(_localStorage!);
  }

  Future<bool> _checkBackendHealth() async {
    final api = _apiClient;
    if (api == null) return false;
    try {
      await api.get('/api/health', auth: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyWeather(AuraWeatherResult weather) {
    currentTemp = weather.temperature;
    location = weather.location;
    weatherCondition = weather.condition;
    precipitationMm = weather.precipitationMm;
    humidity = weather.humidity;
    windSpeedKmh = weather.windSpeedKmh;
    weatherLatitude = weather.latitude;
    weatherLongitude = weather.longitude;
  }

  List<AuraAccount> _ownerFirstAccounts({
    required AuraAccount? owner,
    required List<AuraAccount> loaded,
    required String userId,
  }) {
    final byId = <String, AuraAccount>{};
    for (final account in loaded) {
      if (account.id.trim().isEmpty) continue;
      byId[account.id] = account;
    }
    if (owner != null) {
      byId[owner.id] = owner;
    }
    final result = byId.values.toList();
    result.sort((a, b) {
      if (a.id == userId) return -1;
      if (b.id == userId) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return result;
  }

  String _conversationKey({String contactId = '', String groupId = ''}) {
    return groupId.trim().isNotEmpty
        ? 'group:${groupId.trim()}'
        : 'contact:${contactId.trim()}';
  }

  static const String _auraConversationContactId = 'aura';

  void _setAuraLightState(AuraLightState state, {Duration? autoResetAfter}) {
    _auraLightResetTimer?.cancel();
    _auraLightState = state;
    unawaited(_syncEcoMindStateForAura(state));
    if (autoResetAfter != null && state != AuraLightState.idle) {
      _auraLightResetTimer = Timer(autoResetAfter, () {
        if (_auraLightState == state) {
          _auraLightState = AuraLightState.idle;
          unawaited(_syncEcoMindState('idle'));
          notifyListeners();
        }
      });
    }
    super.notifyListeners();
  }

  Future<void> _syncEcoMindStateForAura(AuraLightState state) {
    return _syncEcoMindState(switch (state) {
      AuraLightState.idle => 'idle',
      AuraLightState.listening => 'listening',
      AuraLightState.processing => 'processing',
      AuraLightState.responding => 'responding',
      AuraLightState.success => 'success',
      AuraLightState.error => 'error',
    });
  }

  Future<void> _syncEcoMindState(String state) async {
    if (state.trim().isEmpty) return;
    if (!_bleService.isReady) {
      if (state != 'idle') {
        final now = DateTime.now();
        final shouldLog =
            _lastEcoMindMissingStateAt == null ||
            now.difference(_lastEcoMindMissingStateAt!).inSeconds >= 15;
        if (shouldLog) {
          _lastEcoMindMissingStateAt = now;
          esp32BleStatus =
              'EcoMind desconectada: LED fisico nao recebeu "$state"';
          _appendEsp32Log('EcoMind desconectada para estado "$state"');
        }
      }
      return;
    }
    try {
      await _bleService.sendJson({'cmd': 'state', 'state': state});
    } catch (error) {
      esp32BleStatus = 'Falha ao atualizar LED da EcoMind';
      _appendEsp32Log('State error: $error');
    }
  }

  Future<void> _loadProfileAndSession(
    String userId,
    String email,
    String preferredName,
  ) async {
    _setInit(AppInitStage.loadingProfile, 'Carregando perfil...');
    final user = _authRepository.currentUser;
    UserProfileData? profile;
    if (user != null) {
      try {
        profile = await _userRepository.loadProfile(user);
      } catch (_) {
        profile = null;
      }
    }
    final profileName = profile?.name.trim() ?? '';
    final resolvedName = profileName.isNotEmpty
        ? profileName
        : (preferredName.trim().isNotEmpty
              ? preferredName.trim()
              : (email.contains('@') ? email.split('@').first : 'Usuario'));
    final titleCaseName = resolvedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');

    if (accounts.isEmpty) {
      accounts.add(
        AuraAccount(
          id: userId,
          name: titleCaseName,
          role: 'Proprietario',
          imageAsset: profile?.avatarUrl.trim().isEmpty == true
              ? null
              : profile?.avatarUrl,
          imagePath: profile?.avatarPath.trim().isEmpty == true
              ? null
              : profile?.avatarPath,
          email: email,
          canManageDevices: true,
          canManageMembers: true,
          canUseVoice: true,
          canUseMedia: true,
          canViewHistory: true,
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
        ),
      );
    } else {
      final current = accounts.first;
      accounts[0] = AuraAccount(
        id: userId,
        name: titleCaseName,
        role: current.role,
        imageAsset: profile?.avatarUrl.trim().isNotEmpty == true
            ? profile!.avatarUrl
            : current.imageAsset,
        imagePath: profile?.avatarPath.trim().isNotEmpty == true
            ? profile!.avatarPath
            : current.imagePath,
        email: email,
        notificationsEnabled: current.notificationsEnabled,
        canManageDevices: current.canManageDevices,
        canManageMembers: current.canManageMembers,
        canUseVoice: current.canUseVoice,
        canUseMedia: current.canUseMedia,
        canViewHistory: current.canViewHistory,
        phone: current.phone,
        joinedAt: current.joinedAt,
        lastLogin: DateTime.now(),
        privacy: current.privacy,
      );
    }
    await _groupsRepository?.acceptPendingInvites(
      userId: userId,
      email: email,
      name: titleCaseName,
    );
    isLoggedIn = true;
    route = AuraRoute.home;
  }

  Future<void> _loadSettingsDevicesContacts() async {
    final userId = _activeUserId;
    if (userId.isEmpty) return;

    _setInit(AppInitStage.loadingSettings, 'Sincronizando configuracoes...');
    final settings = await _settingsRepository!.load(userId);
    themeMode = settings.theme;
    lang = settings.language;
    ringtone = settings.ringtone;
    selectedNotificationToneId = settings.ringtone;
    doNotDisturb =
        settings.raw['do_not_disturb'] == true ||
        (settings.raw['do_not_disturb'] == null &&
            AuraStorageService.getDoNotDisturb() == true);
    notificationDelivery = settings.raw['notification_delivery'] != false;
    appBrightness = settings.raw['app_brightness'] is num
        ? (settings.raw['app_brightness'] as num)
              .toDouble()
              .clamp(0.25, 1)
              .toDouble()
        : appBrightness;
    deviceBrightness = settings.raw['device_brightness'] is num
        ? (settings.raw['device_brightness'] as num)
              .toDouble()
              .clamp(0, 1)
              .toDouble()
        : deviceBrightness;
    adaptiveBrightness = settings.raw['adaptive_brightness'] != false;

    final loadedGroups = await _groupsRepository!.loadGroups(userId);
    groups
      ..clear()
      ..addAll(loadedGroups);
    if (groups.where((group) => group.ownerId == userId).isEmpty) {
      final defaultGroup = await _groupsRepository!.ensureDefaultGroup(
        userId: userId,
      );
      if (defaultGroup != null) {
        groups.insert(0, defaultGroup);
      }
    }

    _setInit(AppInitStage.loadingDevices, 'Carregando dispositivos...');
    final loadedDevices = await _devicesRepository!.load(
      userId,
      groupIds: groups.map((group) => group.id).toList(),
    );
    devices
      ..clear()
      ..addAll(loadedDevices);
    final ownedGroup = groups
        .where((group) => group.ownerId == userId)
        .firstOrNull;
    if (ownedGroup != null) {
      var assignedGroup = false;
      for (final device in devices.where((device) => device.groupId.isEmpty)) {
        device.groupId = ownedGroup.id;
        assignedGroup = true;
      }
      if (assignedGroup) {
        unawaited(_devicesRepository!.save(userId, devices));
      }
    }
    if (devices.isNotEmpty && selectedDeviceId.isEmpty) {
      selectedDeviceId = devices.first.id;
    }

    _setInit(AppInitStage.loadingContacts, 'Carregando contatos...');
    final loadedContacts = await _contactsRepository!.load(userId);
    contacts
      ..clear()
      ..addAll(loadedContacts);
    if (contacts.isNotEmpty && selectedContactId.isEmpty) {
      selectedContactId = contacts.first.id;
    }

    final appData = await _appDataRepository!.load(userId);
    lists
      ..clear()
      ..addAll(appData.lists);
    notes
      ..clear()
      ..addAll(appData.notes);
    alarms
      ..clear()
      ..addAll(appData.alarms);
    timers
      ..clear()
      ..addAll(appData.timers);
    reminders
      ..clear()
      ..addAll(appData.reminders);
    recentActivities
      ..clear()
      ..addAll(appData.activities);
    notifications
      ..clear()
      ..addAll(appData.notifications);
    if (appData.networks.isNotEmpty) {
      wifiNetworks
        ..clear()
        ..addAll(appData.networks.where((item) => item.type == 'Wi-Fi'));
      bluetoothDevices
        ..clear()
        ..addAll(appData.networks.where((item) => item.type == 'Bluetooth'));
      zigbeeHubs
        ..clear()
        ..addAll(appData.networks.where((item) => item.type == 'Zigbee'));
    }

    if (appData.accounts.isNotEmpty) {
      final owner =
          accounts.where((item) => item.id == userId).firstOrNull ??
          accounts.firstOrNull;
      final sortedAccounts = _ownerFirstAccounts(
        owner: owner,
        loaded: appData.accounts,
        userId: userId,
      );
      accounts
        ..clear()
        ..addAll(sortedAccounts);
    }

    for (final skill in skills) {
      final permission = appData.skillPermissions[skill.id];
      if (permission != null) skill.permission = permission;
    }
    if (appData.selectedWorldClockId?.isNotEmpty == true) {
      selectedWorldClockId = appData.selectedWorldClockId!;
      final clock = selectedWorldClock;
      location = clock.city;
      _updateGreeting();
    }
    if (appData.privacy != null) userPrivacy = appData.privacy;

    final localMusic = _musicRepository?.loadLocal(userId);
    if (localMusic != null) {
      currentMedia = AuraMedia(
        id: localMusic.id,
        title: localMusic.title,
        artist: localMusic.artist,
        source: localMusic.source,
        audioUrl: localMusic.audioUrl,
        imageUrl: localMusic.thumbnailUrl,
        isPlaying: localMusic.isPlaying,
        videoId: localMusic.videoId,
        youtubeUrl: localMusic.youtubeUrl,
        spotifyUrl: localMusic.spotifyUrl,
        duration: localMusic.duration,
        position: localMusic.position,
      );
    }

    final loadedCallSessions = await _communicationRepository!.loadCallSessions(
      userId,
    );
    callSessions
      ..clear()
      ..addAll(loadedCallSessions);

    if (lists.isNotEmpty && selectedListId.isEmpty) {
      selectedListId = lists.first.id;
    }
    if (notes.isNotEmpty && selectedNoteId.isEmpty) {
      selectedNoteId = notes.first.id;
    }
    if (alarms.isNotEmpty && selectedAlarmId.isEmpty) {
      selectedAlarmId = alarms.first.id;
    }
    unawaited(_rescheduleNativeAlertsBestEffort());
    await _loadAuraConversation();
    await _loadSelectedConversation();
  }

  Future<void> _rescheduleNativeAlertsBestEffort() async {
    try {
      for (final alarm in alarms) {
        if (alarm.active) {
          await AuraNotificationService.scheduleAlarm(alarm);
        } else {
          await AuraNotificationService.cancelAlarm(alarm.id);
        }
      }
      for (final timer in timers) {
        if (timer.active && timer.remainingSeconds > 0) {
          await AuraNotificationService.scheduleTimer(timer);
        } else {
          await AuraNotificationService.cancelTimer(timer.id);
        }
      }
    } catch (_) {
      // In-app alerts still run; native scheduling is best effort per platform.
    }
  }

  void _setInit(AppInitStage stage, String message, {String? error}) {
    appInitStage = stage;
    appInitMessage = message;
    appInitError = error;
    super.notifyListeners();
  }

  Future<void> _loadSelectedConversation() async {
    final userId = _activeUserId;
    final groupId = selectedGroupId;
    final contactId = selectedContactId;
    if (userId.isEmpty || (contactId.isEmpty && groupId.isEmpty)) return;
    final messages = await _communicationRepository?.loadMessages(
      userId,
      contactId: groupId.isEmpty ? contactId : '',
      groupId: groupId,
    );
    if (messages == null) return;
    _messageCache[_conversationKey(contactId: contactId, groupId: groupId)] =
        messages;
    super.notifyListeners();
  }

  Future<void> _loadAuraConversation() async {
    final userId = _activeUserId;
    if (userId.isEmpty) return;
    final messages = await _communicationRepository?.loadMessages(
      userId,
      contactId: _auraConversationContactId,
    );
    if (messages == null) return;
    _messageCache[_conversationKey(contactId: _auraConversationContactId)] =
        messages;
    super.notifyListeners();
  }

  Future<void> onAuthenticatedSession({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _ensureDependencies();
    _activeUserId = userId;
    await _loadProfileAndSession(userId, email, name);
    await _loadSettingsDevicesContacts();
    _setInit(AppInitStage.ready, 'Pronto');
    _appInitialized = true;
    notifyListeners();
  }

  Future<void> bootstrapNativeState() async {
    final permissions = await AuraPlatformService.requestCorePermissions();
    microphonePermission = permissions['microphone'] ?? microphonePermission;
    cameraPermission = permissions['camera'] ?? cameraPermission;
    contactsPermission = permissions['contacts'] ?? contactsPermission;
    notificationsPermission =
        permissions['notifications'] ?? notificationsPermission;

    final weather = await AuraPlatformService.readLocalWeather();
    if (weather != null) {
      _applyWeather(weather);
      await AuraStorageService.saveLastWeatherTemp(weather.temperature);
      await AuraStorageService.saveLastLocation(weather.location);
    } else {
      currentTemp = AuraStorageService.getLastWeatherTemp() ?? currentTemp;
      location = AuraStorageService.getLastLocation() ?? location;
    }
    notifyListeners();
  }

  void login({
    String email = '',
    String provider = 'E-mail',
    String name = '',
  }) {
    final trimmedEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final fallbackName = cleanName.isNotEmpty
        ? cleanName
        : trimmedEmail.contains('@')
        ? trimmedEmail.split('@').first
        : provider;
    final displayName = fallbackName
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');

    if (accounts.isEmpty) {
      accounts.add(
        AuraAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: displayName.isEmpty ? 'Nova conta' : displayName,
          role: 'Proprietário',
          email: trimmedEmail,
          canManageDevices: true,
          canManageMembers: true,
          canUseVoice: true,
          canUseMedia: true,
          canViewHistory: true,
          joinedAt: DateTime.now(),
          lastLogin: DateTime.now(),
        ),
      );
    } else {
      accounts.first
        ..name = displayName.isEmpty ? accounts.first.name : displayName
        ..email = trimmedEmail.isEmpty ? accounts.first.email : trimmedEmail
        ..lastLogin = DateTime.now();
    }
    _activeUserId = accounts.first.id;
    isLoggedIn = true;
    route = AuraRoute.home;
    notifyListeners();
  }

  void logout({bool remote = true}) {
    if (remote) {
      _authRepository.signOut();
    }
    isLoggedIn = false;
    _activeUserId = '';
    contacts.clear();
    devices.clear();
    accounts.clear();
    groups.clear();
    callSessions.clear();
    _messageCache.clear();
    activeCallSession = null;
    lastVoiceTranscript = '';
    lastAuraReply = '';
    _auraLightResetTimer?.cancel();
    _auraLightState = AuraLightState.idle;
    route = AuraRoute.home;
    _setInit(AppInitStage.ready, 'Pronto');
    _appInitialized = true;
    notifyListeners();
  }

  void go(AuraRoute nextRoute) {
    route = nextRoute;
    notifyListeners();
  }

  void goBack() {
    route = route.parentRoute;
    notifyListeners();
  }

  bool handleSystemBack() {
    if (route.isSubRoute) {
      goBack();
      return false;
    }

    final now = DateTime.now();
    final shouldExit =
        _lastBackAt != null && now.difference(_lastBackAt!).inSeconds < 2;
    _lastBackAt = now;
    notifyListeners();
    return shouldExit;
  }

  void goMain(AuraRoute mainRoute) {
    route = mainRoute;
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (isListening || _audioStatus == 'recording') {
      await _finishVoiceInteraction();
      return;
    }

    isListening = true;
    _setAuraLightState(AuraLightState.listening);
    await startVoiceRecording();
    if (_audioStatus != 'recording') {
      isListening = false;
      _setAuraLightState(
        AuraLightState.error,
        autoResetAfter: const Duration(seconds: 4),
      );
      addNotification(
        title: 'Microfone indisponivel',
        body: 'Nao consegui iniciar a gravacao de voz.',
        origin: 'Voz',
      );
      notifyListeners();
      return;
    }

    _listenTimer?.cancel();
    _listenTimer = Timer(const Duration(seconds: 12), () {
      unawaited(_finishVoiceInteraction());
    });
  }

  Future<void> _finishVoiceInteraction() async {
    _listenTimer?.cancel();
    if (_audioStatus != 'recording' && !isListening) return;
    isListening = false;
    _setAuraLightState(AuraLightState.processing);

    final transcript = await stopVoiceRecordingAndUpload();
    lastVoiceTranscript = transcript.trim();
    if (lastVoiceTranscript.isEmpty) {
      _setAuraLightState(
        AuraLightState.error,
        autoResetAfter: const Duration(seconds: 4),
      );
      addNotification(
        title: 'Voz nao reconhecida',
        body: lastAuraReply.trim().isNotEmpty
            ? lastAuraReply
            : 'Tente falar mais perto do microfone.',
        origin: 'Voz',
      );
      return;
    }

    if (await _tryHandleEcoMindVoiceCommand(lastVoiceTranscript)) {
      notifyListeners();
      return;
    }

    await sendAuraMessage(lastVoiceTranscript, source: 'voice');
    if (lastAuraReply.trim().isNotEmpty) {
      addNotification(
        title: 'Aura respondeu',
        body: lastAuraReply,
        origin: 'Voz',
      );
    }
    notifyListeners();
  }

  Future<bool> _tryHandleEcoMindVoiceCommand(String transcript) async {
    final text = _normalizeVoiceCommand(transcript);
    final requestedColor = _ecoMindColorFromVoice(text);
    final mentionsLight =
        text.contains('luz') ||
        text.contains('lampada') ||
        text.contains('ecomind') ||
        text.contains('eco mind') ||
        (requestedColor != null &&
            (text.contains('mudar') ||
                text.contains('cor') ||
                text.contains('colocar')));
    if (!mentionsLight) return false;

    Map<String, Object?>? command;
    String label = '';
    final brightnessMatch = RegExp(r'brilho\s+(\d{1,3})').firstMatch(text);
    if (brightnessMatch != null) {
      final value = int.tryParse(brightnessMatch.group(1) ?? '') ?? 0;
      command = {'cmd': 'brightness', 'value': value.clamp(0, 100)};
      label = 'brilho ${value.clamp(0, 100)}%';
    } else if (text.contains('desligar') || text.contains('apagar')) {
      command = {'cmd': 'led', 'color': 'apagar'};
      label = 'apagar luz';
    } else if (text.contains('ligar') || text.contains('acender')) {
      command = {'cmd': 'led', 'color': 'branco'};
      label = 'ligar luz';
    } else {
      final color = requestedColor;
      if (color == null) return false;
      command = {'cmd': 'led', 'color': color};
      label = 'mudar para $color';
    }

    final result = await sendEsp32Command(command);
    final connected = result == 'sent';
    lastAuraReply = connected
        ? 'Comando enviado para a EcoMind: $label.'
        : 'Comando entendido ($label), mas a EcoMind nao recebeu: $result';
    addNotification(
      title: connected ? 'EcoMind atualizada' : 'EcoMind desconectada',
      body: lastAuraReply,
      origin: 'EcoMind',
    );
    addActivity(
      text: 'Comando de voz EcoMind',
      origin: 'EcoMind',
      details: lastAuraReply,
    );
    _setAuraLightState(
      connected ? AuraLightState.success : AuraLightState.error,
      autoResetAfter: const Duration(seconds: 4),
    );
    return true;
  }

  String _normalizeVoiceCommand(String value) {
    return value
        .toLowerCase()
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  String? _ecoMindColorFromVoice(String text) {
    const colors = {
      'azul': 'azul',
      'roxo': 'roxo',
      'violeta': 'roxo',
      'ambar': 'ambar',
      'laranja': 'ambar',
      'ciano': 'ciano',
      'verde': 'verde',
      'vermelho': 'vermelho',
      'branco': 'branco',
      'amarelo': 'amarelo',
    };
    for (final entry in colors.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return null;
  }

  void setLocation(String value) {
    if (value.trim().isEmpty) return;
    location = value.trim();
    route = AuraRoute.home;
    notifyListeners();
  }

  AuraDevice? findDevice(String id) {
    return devices.where((device) => device.id == id).firstOrNull;
  }

  Future<void> _saveDevicesBestEffort({String? deletedDeviceId}) async {
    final userId = _activeUserId;
    final repository = _devicesRepository;
    if (repository == null || userId.isEmpty) return;
    try {
      await repository.save(userId, devices);
      if (deletedDeviceId != null && deletedDeviceId.isNotEmpty) {
        await repository.deleteRemote(userId, deletedDeviceId);
      }
      _setAuraLightState(
        AuraLightState.success,
        autoResetAfter: const Duration(seconds: 3),
      );
    } catch (error) {
      _setAuraLightState(
        AuraLightState.error,
        autoResetAfter: const Duration(seconds: 4),
      );
      addNotification(
        title: 'Sincronizacao pendente',
        body:
            'O aparelho foi salvo neste dispositivo, mas ainda nao sincronizou com a conta.',
        origin: 'Dispositivos',
      );
    }
  }

  void toggleDevice(String id) {
    final device = findDevice(id);
    if (device == null) return;
    device.active = !device.active;
    final isEcoMind =
        device.type == AuraDeviceType.hub ||
        device.name.toLowerCase().replaceAll(' ', '').contains('ecomind');
    if (isEcoMind && esp32BleConnected) {
      unawaited(
        sendEsp32Command({
          'cmd': 'led',
          'color': device.active ? 'branco' : 'apagar',
        }),
      );
    }
    device.refreshStatus();
    _devicesRepository?.pushStatus(_activeUserId, device);
    unawaited(_saveDevicesBestEffort());
    addActivity(
      text: device.active
          ? '${device.name} ligado'
          : '${device.name} desligado',
      device: device.name,
      origin: 'Dispositivos',
      details: 'Status atualizado para ${device.status}.',
    );
    notifyListeners();
  }

  void updateDeviceValue(String id, int value) {
    final device = findDevice(id);
    if (device == null) return;
    device.value = value;
    device.refreshStatus();
    _devicesRepository?.pushStatus(_activeUserId, device);
    unawaited(_saveDevicesBestEffort());
    addActivity(
      text: '${device.name} ajustado',
      device: device.name,
      origin: 'Dispositivos',
      details: 'Novo valor: $value. Status: ${device.status}.',
    );
    notifyListeners();
  }

  void updateDeviceAutomation(String id, bool enabled) {
    final device = findDevice(id);
    if (device == null) return;
    device.adaptiveBrightness = enabled;
    notifyListeners();
  }

  void addDevice(
    String name,
    String room,
    AuraDeviceType type, {
    AuraConnectionType connection = AuraConnectionType.wifi,
    Set<AuraConnectionType>? connections,
    String manufacturer = '',
    String model = '',
    bool supportsColor = true,
    bool supportsDimming = true,
  }) {
    if (name.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ownedGroupId =
        groups
            .where((group) => group.ownerId == _activeUserId)
            .firstOrNull
            ?.id ??
        '';
    final device = AuraDevice(
      id: id,
      name: name.trim(),
      room: room.trim().isEmpty ? 'Casa' : room.trim(),
      status: 'Desligado',
      active: false,
      type: type,
      connection: connection,
      connections: connections,
      manufacturer: manufacturer.trim(),
      model: model.trim(),
      groupId: ownedGroupId,
      supportsColor: type == AuraDeviceType.light && supportsColor,
      supportsDimming: supportsDimming,
      value: switch (type) {
        AuraDeviceType.light => 70,
        AuraDeviceType.ac => 23,
        AuraDeviceType.curtain => 100,
        AuraDeviceType.thermostat => 23,
        _ => null,
      },
    );
    devices.add(device);
    selectedDeviceId = id;
    unawaited(_saveDevicesBestEffort());
    addActivity(
      text: '${device.name} adicionado',
      device: device.name,
      origin: 'Dispositivos',
      details:
          '${device.typeLabel} em ${device.room} usando ${device.connectionLabel}.',
    );
    openDeviceConfig(device);
  }

  void deleteDevice(String id) {
    final removed = findDevice(id);
    devices.removeWhere((device) => device.id == id);
    selectedDeviceId = devices.isEmpty ? '' : devices.first.id;
    unawaited(_saveDevicesBestEffort(deletedDeviceId: id));
    route = AuraRoute.moreConfigDeviceSettings;
    if (removed != null) {
      addActivity(
        text: '${removed.name} removido',
        device: removed.name,
        origin: 'Dispositivos',
        details: 'Dispositivo removido da conta.',
      );
    }
    notifyListeners();
  }

  void updateLightSettings(
    String id, {
    int? intensity,
    int? colorHex,
    bool? supportsColor,
    bool? supportsDimming,
  }) {
    final device = findDevice(id);
    if (device == null) return;
    if (intensity != null) device.value = intensity;
    if (colorHex != null) device.colorHex = colorHex;
    if (supportsColor != null) device.supportsColor = supportsColor;
    if (supportsDimming != null) device.supportsDimming = supportsDimming;
    device.refreshStatus();
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
  }

  void updateTvSettings(
    String id, {
    int? volume,
    int? channel,
    int? brightness,
    int? contrast,
    String? colorTemperature,
    bool? hdmiCec,
  }) {
    final device = findDevice(id);
    if (device == null) return;
    if (volume != null) device.tvVolume = volume;
    if (channel != null) device.tvChannel = channel;
    if (brightness != null) device.tvBrightness = brightness;
    if (contrast != null) device.tvContrast = contrast;
    if (colorTemperature != null) {
      device.tvColorTemperature = colorTemperature;
    }
    if (hdmiCec != null) device.hdmiCec = hdmiCec;
    device.refreshStatus();
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
  }

  void updateAcSettings(
    String id, {
    int? temperature,
    String? mode,
    String? fanSpeed,
    bool? ecoMode,
    bool? turboMode,
    bool? sleepMode,
  }) {
    final device = findDevice(id);
    if (device == null) return;
    if (temperature != null) device.value = temperature;
    if (mode != null) device.acMode = mode;
    if (fanSpeed != null) device.fanSpeed = fanSpeed;
    if (ecoMode != null) device.ecoMode = ecoMode;
    if (turboMode != null) device.turboMode = turboMode;
    if (sleepMode != null) device.sleepMode = sleepMode;
    device.refreshStatus();
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
  }

  String? upsertRoutine(
    String deviceId,
    String title,
    String time, {
    String? routineId,
  }) {
    final device = findDevice(deviceId);
    final cleanTitle = title.trim();
    final cleanTime = time.trim().isEmpty ? '22:00' : time.trim();
    if (device == null) return 'Dispositivo nao encontrado.';
    if (cleanTitle.isEmpty) return 'Informe o nome da rotina.';
    final duplicate = device.routines.any(
      (routine) => routine.id != routineId && routine.time == cleanTime,
    );
    if (duplicate) return 'Ja existe uma rotina nesse horario.';

    final editingRoutine = routineId == null
        ? null
        : device.routines
              .where((routine) => routine.id == routineId)
              .firstOrNull;
    if (editingRoutine == null) {
      device.routines.add(
        AuraRoutine(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: cleanTitle,
          kind: AuraRoutineKind.turnOffAt,
          time: cleanTime,
        ),
      );
    } else {
      editingRoutine.title = cleanTitle;
      editingRoutine.time = cleanTime;
      editingRoutine.kind = AuraRoutineKind.turnOffAt;
    }
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
    return null;
  }

  void deleteRoutine(String deviceId, String routineId) {
    final device = findDevice(deviceId);
    if (device == null) return;
    device.routines.removeWhere((routine) => routine.id == routineId);
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
  }

  void toggleRoutine(String deviceId, String routineId) {
    final routine = findDevice(
      deviceId,
    )?.routines.where((item) => item.id == routineId).firstOrNull;
    if (routine == null) return;
    routine.enabled = !routine.enabled;
    unawaited(_saveDevicesBestEffort());
    notifyListeners();
  }

  void openDevice(AuraDevice device) {
    selectedDeviceId = device.id;
    if (device.type == AuraDeviceType.light) {
      route = AuraRoute.deviceLight;
    } else if (device.type == AuraDeviceType.ac) {
      route = AuraRoute.deviceAc;
    } else {
      route = AuraRoute.deviceConfigEcho;
    }
    notifyListeners();
  }

  void openDeviceConfig(AuraDevice device) {
    selectedDeviceId = device.id;
    route = AuraRoute.deviceConfigEcho;
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (currentMedia.isPlaying) {
      await pauseMusicPlayback();
    } else {
      await resumeMusicPlayback();
    }
  }

  void playMedia({
    required String title,
    required String subtitle,
    required String imageUrl,
    String id = '',
    String source = '',
    String audioUrl = '',
    String videoId = '',
    String youtubeUrl = '',
  }) {
    currentMedia = AuraMedia(
      id: id,
      title: title,
      artist: subtitle,
      source: source,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      isPlaying: true,
      videoId: videoId,
      youtubeUrl: youtubeUrl,
    );
    route = AuraRoute.play;
    _rememberRecentMedia(currentMedia);
    unawaited(_startCurrentMediaPlayback());
    notifyListeners();
  }

  void startCall(
    String name, {
    String contactId = '',
    String groupId = '',
    AuraRoute from = AuraRoute.communicateCall,
  }) {
    callingContact = name;
    route = AuraRoute.communicateCalling;
    unawaited(
      (_communicationRepository?.startCallSession(
                _activeUserId,
                contactId: contactId,
                groupId: groupId,
              ) ??
              Future<AuraCallSession?>.value())
          .then((session) {
            if (session == null) return;
            activeCallSession = session;
            callSessions.insert(0, session);
            super.notifyListeners();
          }),
    );
    notifyListeners();
  }

  void startChat(AuraContact contact) {
    selectedContactId = contact.id;
    selectedGroupId = '';
    chatContact = contact.name;
    route = AuraRoute.communicateChat;
    unawaited(_loadSelectedConversation());
    unawaited(importNativeSmsForSelectedContact());
    unawaited(importNativeCallLogForSelectedContact());
    notifyListeners();
  }

  void startGroupChat(AuraGroup group) {
    selectedGroupId = group.id;
    selectedContactId = '';
    chatContact = group.name;
    route = AuraRoute.communicateChat;
    unawaited(_loadSelectedConversation());
    notifyListeners();
  }

  void openGroupSettings(AuraGroup group) {
    selectedGroupId = group.id;
    selectedContactId = '';
    route = AuraRoute.communicateGroupSettings;
    notifyListeners();
  }

  Future<void> updateSelectedGroup({
    String? name,
    bool pickPhoto = false,
  }) async {
    final group = selectedGroup;
    if (group == null || group.ownerId != _storageUserId) return;
    final cleanName = name?.trim() ?? '';
    if (cleanName.isNotEmpty) group.name = cleanName;
    if (pickPhoto) {
      final image = await AuraPlatformService.pickProfileImage();
      if (image != null) {
        final upload = await _userRepository.uploadGroupPhoto(
          ownerId: _storageUserId,
          groupId: group.id,
          file: image,
        );
        group.imageAsset = upload?.url ?? image.path;
        group.imagePath = upload?.path;
      }
    }
    await _groupsRepository?.updateGroup(
      userId: _storageUserId,
      group: group,
    );
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    final group = groups.where((item) => item.id == groupId).firstOrNull;
    if (group == null || group.ownerId != _storageUserId) return;
    groups.removeWhere((item) => item.id == groupId);
    _messageCache.remove(_conversationKey(groupId: groupId));
    if (selectedGroupId == groupId) {
      selectedGroupId = '';
      route = AuraRoute.communicate;
    }
    await _groupsRepository?.deleteGroup(
      userId: _storageUserId,
      groupId: groupId,
    );
    notifyListeners();
  }

  Future<void> removeSelectedGroupMember(String memberId) async {
    final group = selectedGroup;
    if (group == null || group.ownerId != _storageUserId) return;
    group.memberIds.removeWhere((id) => id == memberId);
    await _groupsRepository?.updateGroup(
      userId: _storageUserId,
      group: group,
    );
    notifyListeners();
  }

  Future<void> sendChatMessage(String text) async {
    final cleanText = text.trim();
    final userId = _storageUserId;
    final groupId = selectedGroupId;
    final contactId = selectedContactId;
    if (cleanText.isEmpty ||
        userId.isEmpty ||
        (contactId.isEmpty && groupId.isEmpty)) {
      return;
    }
    final contact = selectedContact;
    var status = 'sent';
    if (groupId.isEmpty && contact?.phone.trim().isNotEmpty == true) {
      final nativeSent = await AuraPlatformService.sendSms(
        rawNumber: contact!.phone,
        body: cleanText,
      );
      status = nativeSent ? 'sms_sent' : 'sms_pending';
      if (!nativeSent) {
        addNotification(
          title: 'SMS nao enviado',
          body:
              'A mensagem ficou salva no Aura, mas o Android nao enviou o SMS.',
          origin: 'Mensagens',
        );
      }
    }
    final message = await _communicationRepository?.sendMessage(
      userId,
      body: cleanText,
      contactId: groupId.isEmpty ? contactId : '',
      groupId: groupId,
      payload: {'transport': status},
    );
    if (message == null) return;
    message.status = status;
    final key = _conversationKey(contactId: contactId, groupId: groupId);
    _messageCache.putIfAbsent(key, () => []).add(message);
    addActivity(
      text: 'Mensagem enviada',
      origin: 'Mensagens',
      details: cleanText,
    );
    notifyListeners();
  }

  Future<void> sendAuraMessage(
    String text, {
    String source = 'text',
    String imageName = '',
  }) async {
    await _ensureDependencies();
    final cleanText = text.trim();
    final cleanImageName = imageName.trim();
    final userId = _storageUserId;
    if (cleanText.isEmpty && cleanImageName.isEmpty) {
      return;
    }

    final historyBefore = List<AuraMessage>.from(auraConversationMessages);
    final outgoing = await _communicationRepository?.sendMessage(
      userId,
      body: cleanImageName.isEmpty
          ? cleanText
          : '${cleanText.isEmpty ? 'Imagem enviada' : cleanText}\nImagem anexada: $cleanImageName',
      contactId: _auraConversationContactId,
      direction: 'outgoing',
      payload: {
        'channel': 'aura_chat',
        'source': source,
        if (cleanImageName.isNotEmpty) 'image_name': cleanImageName,
      },
    );
    if (outgoing != null) {
      final key = _conversationKey(contactId: _auraConversationContactId);
      _messageCache.putIfAbsent(key, () => []).add(outgoing);
      notifyListeners();
    }

    _setAuraLightState(AuraLightState.processing);
    final reply = await askAura(
      cleanText,
      imageName: cleanImageName.isEmpty ? null : cleanImageName,
      history: historyBefore,
    );
    lastAuraReply = reply;

    final incoming = await _communicationRepository?.sendMessage(
      userId,
      body: reply,
      contactId: _auraConversationContactId,
      direction: 'incoming',
      payload: {
        'channel': 'aura_chat',
        'source': 'backend',
        'reply_to_source': source,
      },
    );
    if (incoming != null) {
      final key = _conversationKey(contactId: _auraConversationContactId);
      _messageCache.putIfAbsent(key, () => []).add(incoming);
    }
    _setAuraLightState(
      reply.startsWith('Nao consegui') || reply.startsWith('A conexao')
          ? AuraLightState.error
          : AuraLightState.success,
      autoResetAfter: const Duration(seconds: 4),
    );
    notifyListeners();
  }

  Future<void> endActiveCall() async {
    final session = activeCallSession;
    if (session != null) {
      await _communicationRepository?.endCallSession(_activeUserId, session);
    }
    activeCallSession = null;
    route = AuraRoute.communicate;
    notifyListeners();
  }

  void addContact(String name, String phone, String deviceType) {
    if (name.trim().isEmpty || phone.trim().isEmpty) return;
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final duplicate = contacts.any((contact) {
      final sameName =
          contact.name.trim().toLowerCase() == name.trim().toLowerCase();
      final samePhone =
          contact.phone.replaceAll(RegExp(r'[^0-9+]'), '') == normalizedPhone;
      return sameName || (normalizedPhone.isNotEmpty && samePhone);
    });
    if (duplicate) {
      addNotification(
        title: 'Contato duplicado',
        body: 'Ja existe um contato com esse nome ou numero.',
        origin: 'Contatos',
      );
      return;
    }
    contacts.add(
      AuraContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        phone: phone.trim(),
        time: deviceType,
        type: 'Membro Aura',
      ),
    );
    route = AuraRoute.communicate;
    unawaited(
      _contactsRepository?.save(_activeUserId, contacts) ??
          Future<void>.value(),
    );
    notifyListeners();
  }

  Future<void> importPhoneContacts() async {
    final imported = await AuraPlatformService.readDeviceContacts();
    if (imported.isEmpty) return;
    final existingPhones = contacts
        .map((contact) => contact.phone.replaceAll(RegExp(r'[^0-9+]'), ''))
        .toSet();
    for (final contact in imported) {
      final normalized = contact.phone.replaceAll(RegExp(r'[^0-9+]'), '');
      if (normalized.isNotEmpty && existingPhones.contains(normalized)) {
        continue;
      }
      existingPhones.add(normalized);
      contacts.add(contact);
    }
    contactsPermission = true;
    route = AuraRoute.communicate;
    unawaited(
      _contactsRepository?.save(_activeUserId, contacts) ??
          Future<void>.value(),
    );
    notifyListeners();
  }

  void updateContact(String id, String name, String phone, String deviceType) {
    final contact = contacts.where((c) => c.id == id).firstOrNull;
    if (contact == null || name.trim().isEmpty || phone.trim().isEmpty) return;
    contact.name = name.trim();
    contact.phone = phone.trim();
    contact.time = deviceType;
    route = AuraRoute.communicate;
    unawaited(
      _contactsRepository?.save(_activeUserId, contacts) ??
          Future<void>.value(),
    );
    notifyListeners();
  }

  void deleteContact(String id) {
    contacts.removeWhere((contact) => contact.id == id);
    route = AuraRoute.communicate;
    unawaited(
      _contactsRepository?.save(_activeUserId, contacts) ??
          Future<void>.value(),
    );
    unawaited(
      _contactsRepository?.deleteRemote(_activeUserId, id) ??
          Future<void>.value(),
    );
    notifyListeners();
  }

  Future<String?> createGroup(
    String name,
    Set<String> memberIds, {
    String imageAsset = '',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 'Informe um nome para o grupo.';
    final duplicateName = groups.any(
      (group) => group.name.trim().toLowerCase() == cleanName.toLowerCase(),
    );
    if (duplicateName) return 'Ja existe um grupo com esse nome.';
    if (memberIds.isEmpty) return 'Selecione pelo menos um contato.';

    final selectedMembers = contacts
        .where((contact) => memberIds.contains(contact.id))
        .toList();
    final seenNames = <String>{};
    final seenNumbers = <String>{};
    for (final member in selectedMembers) {
      final nameKey = member.name.trim().toLowerCase();
      final numberKey = member.phone.replaceAll(RegExp(r'[^0-9+]'), '');
      if ((nameKey.isNotEmpty && !seenNames.add(nameKey)) ||
          (numberKey.isNotEmpty && !seenNumbers.add(numberKey))) {
        return 'Remova nomes ou numeros repetidos antes de criar o grupo.';
      }
    }

    final groupId = GroupsRepository.newId();
    var groupImageUrl = imageAsset.trim();
    var groupImagePath = '';
    if (groupImageUrl.isNotEmpty &&
        !groupImageUrl.startsWith('http://') &&
        !groupImageUrl.startsWith('https://')) {
      final upload = await _userRepository.uploadGroupPhoto(
        ownerId: _storageUserId,
        groupId: groupId,
        file: XFile(groupImageUrl),
      );
      if (upload != null) {
        groupImageUrl = upload.url;
        groupImagePath = upload.path;
      }
    }

    final group = await _groupsRepository?.createGroup(
      id: groupId,
      userId: _storageUserId,
      name: cleanName,
      members: selectedMembers,
      imageAsset: groupImageUrl,
      imagePath: groupImagePath,
    );
    if (group == null) return 'Nao consegui salvar o grupo agora.';
    groups.insert(0, group);
    addActivity(
      text: 'Grupo criado',
      origin: 'Grupos',
      details: '${group.name} com ${selectedMembers.length} membro(s).',
    );
    selectedGroupId = group.id;
    selectedContactId = '';
    chatContact = group.name;
    route = AuraRoute.communicateChat;
    notifyListeners();
    return null;
  }

  void addList(String title) {
    if (title.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    lists.add(AuraList(id: id, title: title.trim(), items: []));
    selectedListId = id;
    notifyListeners();
  }

  void deleteList(String id) {
    lists.removeWhere((list) => list.id == id);
    if (selectedListId == id) {
      selectedListId = lists.isEmpty ? '' : lists.first.id;
      route = AuraRoute.moreLists;
    }
    notifyListeners();
  }

  void addNote(String title) {
    if (title.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    notes.add(AuraNote(id: id, title: title.trim(), preview: ''));
    selectedNoteId = id;
    route = AuraRoute.moreNoteEdit;
    notifyListeners();
  }

  void selectList(String id) {
    selectedListId = id;
    route = AuraRoute.moreListItems;
    notifyListeners();
  }

  void renameSelectedList(String title) {
    final list = selectedList;
    if (list == null || title.trim().isEmpty) return;
    list.title = title.trim();
    notifyListeners();
  }

  void toggleListItem(String id) {
    final list = selectedList;
    if (list == null) return;
    final item = list.items.where((i) => i.id == id).firstOrNull;
    if (item == null) return;
    item.checked = !item.checked;
    notifyListeners();
  }

  void addListItem(String text) {
    final list = selectedList;
    if (list == null || text.trim().isEmpty) return;
    list.items.add(
      AuraListItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        checked: false,
      ),
    );
    notifyListeners();
  }

  void deleteListItem(String id) {
    final list = selectedList;
    if (list == null) return;
    list.items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void selectNote(String id) {
    selectedNoteId = id;
    route = AuraRoute.moreNoteEdit;
    notifyListeners();
  }

  void updateNote(String title, String preview) {
    final note = selectedNote;
    if (note == null) return;
    note.title = title.trim().isEmpty ? 'Sem título' : title.trim();
    note.preview = preview.trim();
    route = AuraRoute.moreLists;
    notifyListeners();
  }

  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    if (selectedNoteId == id) {
      selectedNoteId = notes.isEmpty ? '' : notes.first.id;
    }
    route = AuraRoute.moreLists;
    notifyListeners();
  }

  void selectAlarm(String id) {
    selectedAlarmId = id;
    route = AuraRoute.moreAlarmEdit;
    notifyListeners();
  }

  void toggleAlarm(String id) {
    final alarm = alarms.where((a) => a.id == id).firstOrNull;
    if (alarm == null) return;
    alarm.active = !alarm.active;
    if (alarm.active) {
      alarm.lastTriggeredAt = null;
      unawaited(AuraNotificationService.scheduleAlarm(alarm));
    } else {
      unawaited(AuraNotificationService.cancelAlarm(alarm.id));
    }
    notifyListeners();
  }

  void updateAlarm(
    String time,
    String label, {
    String? name,
    List<String>? days,
    String? tone,
    String? source,
    int? snoozeMinutes,
    bool? vibrate,
    int? volume,
    int? ringDurationSeconds,
  }) {
    final alarm = selectedAlarm;
    if (alarm == null) return;
    alarm.time = time.trim().isEmpty ? alarm.time : time.trim();
    alarm.label = label.trim().isEmpty ? 'Todos os dias' : label.trim();
    alarm.name = name?.trim().isEmpty ?? true ? alarm.name : name!.trim();
    alarm.days = days ?? alarm.days;
    alarm.tone = tone ?? alarm.tone;
    alarm.source = source ?? alarm.source;
    alarm.snoozeMinutes = snoozeMinutes ?? alarm.snoozeMinutes;
    alarm.vibrate = vibrate ?? alarm.vibrate;
    alarm.volume = volume ?? alarm.volume;
    alarm.ringDurationSeconds =
        ringDurationSeconds ?? alarm.ringDurationSeconds;
    unawaited(AuraNotificationService.scheduleAlarm(alarm));
    route = AuraRoute.moreAlarms;
    notifyListeners();
  }

  void addAlarm(
    String time,
    String label, {
    String? name,
    List<String>? days,
    String? tone,
    String? source,
    int snoozeMinutes = 10,
    bool vibrate = true,
    int volume = 100,
    int ringDurationSeconds = 90,
  }) {
    final alarm = AuraAlarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      time: time.trim().isEmpty ? '08:00' : time.trim(),
      label: label.trim().isEmpty ? 'Todos os dias' : label.trim(),
      active: true,
      name: name?.trim().isEmpty ?? true ? 'Alarme' : name!.trim(),
      days: days,
      tone: tone ?? ringtone,
      source: source ?? 'Aura',
      snoozeMinutes: snoozeMinutes,
      vibrate: vibrate,
      volume: volume,
      ringDurationSeconds: ringDurationSeconds,
    );
    alarms.add(alarm);
    unawaited(AuraNotificationService.scheduleAlarm(alarm));
    route = AuraRoute.moreAlarms;
    notifyListeners();
  }

  void deleteAlarm(String id) {
    alarms.removeWhere((alarm) => alarm.id == id);
    unawaited(AuraNotificationService.cancelAlarm(id));
    if (selectedAlarmId == id) {
      selectedAlarmId = alarms.isEmpty ? '' : alarms.first.id;
      route = AuraRoute.moreAlarms;
    }
    notifyListeners();
  }

  void stopRingingAlarm() {
    ringingAlarm = null;
    unawaited(AuraPlatformService.stopTonePreview());
    notifyListeners();
  }

  void snoozeRingingAlarm() {
    final alarm = ringingAlarm;
    if (alarm == null) return;
    alarm.snoozedUntil = DateTime.now().add(
      Duration(minutes: alarm.snoozeMinutes.clamp(1, 60).toInt()),
    );
    unawaited(AuraNotificationService.cancelAlarm(alarm.id));
    unawaited(AuraNotificationService.scheduleAlarm(alarm));
    ringingAlarm = null;
    unawaited(AuraPlatformService.stopTonePreview());
    addNotification(
      title: 'Soneca ativada',
      body: '${alarm.name} volta em ${alarm.snoozeMinutes} min.',
      origin: 'Alarme',
    );
    notifyListeners();
  }

  void addTimer(String duration, String label) {
    timers.add(
      AuraTimerItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        duration: duration.trim().isEmpty ? '15:00' : duration.trim(),
        label: label.trim().isEmpty ? 'Novo Timer' : label.trim(),
        active: false,
      ),
    );
    route = AuraRoute.moreAlarms;
    notifyListeners();
  }

  void toggleTimer(String id) {
    final timer = timers.where((t) => t.id == id).firstOrNull;
    if (timer == null) return;
    if (timer.remainingSeconds <= 0 || timer.completed) {
      timer.reset();
    }
    timer.active = !timer.active;
    timer.completed = false;
    if (timer.active) {
      unawaited(AuraNotificationService.scheduleTimer(timer));
    } else {
      unawaited(AuraNotificationService.cancelTimer(timer.id));
    }
    notifyListeners();
  }

  void resetTimer(String id) {
    final timer = timers.where((t) => t.id == id).firstOrNull;
    if (timer == null) return;
    timer.reset();
    unawaited(AuraNotificationService.cancelTimer(timer.id));
    notifyListeners();
  }

  void deleteTimer(String id) {
    timers.removeWhere((timer) => timer.id == id);
    unawaited(AuraNotificationService.cancelTimer(id));
    notifyListeners();
  }

  void stopRingingTimer() {
    ringingTimer = null;
    unawaited(AuraPlatformService.stopTonePreview());
    notifyListeners();
  }

  void toggleStopwatch() {
    stopwatch.active = !stopwatch.active;
    notifyListeners();
  }

  void resetStopwatch() {
    stopwatch.reset();
    notifyListeners();
  }

  void lapStopwatch() {
    if (stopwatch.elapsedSeconds == 0) return;
    stopwatch.laps.insert(0, stopwatch.elapsedSeconds);
    notifyListeners();
  }

  void previousCalendarMonth() {
    calendarMonth = DateTime(calendarMonth.year, calendarMonth.month - 1);
    selectedCalendarDate = DateTime(calendarMonth.year, calendarMonth.month, 1);
    notifyListeners();
  }

  void nextCalendarMonth() {
    calendarMonth = DateTime(calendarMonth.year, calendarMonth.month + 1);
    selectedCalendarDate = DateTime(calendarMonth.year, calendarMonth.month, 1);
    notifyListeners();
  }

  void selectCalendarDate(DateTime date) {
    selectedCalendarDate = _dateOnly(date);
    calendarMonth = DateTime(
      selectedCalendarDate.year,
      selectedCalendarDate.month,
    );
    notifyListeners();
  }

  void addReminderForSelectedDate(
    String text, {
    String? time,
    String? endTime,
    String repeat = 'none',
    int alertMinutesBefore = 0,
    bool active = true,
  }) {
    if (text.trim().isEmpty) return;
    final date = _dateOnly(selectedCalendarDate);
    final dayReminders = reminders.putIfAbsent(date, () => []);
    dayReminders.add(
      AuraReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text.trim(),
        time: time?.trim().isEmpty ?? true ? null : time?.trim(),
        endTime: endTime?.trim().isEmpty ?? true ? null : endTime?.trim(),
        repeat: repeat,
        alertMinutesBefore: alertMinutesBefore,
        active: active,
      ),
    );
    notifyListeners();
  }

  void selectReminder(DateTime date, AuraReminder reminder) {
    selectedReminder = reminder;
    selectedReminderDate = _dateOnly(date);
    route = AuraRoute.moreCalendarEdit;
    notifyListeners();
  }

  void updateReminder(
    String text,
    String? time, [
    DateTime? newDate,
    String? endTime,
    String? repeat,
    int? alertMinutesBefore,
    bool? active,
  ]) {
    final reminder = selectedReminder;
    if (reminder == null || text.trim().isEmpty) return;
    final oldDate = _dateOnly(selectedReminderDate ?? selectedCalendarDate);
    final targetDate = _dateOnly(newDate ?? oldDate);
    if (oldDate != targetDate) {
      reminders[oldDate]?.removeWhere((item) => item.id == reminder.id);
      reminders.putIfAbsent(targetDate, () => []).add(reminder);
      selectedReminderDate = targetDate;
      selectedCalendarDate = targetDate;
      calendarMonth = DateTime(targetDate.year, targetDate.month);
    }
    reminder.text = text.trim();
    reminder.time = time?.trim().isEmpty ?? true ? null : time?.trim();
    reminder.endTime = endTime?.trim().isEmpty ?? true ? null : endTime?.trim();
    reminder.repeat = repeat ?? reminder.repeat;
    reminder.alertMinutesBefore =
        alertMinutesBefore ?? reminder.alertMinutesBefore;
    reminder.active = active ?? reminder.active;
    route = AuraRoute.moreCalendar;
    notifyListeners();
  }

  void deleteReminder(DateTime date, String id) {
    final key = _dateOnly(date);
    reminders[key]?.removeWhere((reminder) => reminder.id == id);
    if (reminders[key]?.isEmpty ?? false) {
      reminders.remove(key);
    }
    if (selectedReminder?.id == id) {
      selectedReminder = null;
      selectedReminderDate = null;
    }
    route = AuraRoute.moreCalendar;
    notifyListeners();
  }

  void setLanguage(String value) {
    lang = value;
    AuraStorageService.saveLanguage(value);
    notifyListeners();
  }

  void setThemeMode(String value) {
    themeMode = value;
    notifyListeners();
  }

  void setAppBrightness(double value) {
    appBrightness = value.clamp(0, 1).toDouble();
    AuraStorageService.saveAppBrightness(appBrightness);
    notifyListeners();
  }

  void setDeviceBrightness(double value) {
    deviceBrightness = value.clamp(0, 1).toDouble();
    AuraStorageService.saveDeviceBrightness(deviceBrightness);
    unawaited(
      sendEsp32Command({
        'cmd': 'brightness',
        'value': (deviceBrightness * 100).round(),
      }),
    );
    notifyListeners();
  }

  void setAdaptiveBrightness(bool value) {
    adaptiveBrightness = value;
    AuraStorageService.saveAdaptiveBrightness(value);
    notifyListeners();
  }

  void setDoNotDisturb(bool value) {
    doNotDisturb = value;
    AuraStorageService.saveDoNotDisturb(value);
    notifyListeners();
  }

  void setNotificationDelivery(bool value) {
    notificationDelivery = value;
    notifyListeners();
  }

  void updatePermissions({
    bool? microphone,
    bool? camera,
    bool? contacts,
    bool? notifications,
    bool? callPhone,
    bool? sms,
    bool? callLog,
  }) {
    microphonePermission = microphone ?? microphonePermission;
    cameraPermission = camera ?? cameraPermission;
    contactsPermission = contacts ?? contactsPermission;
    notificationsPermission = notifications ?? notificationsPermission;
    callPhonePermission = callPhone ?? callPhonePermission;
    smsPermission = sms ?? smsPermission;
    callLogPermission = callLog ?? callLogPermission;
    notifyListeners();
  }

  Future<void> requestTelephonyPermissions() async {
    final result = await AuraPlatformService.requestTelephonyPermissions();
    updatePermissions(
      callPhone: result['callPhone'],
      sms: (result['sendSms'] == true || result['readSms'] == true),
      callLog: result['readCallLog'],
    );
  }

  void setRingtone(String value) {
    ringtone = value;
    AuraStorageService.saveRingtone(value);
    notifyListeners();
  }

  void _appendEsp32Log(String message) {
    final now = DateTime.now();
    final stamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    esp32BleLog.insert(0, '[$stamp] $message');
    if (esp32BleLog.length > 40) {
      esp32BleLog.removeRange(40, esp32BleLog.length);
    }
    _handleEcoMindMessage(message);
    notifyListeners();
  }

  void _handleEcoMindMessage(String message) {
    final jsonStart = message.indexOf('{');
    if (jsonStart < 0) return;
    try {
      final decoded = jsonDecode(message.substring(jsonStart));
      if (decoded is! Map) return;
      final payload = decoded.cast<String, dynamic>();
      final type = (payload['type'] ?? payload['event'] ?? '').toString();

      if (type == 'wifi_scan_result') {
        final networks = payload['networks'];
        if (networks is! List) return;
        final mapped = <String, AuraNetworkItem>{};
        for (final entry in networks) {
          if (entry is! Map) continue;
          final data = entry.cast<String, dynamic>();
          final ssid = (data['ssid'] ?? data['name'] ?? '').toString().trim();
          if (ssid.isEmpty) continue;
          final key = ssid.toLowerCase();
          final rssi = data['rssi'];
          final wasConnected = wifiNetworks.any(
            (network) =>
                network.name.trim().toLowerCase() == key && network.connected,
          );
          mapped[key] = AuraNetworkItem(
            id: 'ecomind-wifi-${_stableNetworkId(ssid)}',
            name: ssid,
            type: 'Wi-Fi',
            signal: rssi == null ? 'EcoMind' : '$rssi dBm',
            available: true,
            connected: wasConnected,
          );
        }
        if (mapped.isNotEmpty) {
          wifiNetworks
            ..clear()
            ..addAll(mapped.values);
          esp32BleStatus = 'Encontrou ${mapped.length} rede(s) pela EcoMind';
        }
        return;
      }

      if (type == 'wifi_connect_result' ||
          type == 'wifi_connected' ||
          type == 'wifi_connect') {
        final result = payload['result'];
        final resultMap = result is Map
            ? result.cast<String, dynamic>()
            : <String, dynamic>{};
        final ssid =
            (payload['ssid'] ?? resultMap['ssid'] ?? _pendingEcoMindWifiSsid)
                .toString()
                .trim();
        final ip =
            (payload['ip'] ??
                    resultMap['ip'] ??
                    resultMap['local_ip'] ??
                    resultMap['address'] ??
                    '')
                .toString()
                .trim();
        final connected =
            payload['success'] == true ||
            payload['connected'] == true ||
            resultMap['success'] == true ||
            resultMap['connected'] == true ||
            type == 'wifi_connected' ||
            ip.isNotEmpty;
        if (connected) {
          _markEcoMindWifiConnected(ssid);
          esp32BleStatus = ip.isEmpty
              ? 'EcoMind conectada ao Wi-Fi'
              : 'EcoMind conectada ao Wi-Fi ($ip)';
        } else {
          esp32BleStatus = 'Falha no Wi-Fi da EcoMind';
        }
        return;
      }

      if (type == 'backend_health_result') {
        final success =
            payload['success'] == true ||
            payload['ok'] == true ||
            payload['status'] == 'ok';
        final message =
            (payload['message'] ?? payload['status'] ?? payload['error'] ?? '')
                .toString()
                .trim();
        esp32BleStatus = success
            ? 'Backend acessivel pela EcoMind'
            : message == 'wifi_not_connected'
            ? 'Conecte a EcoMind ao Wi-Fi antes de testar o backend'
            : 'Backend indisponivel pela EcoMind';
        addActivity(
          text: esp32BleStatus,
          origin: 'EcoMind',
          details: message.isEmpty ? jsonEncode(payload) : message,
        );
        return;
      }

      if (type == 'speak_request') {
        final text =
            (payload['text'] ?? payload['message'] ?? payload['response'] ?? '')
                .toString()
                .trim();
        esp32BleStatus = 'EcoMind recebeu pedido de fala';
        addActivity(
          text: 'Pedido de fala enviado a EcoMind',
          origin: 'EcoMind',
          details: text.isEmpty ? jsonEncode(payload) : text,
        );
        return;
      }

      if (type == 'status') {
        final wifi = payload['wifi'];
        if (wifi is Map && wifi['connected'] == true) {
          final ip = (wifi['ip'] ?? wifi['local_ip'] ?? '').toString().trim();
          esp32BleStatus = ip.isEmpty
              ? 'EcoMind conectada ao Wi-Fi'
              : 'EcoMind conectada ao Wi-Fi ($ip)';
        }
      }
    } catch (_) {
      // BLE log stays visible; malformed or partial JSON is only ignored here.
    }
  }

  void _markEcoMindWifiConnected(String ssid) {
    final cleanSsid = ssid.trim();
    if (cleanSsid.isEmpty) return;
    final key = cleanSsid.toLowerCase();
    var found = false;
    for (final network in wifiNetworks) {
      final matches = network.name.trim().toLowerCase() == key;
      network.connected = matches;
      found = found || matches;
    }
    if (!found) {
      wifiNetworks.insert(
        0,
        AuraNetworkItem(
          id: 'ecomind-wifi-${_stableNetworkId(cleanSsid)}',
          name: cleanSsid,
          type: 'Wi-Fi',
          signal: 'EcoMind conectada',
          available: true,
          connected: true,
        ),
      );
    }
  }

  String _stableNetworkId(String value) {
    final cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : cleaned;
  }

  void clearEsp32BleLog() {
    esp32BleLog.clear();
    notifyListeners();
  }

  void connectNetwork(AuraNetworkItem item) {
    final collection = switch (item.type) {
      'Wi-Fi' => wifiNetworks,
      'Bluetooth' => bluetoothDevices,
      _ => zigbeeHubs,
    };
    for (final network in collection) {
      network.connected = network.id == item.id;
    }
    if (item.type == 'Bluetooth') {
      _selectedBleDeviceId = item.id;
    }
    addActivity(
      text: '${item.name} conectado',
      device: item.name,
      origin: item.type,
      details: 'Estado de conexao salvo como conectado no app.',
    );
    notifyListeners();
  }

  Future<void> scanEsp32Bluetooth() async {
    esp32BleBusy = true;
    esp32BleStatus = 'Procurando sua EcoMind...';
    _appendEsp32Log('Procurando sua EcoMind por BLE');
    try {
      final found = await _bleService.scanEsp32Devices();
      if (found.isEmpty) {
        esp32BleStatus = 'Nenhuma EcoMind encontrada';
        _appendEsp32Log('Nenhuma EcoMind encontrada no scan BLE');
        return;
      }
      bluetoothDevices
        ..clear()
        ..addAll(found);
      esp32BleStatus = 'Encontrou sua EcoMind';
      _appendEsp32Log(
        'Encontrado: ${found.map((item) => item.name).join(', ')}',
      );
    } catch (error) {
      esp32BleStatus = 'Falha no scan BLE';
      _appendEsp32Log('Scan error: $error');
    } finally {
      esp32BleBusy = false;
      notifyListeners();
    }
  }

  Future<String> connectEsp32(AuraNetworkItem item) async {
    if (!item.available) return 'unavailable';
    esp32BleBusy = true;
    esp32BleStatus = 'Conectando em ${item.name}...';
    _appendEsp32Log('Connecting to ${item.name}');
    try {
      final connected = await _bleService.connect(item.id);
      if (connected) {
        _selectedBleDeviceId = item.id;
        for (final network in bluetoothDevices) {
          network.connected = network.id == item.id;
        }
        esp32BleStatus = 'EcoMind conectada (MTU ${_bleService.mtu})';
        addActivity(
          text: '${item.name} conectado',
          device: item.name,
          origin: item.type,
          details: 'Conectado via Nordic UART BLE.',
        );
        return 'connected';
      }
      esp32BleStatus = 'Nordic UART nao encontrado';
      _appendEsp32Log('Nordic UART service/characteristics missing');
      return 'failed';
    } catch (error) {
      esp32BleStatus = 'Falha ao conectar';
      _appendEsp32Log('Connect error: $error');
      return 'failed';
    } finally {
      esp32BleBusy = false;
      notifyListeners();
    }
  }

  Future<String> provisionWifiToEsp32({
    required String ssid,
    required String password,
  }) async {
    if (_selectedBleDeviceId.isEmpty) {
      return 'Selecione sua EcoMind via Bluetooth.';
    }
    if (ssid.trim().isEmpty) return 'Informe o nome da rede Wi-Fi.';
    if (password.trim().isEmpty) return 'Informe a senha da rede.';
    _pendingEcoMindWifiSsid = ssid.trim();
    final status = await sendEsp32Command({
      'cmd': 'wifi_connect',
      'ssid': ssid.trim(),
      'password': password,
    });
    addNotification(
      title: 'Wi-Fi da EcoMind',
      body: status == 'sent'
          ? 'Credenciais enviadas. Aguarde o retorno da EcoMind.'
          : status,
      device: _selectedBleDeviceId,
      origin: 'EcoMind',
    );
    addActivity(
      text: 'Wi-Fi enviado a EcoMind',
      device: _selectedBleDeviceId,
      origin: 'EcoMind',
      details: 'Rede $ssid enviada por BLE. Resultado: $status.',
    );
    return status == 'sent'
        ? 'Enviado para a EcoMind. Aguarde o retorno no log BLE.'
        : status;
  }

  Future<String> scanEcoMindWifiNetworks() async {
    final status = await sendEsp32Command({'cmd': 'wifi_scan'});
    return status == 'sent' ? 'Solicitei o scan Wi-Fi para a EcoMind.' : status;
  }

  Future<String> sendEsp32Command(Map<String, Object?> command) async {
    if (_selectedBleDeviceId.isEmpty) {
      return 'Selecione sua EcoMind via Bluetooth.';
    }
    esp32BleBusy = true;
    try {
      final cmd = command['cmd']?.toString();
      if (cmd == 'wifi_scan' || cmd == 'wifi_connect') {
        await _syncEcoMindState('wifi');
      } else if (cmd == 'backend_health') {
        await _syncEcoMindState('backend');
      } else if (cmd == 'speak') {
        await _syncEcoMindState('speaking');
      } else {
        await _syncEcoMindState('processing');
      }
      final result = await _bleService.sendJson(command);
      if (result == 'not_connected') {
        esp32BleStatus = 'EcoMind desconectada';
        return 'EcoMind desconectada.';
      }
      esp32BleStatus = 'Comando enviado';
      return 'sent';
    } catch (error) {
      esp32BleStatus = 'Falha ao enviar comando';
      _appendEsp32Log('Send error: $error');
      if (error.toString().contains('payload_too_large')) {
        return 'Comando grande demais para o Bluetooth atual. Reconecte a EcoMind e tente de novo.';
      }
      return 'Falha ao enviar: $error';
    } finally {
      esp32BleBusy = false;
      notifyListeners();
    }
  }

  Future<void> refreshNearbyNetworks(String type) async {
    final stamp = DateTime.now().second;
    if (type == 'Wi-Fi') {
      final results = await AuraPlatformService.scanWifiNetworks();
      if (results.isNotEmpty) {
        wifiNetworks
          ..clear()
          ..addAll(results);
        notifyListeners();
        return;
      }
    } else if (type == 'Bluetooth') {
      final results = await AuraPlatformService.scanBluetoothDevices();
      final esp32 = await _bleService.scanEsp32Devices();
      final merged = <String, AuraNetworkItem>{};
      for (final item in [...results, ...esp32]) {
        merged[item.id] = item;
      }
      if (merged.isNotEmpty) {
        bluetoothDevices
          ..clear()
          ..addAll(merged.values);
        notifyListeners();
        return;
      }
    }
    if (type == 'Wi-Fi') {
      wifiNetworks
        ..clear()
        ..addAll([
          AuraNetworkItem(
            id: 'wifi-home-$stamp',
            name: 'Rede próxima 5G',
            type: 'Wi-Fi',
            signal: 'Forte',
            available: true,
          ),
          AuraNetworkItem(
            id: 'wifi-iot-$stamp',
            name: 'Casa Inteligente IoT',
            type: 'Wi-Fi',
            signal: 'Médio',
            available: true,
          ),
          AuraNetworkItem(
            id: 'wifi-manual',
            name: 'Adicionar rede manualmente',
            type: 'Wi-Fi',
            signal: 'Fallback web/iOS',
            available: true,
          ),
        ]);
    } else if (type == 'Bluetooth') {
      bluetoothDevices
        ..clear()
        ..addAll([
          AuraNetworkItem(
            id: 'bt-speaker-$stamp',
            name: 'Caixa Bluetooth próxima',
            type: 'Bluetooth',
            signal: 'Perto',
            available: true,
          ),
          AuraNetworkItem(
            id: 'bt-tv-$stamp',
            name: 'TV detectável',
            type: 'Bluetooth',
            signal: 'Pareamento disponível',
            available: true,
          ),
          AuraNetworkItem(
            id: 'bt-manual',
            name: 'Parear dispositivo manualmente',
            type: 'Bluetooth',
            signal: 'Fallback quando o scan real não estiver disponível',
            available: true,
          ),
        ]);
    }
    notifyListeners();
  }

  Future<void> setWorldClock(String id) async {
    selectedWorldClockId = id;
    final clock = selectedWorldClock;
    location = clock.city;
    _updateGreeting();
    notifyListeners();
    final weather = await AuraPlatformService.readWeatherForCoordinates(
      latitude: clock.latitude,
      longitude: clock.longitude,
      locationName: clock.city,
    );
    if (weather != null) {
      _applyWeather(weather);
    }
    addActivity(
      text: 'Relogio global alterado',
      origin: 'Relogio',
      details: 'Cidade selecionada: ${clock.label}.',
    );
    unawaited(_persistUserState());
    notifyListeners();
  }

  Future<String?> addAccount(
    String name,
    String email,
    String role, {
    bool? canManageDevices,
    bool? canManageMembers,
    bool? canUseVoice,
    bool? canUseMedia,
    bool? canViewHistory,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty) return null;
    final normalizedEmail = email.trim().toLowerCase();
    final duplicate = accounts.any((account) {
      return account.email.trim().toLowerCase() == normalizedEmail ||
          account.name.trim().toLowerCase() == name.trim().toLowerCase();
    });
    if (duplicate) {
      addNotification(
        title: 'Membro duplicado',
        body: 'Ja existe uma conta com esse nome ou e-mail.',
        origin: 'Membros',
      );
      return null;
    }
    final defaultGroup = await _groupsRepository?.ensureDefaultGroup(
      userId: _activeUserId,
    );
    if (defaultGroup != null &&
        groups.where((group) => group.id == defaultGroup.id).isEmpty) {
      groups.insert(0, defaultGroup);
    }
    final permissions = _rolePermissions(role);
    final memberId = DateTime.now().millisecondsSinceEpoch.toString();
    final inviteCode = 'account-${memberId.substring(memberId.length - 6)}';
    final inviteUrl =
        _groupsRepository?.buildInviteUrl(
          inviteCode: defaultGroup?.inviteCode ?? inviteCode,
          email: normalizedEmail,
          groupId: defaultGroup?.id ?? '',
        ) ??
        '${AppConfig.webRedirectUrl}?invite=$memberId&email=${Uri.encodeComponent(normalizedEmail)}';
    accounts.add(
      AuraAccount(
        id: memberId,
        name: name.trim(),
        email: normalizedEmail,
        role: role.trim().isEmpty ? 'Membro' : role.trim(),
        canManageDevices: canManageDevices ?? permissions.canManageDevices,
        canManageMembers: canManageMembers ?? permissions.canManageMembers,
        canUseVoice: canUseVoice ?? permissions.canUseVoice,
        canUseMedia: canUseMedia ?? permissions.canUseMedia,
        canViewHistory: canViewHistory ?? permissions.canViewHistory,
        groupId: defaultGroup?.id ?? '',
      ),
    );
    unawaited(
      _groupsRepository?.createInvite(
            userId: _activeUserId,
            email: normalizedEmail,
            role: role,
            inviteUrl: inviteUrl,
            groupId: defaultGroup?.id ?? '',
            inviteCode: defaultGroup?.inviteCode ?? inviteCode,
            payload: {
              'name': name.trim(),
              'group_id': defaultGroup?.id ?? '',
              'permissions': {
                'can_manage_devices':
                    canManageDevices ?? permissions.canManageDevices,
                'can_manage_members':
                    canManageMembers ?? permissions.canManageMembers,
                'can_use_voice': canUseVoice ?? permissions.canUseVoice,
                'can_use_media': canUseMedia ?? permissions.canUseMedia,
                'can_view_history':
                    canViewHistory ?? permissions.canViewHistory,
              },
            },
          ) ??
          Future<void>.value(),
    );
    addActivity(
      text: 'Convite enviado para ${name.trim()}',
      origin: 'Membros',
      details: 'Cargo: $role. Link: $inviteUrl',
    );
    route = AuraRoute.moreConfigAccounts;
    notifyListeners();
    return inviteUrl;
  }

  void updateAccount(
    String id, {
    String? name,
    String? email,
    String? role,
    bool? canManage,
    bool? notificationsEnabled,
    bool? canManageMembers,
    bool? canUseVoice,
    bool? canUseMedia,
    bool? canViewHistory,
  }) {
    final account = accounts.where((item) => item.id == id).firstOrNull;
    if (account == null) return;
    if (name != null && name.trim().isNotEmpty) account.name = name.trim();
    if (email != null) account.email = email.trim();
    if (role != null && role.trim().isNotEmpty) account.role = role.trim();
    if (canManage != null) account.canManageDevices = canManage;
    if (notificationsEnabled != null) {
      account.notificationsEnabled = notificationsEnabled;
    }
    if (canManageMembers != null) {
      account.canManageMembers = canManageMembers;
    }
    if (canUseVoice != null) account.canUseVoice = canUseVoice;
    if (canUseMedia != null) account.canUseMedia = canUseMedia;
    if (canViewHistory != null) account.canViewHistory = canViewHistory;
    if (id == _activeUserId) {
      unawaited(
        _userRepository.saveProfile(
          userId: id,
          name: account.name,
          email: account.email,
          avatarUrl: account.imageAsset,
          avatarPath: account.imagePath,
        ),
      );
    }
    unawaited(_persistUserState());
    notifyListeners();
  }

  Future<void> updateAccountPhoto(String id) async {
    final account = accounts.where((item) => item.id == id).firstOrNull;
    if (account == null) return;
    final image = await AuraPlatformService.pickProfileImage();
    if (image == null) return;
    final uploaded = id == _activeUserId
        ? await _userRepository.uploadProfilePhoto(userId: id, file: image)
        : await _userRepository.uploadManagedPhoto(
            ownerId: _activeUserId,
            targetId: id,
            file: image,
          );
    account.imageAsset = uploaded?.url ?? image.path;
    account.imagePath = uploaded?.path;
    if (id == _activeUserId) {
      unawaited(
        _userRepository.saveProfile(
          userId: id,
          name: account.name,
          email: account.email,
          avatarUrl: account.imageAsset,
          avatarPath: account.imagePath,
        ),
      );
    }
    unawaited(_persistUserState());
    notifyListeners();
  }

  Future<void> updateContactPhoto(String id) async {
    final contact = contacts.where((item) => item.id == id).firstOrNull;
    if (contact == null) return;
    final image = await AuraPlatformService.pickProfileImage();
    if (image == null) return;
    final upload = await _userRepository.uploadManagedPhoto(
      ownerId: _activeUserId,
      targetId: id,
      file: image,
    );
    contact.imageAsset = upload?.url ?? image.path;
    unawaited(
      _contactsRepository?.save(_activeUserId, contacts) ??
          Future<void>.value(),
    );
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    if (id == _activeUserId) return;
    accounts.removeWhere((account) => account.id == id);
    if (selectedAccountId == id) {
      selectedAccountId = '';
      route = AuraRoute.moreConfigAccounts;
    }
    await _appDataRepository?.deleteAccount(_activeUserId, id);
    notifyListeners();
  }

  void openAccountSettings(String id) {
    if (accounts.where((account) => account.id == id).isEmpty) return;
    selectedAccountId = id;
    route = AuraRoute.moreConfigAccountSettings;
    notifyListeners();
  }

  AuraRolePermissions _rolePermissions(String role) {
    return switch (role) {
      'Administrador' => const AuraRolePermissions(
        canManageDevices: true,
        canManageMembers: true,
        canUseVoice: true,
        canUseMedia: true,
        canViewHistory: true,
      ),
      'Convidado' => const AuraRolePermissions(
        canManageDevices: false,
        canManageMembers: false,
        canUseVoice: false,
        canUseMedia: true,
        canViewHistory: false,
      ),
      _ => const AuraRolePermissions(
        canManageDevices: true,
        canManageMembers: false,
        canUseVoice: true,
        canUseMedia: true,
        canViewHistory: false,
      ),
    };
  }

  void setListMode(String value) {
    listMode = value;
    notifyListeners();
  }

  void setAlarmMode(String value) {
    alarmMode = value;
    notifyListeners();
  }

  void toggleSkill(String id) {
    final skill = skills.where((s) => s.id == id).firstOrNull;
    if (skill == null) return;
    skill.permission = !skill.permission;
    notifyListeners();
  }

  void openSkillLogin(String id) {
    final skill = skills.where((s) => s.id == id).firstOrNull;
    activeSkill = skill?.title ?? id;
    route = AuraRoute.skillLogin;
    notifyListeners();
  }

  AuraSkill? get activeSkillItem =>
      skills.where((skill) => skill.title == activeSkill).firstOrNull;

  void markActiveSkillConnected() {
    final skill = activeSkillItem;
    if (skill == null) return;
    skill.permission = true;
    notifyListeners();
  }

  Future<void> connectActiveSkill() async {
    final skill = activeSkillItem;
    if (skill == null) return;

    String target = skill.connectUrl;
    if (skill.id == 'spotify') {
      final alreadyConnected = await _musicRepository?.spotifyAuthenticated();
      if (alreadyConnected == true) {
        markActiveSkillConnected();
        return;
      }
      final backendUrl = await _musicRepository?.spotifyLoginUrl();
      if (backendUrl != null && backendUrl.isNotEmpty) {
        target = backendUrl;
      }
    }

    if (target.isNotEmpty) {
      await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    }
    if (skill.id != 'spotify') {
      markActiveSkillConnected();
    } else {
      addNotification(
        title: 'Spotify aberto',
        body: 'Conclua o login e volte para a Aura para confirmar a conexao.',
        origin: 'Skills',
      );
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    if (uri.scheme != 'auramind') return;
    if (uri.host == 'spotify-connected') {
      final spotify = skills
          .where((skill) => skill.id == 'spotify')
          .firstOrNull;
      if (spotify != null) spotify.permission = true;
      addNotification(
        title: 'Spotify conectado',
        body: 'A integracao foi confirmada pelo backend.',
        origin: 'Skills',
      );
      notifyListeners();
      return;
    }
    if (uri.host == 'invite') {
      final email = uri.queryParameters['email'] ?? currentAccount?.email ?? '';
      await _groupsRepository?.acceptPendingInvites(
        userId: _activeUserId,
        email: email,
        name: currentAccount?.name ?? '',
      );
      if (_activeUserId.isNotEmpty) {
        final loadedGroups = await _groupsRepository?.loadGroups(_activeUserId);
        if (loadedGroups != null) {
          groups
            ..clear()
            ..addAll(loadedGroups);
        }
      }
      addNotification(
        title: 'Convite recebido',
        body: 'O convite foi processado para esta conta.',
        origin: 'Convites',
      );
      notifyListeners();
    }
  }

  Future<void> dialPhoneNumber(String rawNumber) async {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    final nativePlaced = await AuraPlatformService.placeCall(digits);
    if (nativePlaced) return;
    final uri = Uri.parse('tel:$digits');
    if (!await canLaunchUrl(uri)) {
      addNotification(
        title: 'Ligacao indisponivel',
        body: 'Nao foi possivel abrir o discador neste dispositivo.',
        origin: 'Telefone',
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> importNativeSmsForSelectedContact() async {
    final contact = selectedContact;
    final userId = _activeUserId;
    if (contact == null || userId.isEmpty || contact.phone.trim().isEmpty) {
      return;
    }
    final nativeMessages = await AuraPlatformService.loadSmsThread(
      contact.phone,
    );
    if (nativeMessages.isEmpty) return;
    final key = _conversationKey(contactId: contact.id);
    final existing = _messageCache.putIfAbsent(key, () => []);
    final seen = existing.map((message) => message.id).toSet();
    for (final native in nativeMessages) {
      final id = 'sms:${native.id}';
      if (!seen.add(id)) continue;
      existing.add(
        AuraMessage(
          id: id,
          userId: userId,
          body: native.body,
          direction: native.direction,
          createdAt: native.createdAt,
          contactId: contact.id,
          status: 'sms_imported',
        ),
      );
    }
    existing.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  Future<void> importNativeCallLogForSelectedContact() async {
    final contact = selectedContact;
    if (contact == null || contact.phone.trim().isEmpty) return;
    final calls = await AuraPlatformService.loadCallLog(contact.phone);
    if (calls.isEmpty) return;
    for (final call in calls.take(5)) {
      addActivity(
        text: 'Ligacao ${call.type}',
        device: contact.name,
        origin: 'Telefone',
        details:
            '${contact.phone} em ${call.createdAt.toIso8601String()} por ${call.durationSeconds}s',
      );
    }
  }

  Future<void> playMusicFromPrompt(String prompt) async {
    await _ensureDependencies();
    if (prompt.trim().isEmpty) return;
    _setAuraLightState(AuraLightState.processing);
    musicErrorMessage = '';
    notifyListeners();
    final result = await _musicRepository?.play(
      _storageUserId,
      prompt.trim(),
      musicContext: _musicClientContext(),
    );
    final data = result?.data;
    if (data == null) {
      final message = result?.errorMessage.trim().isNotEmpty == true
          ? result!.errorMessage
          : 'Nao foi possivel iniciar a reproducao agora.';
      _setMusicError(message);
      _setAuraLightState(
        AuraLightState.error,
        autoResetAfter: const Duration(seconds: 4),
      );
      return;
    }

    currentMedia = _mediaFromPlaybackData(data);
    musicErrorMessage = '';
    route = AuraRoute.play;
    unawaited(_startCurrentMediaPlayback());
    _setAuraLightState(
      AuraLightState.success,
      autoResetAfter: const Duration(seconds: 4),
    );
    notifyListeners();
  }

  AuraMedia _mediaFromPlaybackData(MusicPlaybackData data) {
    return AuraMedia(
      id: data.id,
      title: data.title,
      artist: data.artist,
      source: data.source,
      audioUrl: data.audioUrl,
      imageUrl: data.thumbnailUrl,
      isPlaying: true,
      videoId: data.videoId,
      youtubeUrl: data.youtubeUrl,
      spotifyUrl: data.spotifyUrl,
      duration: data.duration,
      position: data.position,
    );
  }

  Map<String, dynamic> _musicClientContext() {
    final active = currentMedia.hasAnyMedia;
    return {
      'active': active,
      'is_playing': active && currentMedia.isPlaying,
      'has_previous': recentlyPlayed.length > 1,
      'video_id': currentMedia.videoId,
      'audio_url': currentMedia.audioUrl,
      'title': currentMedia.title,
      'artist': currentMedia.artist,
      'search_query': [
        currentMedia.title,
        currentMedia.artist,
      ].where((value) => value.trim().isNotEmpty).join(' '),
    };
  }

  Future<void> _applyMusicPayload(Map<dynamic, dynamic> music) async {
    final action = MusicRepository.actionFromPayload(music);
    if (action == 'stop') {
      await stopMusicPlayback();
      return;
    }
    if (action == 'next') {
      await playNextMusic();
      return;
    }
    if (action == 'previous') {
      await playPreviousMusic();
      return;
    }

    final data = MusicPlaybackData.fromJson({
      ...music.cast<String, dynamic>(),
      'is_playing': true,
    });
    if (data.audioUrl.trim().isEmpty &&
        data.videoId.trim().isEmpty &&
        data.youtubeUrl.trim().isEmpty) {
      _setMusicError(
        'A Aura encontrou uma midia, mas ela nao veio com link tocavel.',
      );
      return;
    }

    currentMedia = _mediaFromPlaybackData(data);
    _rememberRecentMedia(currentMedia);
    musicErrorMessage = '';
    unawaited(_startCurrentMediaPlayback());
  }

  void _rememberRecentMedia(AuraMedia media) {
    if (!media.hasAnyMedia && media.title.trim().isEmpty) return;
    final key = media.id.trim().isNotEmpty
        ? media.id.trim()
        : '${media.title}|${media.artist}|${media.audioUrl}|${media.videoId}';
    recentlyPlayed.removeWhere((item) {
      final itemKey = item.id.trim().isNotEmpty
          ? item.id.trim()
          : '${item.title}|${item.artist}|${item.audioUrl}|${item.videoId}';
      return itemKey == key;
    });
    recentlyPlayed.insert(
      0,
      AuraMedia(
        id: media.id,
        title: media.title,
        artist: media.artist,
        source: media.source,
        audioUrl: media.audioUrl,
        imageUrl: media.imageUrl,
        isPlaying: false,
        videoId: media.videoId,
        youtubeUrl: media.youtubeUrl,
        spotifyUrl: media.spotifyUrl,
        duration: media.duration,
        position: Duration.zero,
      ),
    );
    if (recentlyPlayed.length > 12) {
      recentlyPlayed.removeRange(12, recentlyPlayed.length);
    }
  }

  Future<void> _startCurrentMediaPlayback() async {
    if (currentMedia.videoId.trim().isNotEmpty) {
      await _musicPlayer.stop();
      currentMedia.isPlaying = true;
      musicErrorMessage = '';
      _rememberRecentMedia(currentMedia);
      notifyListeners();
      return;
    }
    if (currentMedia.audioUrl.trim().isEmpty) {
      currentMedia.isPlaying = false;
      if (currentMedia.hasPlayableVideo) {
        musicErrorMessage = '';
        addNotification(
          title: 'Música disponível no YouTube',
          body:
              'Abra no YouTube ou ajuste o backend para retornar audio_url para tocar dentro do app.',
          origin: 'Mídia',
        );
      } else {
        _setMusicError('O backend nao retornou uma midia tocavel.');
      }
      notifyListeners();
      return;
    }

    try {
      await _musicPlayer.play(currentMedia);
      currentMedia.isPlaying = true;
      musicErrorMessage = '';
      _rememberRecentMedia(currentMedia);
      notifyListeners();
    } catch (error) {
      currentMedia.isPlaying = false;
      _setMusicError('Nao consegui tocar o audio no player nativo: $error');
    }
  }

  void markMusicPlaybackError(String message) {
    _setMusicError(message);
    _setAuraLightState(
      AuraLightState.error,
      autoResetAfter: const Duration(seconds: 4),
    );
  }

  void clearMusicError() {
    if (musicErrorMessage.isEmpty) return;
    musicErrorMessage = '';
    notifyListeners();
  }

  void _setMusicError(String message) {
    final cleanMessage = message.trim().isEmpty
        ? 'Nao consegui tocar essa musica agora.'
        : message.trim();
    musicErrorMessage = cleanMessage;
    addNotification(
      title: 'Musica indisponivel',
      body: cleanMessage,
      origin: 'Musica',
    );
    addActivity(
      text: 'Musica indisponivel',
      origin: 'Musica',
      details: cleanMessage,
    );
    notifyListeners();
  }

  List<Map<String, String>> _auraHistoryPayload(List<AuraMessage> messages) {
    return messages
        .where((message) => message.body.trim().isNotEmpty)
        .toList()
        .reversed
        .take(12)
        .toList()
        .reversed
        .map(
          (message) => {
            'role': message.direction == 'incoming' ? 'assistant' : 'user',
            'text': message.body,
          },
        )
        .toList();
  }

  Future<String> askAura(
    String text, {
    String? imageName,
    List<AuraMessage>? history,
  }) async {
    await _ensureDependencies();
    final cleanText = text.trim();
    if (cleanText.isEmpty && (imageName ?? '').trim().isEmpty) return '';
    final api = _apiClient;
    if (api == null) {
      return 'A conexao com a Aura ainda nao esta pronta.';
    }

    try {
      _setAuraLightState(AuraLightState.processing);
      final now = DateTime.now();
      final response = await api.post(
        '/api/chat',
        body: {
          'message': imageName == null || imageName.trim().isEmpty
              ? cleanText
              : '$cleanText\nImagem anexada: $imageName',
          'locale': lang,
          'history': _auraHistoryPayload(history ?? auraConversationMessages),
          'client_context': {
            'user_id': _storageUserId,
            'locale': lang,
            'location': location,
            'timezone': now.timeZoneName,
            'local_time_iso': now.toIso8601String(),
            'local_time_24h':
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            'temperature': currentTemp,
            'weather': {
              'location': location,
              'temperature_c': currentTemp,
              'condition': weatherCondition,
              'precipitation_mm': precipitationMm,
              'humidity': humidity,
              'wind_speed_kmh': windSpeedKmh,
              'latitude': weatherLatitude,
              'longitude': weatherLongitude,
              'summary':
                  '$weatherCondition, $currentTemp C em $location, chuva ${precipitationMm.toStringAsFixed(1)} mm, umidade $humidity%, vento ${windSpeedKmh.toStringAsFixed(1)} km/h.',
              'source': 'flutter_app',
            },
            'music': _musicClientContext(),
            'devices': devices
                .map(
                  (device) => {
                    'id': device.id,
                    'name': device.name,
                    'room': device.room,
                    'type': device.type.name,
                    'status': device.status,
                    'active': device.active,
                  },
                )
                .toList(),
          },
        },
        auth: false,
      );
      final payload = response is Map<String, dynamic>
          ? response
          : <String, dynamic>{};
      final music = payload['music'];
      if (music is Map) {
        await _applyMusicPayload(music);
      }
      final reply =
          (payload['response'] ?? payload['message'] ?? payload['text'] ?? '')
              .toString()
              .trim();
      addActivity(text: 'Conversa com Aura', origin: 'IA', details: cleanText);
      if (reply.isNotEmpty) {
        _setAuraLightState(AuraLightState.responding);
        if (!doNotDisturb) {
          unawaited(_playAuraTts(reply));
        }
      }
      return reply.isEmpty
          ? 'A Aura processou sua mensagem, mas nao retornou texto.'
          : reply;
    } catch (error) {
      final message = error is AppError
          ? error.message
          : 'Nao consegui falar com o backend da Aura agora.';
      _setAuraLightState(
        AuraLightState.error,
        autoResetAfter: const Duration(seconds: 4),
      );
      return message.trim().isEmpty
          ? 'Nao consegui falar com o backend da Aura agora.'
          : message;
    }
  }

  Future<void> _playAuraTts(String text) async {
    await _ensureDependencies();
    final api = _apiClient;
    if (api == null || text.trim().isEmpty) return;
    try {
      final bytes = await api.postBytes(
        '/api/tts',
        body: {'text': text, 'locale': lang, 'provider': 'gemini'},
        auth: false,
      );
      await AuraPlatformService.playVoiceBytes(bytes);
    } catch (error) {
      final message = error is AppError
          ? 'Nao consegui tocar a resposta em voz: ${error.message}'
          : 'Nao consegui tocar a resposta em voz agora.';
      addActivity(text: 'TTS indisponivel', origin: 'Voz', details: message);
      // Spoken replies are a progressive enhancement; chat text remains.
    }
  }

  Future<void> stopMusicPlayback() async {
    await _musicRepository?.stop(_storageUserId);
    await _musicPlayer.stop();
    currentMedia.isPlaying = false;
    currentMedia.position = Duration.zero;
    notifyListeners();
  }

  Future<void> pauseMusicPlayback() async {
    await _musicPlayer.pause();
    currentMedia.isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeMusicPlayback() async {
    if (currentMedia.videoId.trim().isNotEmpty) {
      currentMedia.isPlaying = true;
      musicErrorMessage = '';
      notifyListeners();
      return;
    }
    if (currentMedia.audioUrl.trim().isEmpty) {
      await _startCurrentMediaPlayback();
      return;
    }
    await _musicPlayer.play(currentMedia);
    currentMedia.isPlaying = true;
    notifyListeners();
  }

  Future<void> seekMusic(Duration position) async {
    if (currentMedia.videoId.trim().isEmpty) {
      await _musicPlayer.seek(position);
    }
    currentMedia.position = position;
    notifyListeners();
  }

  void syncExternalMusicPlayback({
    required bool playing,
    Duration? position,
    Duration? duration,
    String? error,
  }) {
    currentMedia.isPlaying = playing;
    if (position != null) currentMedia.position = position;
    if (duration != null && duration > Duration.zero) {
      currentMedia.duration = duration;
    }
    if (error != null && error.trim().isNotEmpty) {
      _setMusicError(error);
      return;
    }
    notifyListeners();
  }

  Future<void> playRecentMedia(AuraMedia media) async {
    currentMedia = AuraMedia(
      id: media.id,
      title: media.title,
      artist: media.artist,
      source: media.source,
      audioUrl: media.audioUrl,
      imageUrl: media.imageUrl,
      isPlaying: true,
      videoId: media.videoId,
      youtubeUrl: media.youtubeUrl,
      spotifyUrl: media.spotifyUrl,
      duration: media.duration,
      position: Duration.zero,
    );
    route = AuraRoute.play;
    _rememberRecentMedia(currentMedia);
    await _startCurrentMediaPlayback();
  }

  Future<void> playNextMusic() async {
    final result = await _musicRepository?.next(
      _storageUserId,
      videoId: currentMedia.videoId,
      title: currentMedia.title,
      artist: currentMedia.artist,
    );
    final data = result?.data;
    if (data == null) {
      _setMusicError(result?.errorMessage ?? 'Nao encontrei a proxima musica.');
      return;
    }
    currentMedia = _mediaFromPlaybackData(data);
    _rememberRecentMedia(currentMedia);
    await _startCurrentMediaPlayback();
  }

  Future<void> playPreviousMusic() async {
    if (recentlyPlayed.length < 2) {
      await seekMusic(Duration.zero);
      return;
    }
    await playRecentMedia(recentlyPlayed[1]);
  }

  Future<void> startVoiceRecording() async {
    await _ensureDependencies();
    final audio = _audioRepository;
    if (audio == null) {
      _audioStatus = 'error';
      lastAuraReply = 'Gravador de voz nao inicializado.';
      notifyListeners();
      return;
    }
    final started = await audio.startRecording();
    _audioStatus = started ? 'recording' : 'error';
    if (!started) {
      lastAuraReply =
          'Nao consegui acessar o microfone. Verifique a permissao do Android.';
    }
    notifyListeners();
  }

  Future<String> stopVoiceRecordingAndUpload() async {
    await _ensureDependencies();
    final audio = _audioRepository;
    final userId = _storageUserId;
    if (audio == null) {
      _audioStatus = 'error';
      lastAuraReply = 'Gravador de voz nao inicializado.';
      notifyListeners();
      return '';
    }

    _audioStatus = 'processing';
    notifyListeners();
    _capturedAudio = await audio.stopRecording();
    if (_capturedAudio == null) {
      _audioStatus = 'error';
      lastAuraReply = 'Nao encontrei audio gravado para enviar.';
      notifyListeners();
      return '';
    }

    _audioStatus = 'uploading';
    notifyListeners();
    try {
      final result = await audio.uploadAudio(
        userId: userId,
        file: _capturedAudio!,
        locale: lang,
        deviceId: selectedDeviceId.isEmpty ? null : selectedDeviceId,
        metadata: {'source': 'aura_voice', 'platform_locale': lang},
      );
      if (!result.success || result.transcription.trim().isEmpty) {
        _audioStatus = 'error';
        lastAuraReply = result.errorMessage.trim().isNotEmpty
            ? result.errorMessage
            : 'Nao consegui transcrever o audio.';
        notifyListeners();
        return '';
      }
      _audioStatus = 'completed';
      notifyListeners();
      return result.transcription;
    } catch (error) {
      _audioStatus = 'error';
      lastAuraReply = error is AppError
          ? error.message
          : 'Nao consegui enviar o audio ao backend.';
      notifyListeners();
      return '';
    }
  }

  void addActivity({
    required String text,
    String device = '',
    String origin = 'Aura Mind',
    String details = '',
  }) {
    recentActivities.insert(
      0,
      AuraActivity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        time: _formatActivityTime(DateTime.now()),
        text: text,
        device: device.isEmpty ? 'Aplicativo' : device,
        origin: origin,
        details: details.isEmpty ? text : details,
      ),
    );
    if (recentActivities.length > 100) {
      recentActivities.removeRange(100, recentActivities.length);
    }
    notifyListeners();
  }

  Future<bool> submitSupportRequest({
    required String subject,
    required String message,
    String origin = 'Suporte',
    bool openEmail = false,
  }) async {
    final cleanSubject = subject.trim().isEmpty
        ? 'Suporte Aura Mind'
        : subject.trim();
    final cleanMessage = message.trim().isEmpty
        ? 'O usuario nao escreveu detalhes.'
        : message.trim();
    addActivity(text: cleanSubject, origin: origin, details: cleanMessage);
    addNotification(
      title: origin,
      body: 'Registro salvo no app. ${openEmail ? 'Abrindo e-mail...' : ''}',
      origin: origin,
    );
    if (!openEmail) return true;
    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {'subject': cleanSubject, 'body': cleanMessage},
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      addNotification(
        title: 'E-mail indisponivel',
        body:
            'Nao consegui abrir o app de e-mail. Envie para ${AppConfig.supportEmail}.',
        origin: origin,
      );
      return false;
    }
  }

  // Notification Management
  void addNotification({
    required String title,
    required String body,
    String device = '',
    String origin = '',
  }) {
    final urgent = origin == 'Alarme' || origin == 'Timer';
    if (!urgent && (!notificationDelivery || doNotDisturb)) return;
    notifications.insert(
      0,
      AuraNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        device: device,
        origin: origin,
      ),
    );
    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }
    notifyListeners();
  }

  String _formatActivityTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return 'Hoje, $hour:$minute';
  }

  void markNotificationAsRead(String id) {
    final notification = notifications.where((n) => n.id == id).firstOrNull;
    if (notification != null) {
      notification.read = true;
      notifyListeners();
    }
  }

  void clearNotifications() {
    notifications.clear();
    notifyListeners();
  }

  int get unreadNotificationCount => notifications.where((n) => !n.read).length;

  // Privacy Management
  void initializePrivacy() {
    userPrivacy ??= AuraPrivacy();
  }

  void updatePrivacy({
    bool? allowLocationTracking,
    bool? allowAnalytics,
    bool? allowThirdPartyIntegration,
    int? dataRetentionDays,
    bool? emailNotifications,
    bool? pushNotifications,
    String? profileVisibility,
  }) {
    initializePrivacy();
    if (allowLocationTracking != null) {
      userPrivacy!.allowLocationTracking = allowLocationTracking;
    }
    if (allowAnalytics != null) {
      userPrivacy!.allowAnalytics = allowAnalytics;
    }
    if (allowThirdPartyIntegration != null) {
      userPrivacy!.allowThirdPartyIntegration = allowThirdPartyIntegration;
    }
    if (dataRetentionDays != null) {
      userPrivacy!.dataRetentionDays = dataRetentionDays;
    }
    if (emailNotifications != null) {
      userPrivacy!.emailNotifications = emailNotifications;
    }
    if (pushNotifications != null) {
      userPrivacy!.pushNotifications = pushNotifications;
    }
    if (profileVisibility != null) {
      userPrivacy!.profileVisibility = profileVisibility;
    }
    notifyListeners();
  }

  // Notification Tone Management
  void setNotificationTone(String toneId) {
    selectedNotificationToneId = toneId;
    ringtone = toneId;
    notifyListeners();
  }

  String? getNotificationToneDescription(String toneId) {
    return notificationTones
        .where((t) => t.id == toneId)
        .firstOrNull
        ?.description;
  }

  String? holidayFor(DateTime date) {
    final day = _dateOnly(date);
    final fixed = <String, String>{
      '1-1': 'Confraternização Universal',
      '1-25': 'Aniversário de São Paulo',
      '4-21': 'Tiradentes',
      '5-1': 'Dia do Trabalhador',
      '7-9': 'Revolução Constitucionalista',
      '9-7': 'Independência do Brasil',
      '10-12': 'Nossa Senhora Aparecida',
      '11-2': 'Finados',
      '11-15': 'Proclamação da República',
      '11-20': 'Consciência Negra',
      '12-25': 'Natal',
    };
    final fixedHoliday = fixed['${day.month}-${day.day}'];
    if (fixedHoliday != null) return fixedHoliday;

    final easter = _easterSunday(day.year);
    final movable = <DateTime, String>{
      easter.subtract(const Duration(days: 48)): 'Carnaval',
      easter.subtract(const Duration(days: 47)): 'Carnaval',
      easter.subtract(const Duration(days: 2)): 'Sexta-feira Santa',
      easter: 'Páscoa',
      easter.add(const Duration(days: 60)): 'Corpus Christi',
    };
    return movable[day];
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_activeUserId.isEmpty || appInitStage != AppInitStage.ready) return;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 450), () {
      _persistUserState();
    });
  }

  Future<void> _persistUserState() async {
    final userId = _activeUserId;
    if (userId.isEmpty) return;
    await _ensureDependencies();
    await _settingsRepository?.save(
      userId,
      UserSettingsData(
        theme: themeMode,
        language: lang,
        ringtone: ringtone,
        onboardingCompleted: true,
        selectedVoice: 'Aura',
        raw: {
          'do_not_disturb': doNotDisturb,
          'notification_delivery': notificationDelivery,
          'app_brightness': appBrightness,
          'device_brightness': deviceBrightness,
          'adaptive_brightness': adaptiveBrightness,
          'weather': {
            'location': location,
            'condition': weatherCondition,
            'temperature_c': currentTemp,
            'precipitation_mm': precipitationMm,
            'humidity': humidity,
            'wind_speed_kmh': windSpeedKmh,
            'latitude': weatherLatitude,
            'longitude': weatherLongitude,
          },
        },
      ),
    );
    await _contactsRepository?.save(userId, contacts);
    try {
      await _devicesRepository?.save(userId, devices);
    } catch (_) {
      // Local device state remains cached; explicit device actions show feedback.
    }
    await _appDataRepository?.save(
      userId,
      lists: lists,
      notes: notes,
      alarms: alarms,
      timers: timers,
      reminders: reminders,
      accounts: accounts,
      activities: recentActivities,
      notifications: notifications,
      networks: [...wifiNetworks, ...bluetoothDevices, ...zigbeeHubs],
      skills: skills,
      selectedWorldClockId: selectedWorldClockId,
      privacy: userPrivacy ?? currentAccount?.privacy,
    );
  }

  void _tickClock() {
    var shouldNotify = false;
    final now = DateTime.now();

    for (final timer in timers) {
      if (!timer.active) {
        if (timer.completed) {
          timer.elapsedAfterFinishSeconds += 1;
          shouldNotify = true;
        }
        continue;
      }
      timer.remainingSeconds -= 1;
      shouldNotify = true;
      if (timer.remainingSeconds <= 0) {
        timer.remainingSeconds = 0;
        timer.active = false;
        timer.completed = true;
        timer.completedAt = now;
        timer.elapsedAfterFinishSeconds = 0;
        ringingTimer = timer;
        unawaited(AuraNotificationService.cancelTimer(timer.id));
        unawaited(
          AuraPlatformService.playAlertTone(
            ringtone,
            durationSeconds: 90,
            volume: 100,
            vibrate: true,
          ),
        );
        unawaited(
          AuraNotificationService.showTimerNotification(
            timerLabel: timer.label,
            tone: ringtone,
          ),
        );
      }
    }

    if (stopwatch.active) {
      stopwatch.elapsedSeconds += 1;
      shouldNotify = true;
    }

    for (final alarm in alarms) {
      if (!alarm.active || !alarm.shouldTrigger(now)) continue;
      alarm.lastTriggeredAt = now;
      alarm.snoozedUntil = null;
      ringingAlarm = alarm;
      unawaited(AuraNotificationService.scheduleAlarm(alarm));
      unawaited(
        AuraPlatformService.playAlertTone(
          alarm.tone,
          durationSeconds: alarm.ringDurationSeconds,
          volume: alarm.volume,
          vibrate: alarm.vibrate,
        ),
      );
      unawaited(
        AuraNotificationService.showAlarmNotification(
          alarmName: alarm.name,
          time: alarm.time,
          tone: alarm.tone,
        ),
      );
      shouldNotify = true;
    }

    for (final entry in reminders.entries) {
      for (final reminder in entry.value) {
        if (!_shouldTriggerReminder(entry.key, reminder, now)) continue;
        reminder.lastTriggeredAt = now;
        addNotification(
          title: 'Lembrete',
          body: reminder.text,
          origin: 'Lembrete',
        );
        if (!doNotDisturb && notificationDelivery) {
          unawaited(
            AuraNotificationService.showNotification(
              id: reminder.id.hashCode,
              title: 'Lembrete',
              body: reminder.text,
              payload: 'reminder:${reminder.id}',
            ),
          );
        }
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _shouldTriggerReminder(
    DateTime date,
    AuraReminder reminder,
    DateTime now,
  ) {
    if (!reminder.active || reminder.time == null) return false;
    if (!_reminderOccursOn(date, reminder, now)) return false;
    final parts = reminder.time!.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).subtract(Duration(minutes: reminder.alertMinutesBefore));
    if (now.hour != scheduled.hour || now.minute != scheduled.minute) {
      return false;
    }
    final last = reminder.lastTriggeredAt;
    return last == null ||
        last.year != now.year ||
        last.month != now.month ||
        last.day != now.day ||
        last.hour != now.hour ||
        last.minute != now.minute;
  }

  bool _reminderOccursOn(DateTime date, AuraReminder reminder, DateTime now) {
    final base = _dateOnly(date);
    final today = _dateOnly(now);
    if (reminder.repeat == 'daily') return !today.isBefore(base);
    if (reminder.repeat == 'weekly') {
      return !today.isBefore(base) && today.weekday == base.weekday;
    }
    if (reminder.repeat == 'monthly') {
      return !today.isBefore(base) && today.day == base.day;
    }
    return today.year == base.year &&
        today.month == base.month &&
        today.day == base.day;
  }

  static DateTime _easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  @override
  void dispose() {
    _listenTimer?.cancel();
    _auraLightResetTimer?.cancel();
    _greetingTimer?.cancel();
    _clockTimer?.cancel();
    _persistDebounce?.cancel();
    _bleLogSubscription?.cancel();
    _musicPlayerSubscription?.cancel();
    unawaited(AuraPlatformService.stopTonePreview());
    unawaited(_bleService.dispose());
    unawaited(_musicPlayer.dispose());
    super.dispose();
  }

  void _updateGreeting() {
    final clock = selectedWorldClock;
    final hour = DateTime.now()
        .toUtc()
        .add(Duration(minutes: clock.utcOffsetMinutes))
        .hour;
    if (hour >= 5 && hour < 12) {
      greeting = 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }
  }
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
