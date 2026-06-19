import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_route.dart';
import '../../core/localization/aura_localizations.dart';
import '../../core/theme/aura_colors.dart';
import '../../core/theme/aura_radii.dart';
import '../../core/theme/aura_spacing.dart';
import '../../models/aura_models.dart';
import '../../services/aura_platform_service.dart';
import '../../state/aura_controller.dart';
import '../../state/aura_scope.dart';
import '../../widgets/aura_animated_light.dart';
import '../../widgets/aura_primary_button.dart';
import '../../widgets/aura_persistent_media_player.dart';
import '../../widgets/aura_text_field.dart';
import '../../widgets/aura_ui.dart';

ImageProvider? _imageProvider(String? value) {
  final path = value?.trim() ?? '';
  if (path.isEmpty) return null;
  final uri = Uri.tryParse(path);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}

class AuraRouteView extends StatelessWidget {
  const AuraRouteView({super.key, required this.route});

  final AuraRoute route;

  @override
  Widget build(BuildContext context) {
    return switch (route) {
      AuraRoute.home => const HomeView(),
      AuraRoute.homeLocation => const HomeLocationView(),
      AuraRoute.auraAsk => const AuraAskView(),
      AuraRoute.communicate => const CommunicateView(),
      AuraRoute.communicateCall => const ContactPickerView(
        mode: ContactPickerMode.call,
      ),
      AuraRoute.communicateMessage => const ContactPickerView(
        mode: ContactPickerMode.message,
      ),
      AuraRoute.communicateChat => const ChatView(),
      AuraRoute.communicateDropIn => const DropInView(),
      AuraRoute.communicateAnnouncements => const AnnouncementsView(),
      AuraRoute.communicateCalling => const CallingView(),
      AuraRoute.communicateAddContact => const ContactFormView(),
      AuraRoute.communicateEditContact => const ContactFormView(editing: true),
      AuraRoute.communicateAddGroup => const GroupFormView(),
      AuraRoute.communicateGroupSettings => const GroupSettingsView(),
      AuraRoute.play => const MediaView(),
      AuraRoute.devices => const DevicesView(),
      AuraRoute.deviceLight => const DeviceDetailView(
        kind: AuraDeviceType.light,
      ),
      AuraRoute.deviceAc => const DeviceDetailView(kind: AuraDeviceType.ac),
      AuraRoute.more => const MoreView(),
      AuraRoute.moreLists => const ListsAndNotesView(),
      AuraRoute.moreListItems => const ListItemsView(),
      AuraRoute.moreNoteEdit => const NoteEditView(),
      AuraRoute.moreCalendar => const CalendarView(),
      AuraRoute.moreCalendarEdit => const ReminderEditView(),
      AuraRoute.moreAlarms => const AlarmsView(),
      AuraRoute.moreAlarmEdit => const AlarmFormView(editing: true),
      AuraRoute.moreAlarmNew => const AlarmFormView(),
      AuraRoute.moreSkills => const SkillsView(),
      AuraRoute.moreConfig => const ConfigView(),
      AuraRoute.moreConfigDevice => const ConfigDeviceView(),
      AuraRoute.moreConfigDeviceSettings => const DeviceSettingsListView(),
      AuraRoute.moreConfigDeviceAdd => const DeviceAddFlowView(),
      AuraRoute.deviceConfigLight1 ||
      AuraRoute.deviceConfigLight2 ||
      AuraRoute.deviceConfigTv ||
      AuraRoute.deviceConfigAc ||
      AuraRoute.deviceConfigEcho => const DeviceConfigUpgradedView(),
      AuraRoute.moreConfigWifi => const WifiSettingsView(),
      AuraRoute.moreConfigBluetooth => const NearbyBluetoothView(),
      AuraRoute.moreConfigDisplay => const DisplaySettingsView(),
      AuraRoute.moreConfigLanguage => const LanguageSettingsView(),
      AuraRoute.moreConfigNotifications => const NotificationsView(),
      AuraRoute.moreConfigPermissions => const PermissionsStatusView(),
      AuraRoute.moreConfigNotificationsRingtone => const RingtoneView(),
      AuraRoute.moreConfigAccounts => const AccountsView(),
      AuraRoute.moreConfigAccountsAdd => const AccountAddView(),
      AuraRoute.moreConfigAccountSettings => const AccountSettingsView(),
      AuraRoute.moreActivities => const ActivitiesView(),
      AuraRoute.moreSupport => const SupportView(),
      AuraRoute.moreFeedback => const FeedbackView(),
      AuraRoute.profile => const ProfileView(),
      AuraRoute.profileData => const ProfileDataView(),
      AuraRoute.profileDataEdit => const ProfileDataEditView(),
      AuraRoute.profileVoice => const ProfileVoiceView(),
      AuraRoute.profileVoiceLanguage => const VoiceLanguageView(),
      AuraRoute.profileVoiceSpeed => const VoiceSpeedView(),
      AuraRoute.profileVoiceWakeWord => const WakeWordView(),
      AuraRoute.profilePrivacy => const ProfilePrivacyView(),
      AuraRoute.profilePrivacyHistory => const PrivacyHistoryView(),
      AuraRoute.profilePrivacySkills => const PrivacySkillsView(),
      AuraRoute.legalTerms => const LegalDocumentView(kind: 'terms'),
      AuraRoute.legalPrivacy => const LegalDocumentView(kind: 'privacy'),
      AuraRoute.skillLogin => const SkillLoginView(),
    };
  }
}

class _ScrollPage extends StatelessWidget {
  const _ScrollPage({required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: children,
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuraScope.of(context);
    final homeDevices = controller.devices.take(4).toList();
    final auraStatusText = switch (controller.auraLightState) {
      AuraLightState.listening => 'Ouvindo...',
      AuraLightState.processing => 'Processando...',
      AuraLightState.responding => 'Respondendo...',
      AuraLightState.success => 'Pronto',
      AuraLightState.error => 'Falha ao conectar',
      AuraLightState.idle => 'Toque para falar com Aura Mind',
    };
    final auraStatusColor = switch (controller.auraLightState) {
      AuraLightState.processing => AuraColors.purple400,
      AuraLightState.responding => AuraColors.purple400,
      AuraLightState.success => AuraColors.green400,
      AuraLightState.error => AuraColors.red400,
      AuraLightState.listening => AuraColors.cyan400,
      AuraLightState.idle => AuraColors.zinc400,
    };

    return _ScrollPage(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Center(
          child: InkWell(
            onTap: () => controller.toggleListening(),
            borderRadius: BorderRadius.circular(120),
            child: Column(
              children: [
                AuraAnimatedLight(
                  listening: controller.isListening,
                  state: controller.auraLightState,
                  size: 230,
                  logoSize: controller.isListening ? 0 : 118,
                ),
                Text(
                  auraStatusText,
                  style: TextStyle(
                    color: auraStatusColor,
                    fontSize: controller.isListening ? 18 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AuraFilterChip(
                label: 'Ligar luzes',
                selected: false,
                onTap: () {
                  final light = controller.devices
                      .where((device) => device.type == AuraDeviceType.light)
                      .firstOrNull;
                  if (light == null) {
                    controller.go(AuraRoute.moreConfigDeviceAdd);
                  } else {
                    controller.toggleDevice(light.id);
                  }
                },
              ),
              AuraFilterChip(
                label: 'Tocar jazz',
                selected: false,
                onTap: () async {
                  controller.go(AuraRoute.auraAsk);
                  await controller.sendAuraMessage(
                    'Tocar jazz',
                    source: 'quick_action',
                  );
                },
              ),
              AuraFilterChip(
                label: 'Vai chover?',
                selected: false,
                onTap: () async {
                  controller.go(AuraRoute.auraAsk);
                  await controller.sendAuraMessage(
                    'Vai chover hoje em ${controller.location}?',
                    source: 'quick_action',
                  );
                },
              ),
              AuraFilterChip(
                label: 'Perguntar por mensagem',
                selected: false,
                onTap: () => controller.go(AuraRoute.auraAsk),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AuraSection(
          child: Column(
            children: [
              _SectionHeader(
                title: 'Casa Inteligente',
                action: 'Ver tudo',
                onTap: () => controller.go(AuraRoute.devices),
              ),
              const SizedBox(height: 14),
              if (homeDevices.isEmpty)
                _EmptyState(
                  icon: Icons.add_home_work_rounded,
                  title: 'Sua casa ainda está vazia',
                  subtitle:
                      'Adicione lâmpadas, TVs, sensores, hubs Zigbee e outros aparelhos para começar.',
                  action: 'Adicionar dispositivo',
                  onTap: () => controller.go(AuraRoute.moreConfigDeviceAdd),
                )
              else
                GridView.builder(
                  itemCount: homeDevices.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width > 760
                        ? 4
                        : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: MediaQuery.sizeOf(context).width > 760
                        ? 0.82
                        : 0.74,
                  ),
                  itemBuilder: (context, index) {
                    final device = homeDevices[index];
                    return AuraDeviceCard(
                      device: device,
                      onTap: () => controller.openDevice(device),
                      onToggle: () => controller.toggleDevice(device.id),
                      onSettings: () => controller.openDeviceConfig(device),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CurrentMediaCard(controller: controller),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: isDark ? AuraColors.white : const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: Text(action!),
            style: TextButton.styleFrom(foregroundColor: AuraColors.cyan400),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuraRadii.xl),
        color: isDark ? Colors.transparent : Colors.white,
        border: Border.all(
          color: isDark
              ? AuraColors.cyan500.withValues(alpha: 0.20)
              : const Color(0xFFDCE6F2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AuraColors.cyan400, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AuraColors.zinc400 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: Text(action),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, this.onClose});

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AuraRadii.lg),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFCA5A5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AuraColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onClose != null)
            IconButton(
              tooltip: 'Fechar',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: AuraColors.white,
            ),
        ],
      ),
    );
  }
}

class _FullWidthToggleTile extends StatelessWidget {
  const _FullWidthToggleTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AuraListTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: IgnorePointer(
        child: Opacity(
          opacity: onChanged == null ? 0.45 : 1,
          child: AuraSwitch(value: value, onChanged: (_) {}),
        ),
      ),
    );
  }
}

class _LargeSliderTile extends StatefulWidget {
  const _LargeSliderTile({
    required this.icon,
    required this.title,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final IconData icon;
  final String title;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  State<_LargeSliderTile> createState() => _LargeSliderTileState();
}

class _LargeSliderTileState extends State<_LargeSliderTile> {
  late double _draftValue;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _draftValue = _clamp(widget.value);
  }

  @override
  void didUpdateWidget(covariant _LargeSliderTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && widget.value != oldWidget.value) {
      _draftValue = _clamp(widget.value);
    }
  }

  double _clamp(double value) => value.clamp(widget.min, widget.max).toDouble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: isDark
            ? AuraColors.zinc900.withValues(alpha: 0.46)
            : Colors.white,
        borderRadius: BorderRadius.circular(AuraRadii.lg),
        border: Border.all(
          color: isDark
              ? AuraColors.zinc800.withValues(alpha: 0.46)
              : const Color(0xFFDCE6F2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(widget.icon, color: AuraColors.purple400, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: isDark
                        ? AuraColors.zinc100
                        : const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                widget.valueText,
                style: TextStyle(
                  color: isDark ? AuraColors.zinc300 : const Color(0xFF334155),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: _clamp(_draftValue),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.valueText,
            onChangeStart: (_) => setState(() => _dragging = true),
            onChanged: (value) => setState(() => _draftValue = _clamp(value)),
            onChangeEnd: (value) {
              final next = _clamp(value);
              setState(() {
                _draftValue = next;
                _dragging = false;
              });
              widget.onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _CurrentMediaCard extends StatelessWidget {
  const _CurrentMediaCard({required this.controller});

  final AuraController controller;

  @override
  Widget build(BuildContext context) {
    final media = controller.currentMedia;
    final controls = AuraMediaPlayerScope.maybeOf(context);
    return InkWell(
      onTap: () => controller.go(AuraRoute.play),
      borderRadius: BorderRadius.circular(AuraRadii.xl),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF312E81).withValues(alpha: 0.46),
              const Color(0xFF581C87).withValues(alpha: 0.34),
            ],
          ),
          borderRadius: BorderRadius.circular(AuraRadii.xl),
          border: Border.all(
            color: media.isPlaying
                ? const Color(0xFF818CF8).withValues(alpha: 0.52)
                : const Color(0xFF818CF8).withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            _NetworkSquare(imageUrl: media.imageUrl, size: 64, radius: 14),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tocando Agora',
                    style: TextStyle(
                      color: Color(0xFFA5B4FC),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    media.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuraColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    media.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  controls?.toggle() ?? Future.sync(controller.togglePlay),
              icon: Icon(
                media.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: AuraColors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AuraColors.white.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkSquare extends StatelessWidget {
  const _NetworkSquare({
    required this.imageUrl,
    required this.size,
    required this.radius,
  });

  final String imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AuraColors.zinc800 : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: const Icon(Icons.music_note_rounded, color: AuraColors.cyan400),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: isDark ? AuraColors.zinc800 : const Color(0xFFEFF6FF),
            child: const Icon(
              Icons.music_note_rounded,
              color: AuraColors.cyan400,
            ),
          );
        },
      ),
    );
  }
}

class HomeLocationView extends StatefulWidget {
  const HomeLocationView({super.key});

  @override
  State<HomeLocationView> createState() => _HomeLocationViewState();
}

class _HomeLocationViewState extends State<HomeLocationView> {
  TextEditingController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= TextEditingController(text: AuraScope.of(context).location);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    if (app.recentActivities.isEmpty) {
      return _ScrollPage(
        children: [
          _EmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: 'Sem atividades ainda',
            subtitle:
                'Quando voce conectar aparelhos, skills ou contatos, o historico aparece aqui.',
            action: 'Adicionar aparelho',
            onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
          ),
        ],
      );
    }
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${app.currentTemp}°C em ${app.location}',
                style: const TextStyle(
                  color: AuraColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use a localização do celular para ajustar clima, rotinas e horários padrão.',
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await AuraPlatformService.readLocalWeather();
                  if (result == null) return;
                  app.currentTemp = result.temperature;
                  app.setLocation(result.location);
                },
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Usar local atual'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Cidade atual',
          hint: 'São Paulo',
          controller: _controller,
        ),
        const SizedBox(height: AuraSpacing.xxl),
        AuraPrimaryButton(
          label: 'Salvar localização',
          onPressed: () => app.setLocation(_controller?.text ?? ''),
        ),
      ],
    );
  }
}

class AuraAskView extends StatefulWidget {
  const AuraAskView({super.key});

  @override
  State<AuraAskView> createState() => _AuraAskViewState();
}

class _AuraAskViewState extends State<AuraAskView> {
  final _message = TextEditingController();
  final _scrollController = ScrollController();

  String? _pickedImage;

  @override
  void dispose() {
    _message.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendAura() async {
    final text = _message.text.trim();

    if (text.isEmpty && _pickedImage == null) return;

    final app = AuraScope.of(context);
    final image = _pickedImage;
    setState(() {
      _message.clear();
      _pickedImage = null;
    });

    await app.sendAuraMessage(text, source: 'text', imageName: image ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final messages = app.auraConversationMessages;
    final voiceBusy =
        app.audioStatus == 'processing' || app.audioStatus == 'uploading';
    final recording = app.audioStatus == 'recording' || app.isListening;
    if (messages.isNotEmpty) _scrollToBottom();
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Como posso ajudar hoje?',
                    style: TextStyle(color: AuraColors.zinc400),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final sent = message.direction == 'outgoing';

                    return Align(
                      alignment: sent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: sent ? AuraColors.cyan500 : AuraColors.zinc800,
                          borderRadius: BorderRadius.circular(AuraRadii.lg),
                        ),
                        child: Text(
                          message.body,
                          style: TextStyle(
                            color: sent ? AuraColors.black : AuraColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (app.audioStatus == 'processing' || app.audioStatus == 'uploading')
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  'Processando voz...',
                  style: TextStyle(color: AuraColors.zinc400),
                ),
              ],
            ),
          ),

        if (_pickedImage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AuraListTile(
              icon: Icons.image_search_rounded,
              title: _pickedImage!,
              subtitle: 'Imagem pronta para pesquisa',
              trailing: IconButton(
                onPressed: () => setState(() => _pickedImage = null),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () async {
                  final image =
                      await AuraPlatformService.pickImageForAuraSearch();

                  if (image == null) return;

                  setState(() => _pickedImage = image);
                },
                icon: const Icon(Icons.image_search_rounded),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: _message,
                  decoration: const InputDecoration(
                    hintText: 'Pergunte algo para a Aura...',
                  ),
                  onSubmitted: (_) => _sendAura(),
                ),
              ),

              const SizedBox(width: 8),

              IconButton.filledTonal(
                tooltip: recording ? 'Parar gravacao' : 'Gravar voz',
                onPressed: voiceBusy ? null : app.toggleListening,
                icon: Icon(recording ? Icons.stop_rounded : Icons.mic_rounded),
              ),

              const SizedBox(width: 8),

              IconButton.filled(
                onPressed: _sendAura,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunicateView extends StatefulWidget {
  const CommunicateView({super.key});

  @override
  State<CommunicateView> createState() => _CommunicateViewState();
}

class _CommunicateViewState extends State<CommunicateView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final query = _search.text.trim().toLowerCase();
    final filteredContacts = query.isEmpty
        ? app.contacts
        : app.contacts.where((contact) {
            return contact.name.toLowerCase().contains(query) ||
                contact.phone.toLowerCase().contains(query) ||
                contact.type.toLowerCase().contains(query);
          }).toList();
    return _ScrollPage(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 520;
            final itemWidth = compact ? (width - 16) / 2 : 118.0;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: AuraActionIcon(
                    icon: Icons.phone_rounded,
                    label: 'Ligar',
                    color: const Color(0xFF4ADE80),
                    onTap: () => app.go(AuraRoute.communicateCall),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AuraActionIcon(
                    icon: Icons.message_rounded,
                    label: 'Mensagem',
                    color: const Color(0xFF60A5FA),
                    onTap: () => app.go(AuraRoute.communicateMessage),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AuraActionIcon(
                    icon: Icons.settings_input_antenna_rounded,
                    label: 'Drop In',
                    color: const Color(0xFFC084FC),
                    onTap: () => app.go(AuraRoute.communicateDropIn),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: AuraActionIcon(
                    icon: Icons.notifications_rounded,
                    label: 'Avisos',
                    color: const Color(0xFFFBBF24),
                    onTap: () => app.go(AuraRoute.communicateAnnouncements),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150, maxWidth: 240),
              child: OutlinedButton.icon(
                onPressed: () => app.go(AuraRoute.communicateAddContact),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Novo contato'),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150, maxWidth: 240),
              child: OutlinedButton.icon(
                onPressed: app.importPhoneContacts,
                icon: const Icon(Icons.contacts_rounded),
                label: const Text('Importar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => app.go(AuraRoute.communicateAddGroup),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Criar novo grupo'),
          ),
        ),
        const SizedBox(height: 28),
        AuraTextField(
          label: 'Pesquisar contato',
          hint: 'Nome, telefone ou tipo',
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        if (app.groups.isNotEmpty) ...[
          const SizedBox(height: 22),
          const _ListTitle('Grupos'),
          for (final group in app.groups) ...[
            Dismissible(
              key: ValueKey('group-${group.id}'),
              direction: group.ownerId == app.activeUserId
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: const _SwipeDeleteBackground(),
              confirmDismiss: (_) => _confirmDestructiveAction(
                context,
                title: 'Excluir grupo?',
                message:
                    'O grupo "${group.name}" e suas conversas serão removidos.',
              ),
              onDismissed: (_) => unawaited(app.deleteGroup(group.id)),
              child: AuraSection(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _ProfileAvatar(
                    name: group.name,
                    imageUrl: group.imageAsset,
                    size: 48,
                  ),
                  title: Text(group.name),
                  subtitle: Text('${group.memberIds.length} membro(s)'),
                  trailing: IconButton(
                    tooltip: 'Configurações do grupo',
                    onPressed: () => app.openGroupSettings(group),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                  onTap: () => app.startGroupChat(group),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        const SizedBox(height: 22),
        const _ListTitle('Contatos salvos'),
        if (filteredContacts.isEmpty)
          _EmptyState(
            icon: Icons.contacts_rounded,
            title: app.contacts.isEmpty
                ? 'Nenhum contato ainda'
                : 'Nenhum contato encontrado',
            subtitle:
                'Adicione manualmente, importe contatos ou ajuste a busca.',
            action: 'Adicionar contato',
            onTap: () => app.go(AuraRoute.communicateAddContact),
          )
        else
          for (final contact in filteredContacts) ...[
            AuraContactCard(
              contact: contact,
              onTap: () {
                app.selectedContactId = contact.id;
                app.go(AuraRoute.communicateEditContact);
              },
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ListTitle extends StatelessWidget {
  const _ListTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AuraColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

enum ContactPickerMode { call, message }

class ContactPickerView extends StatefulWidget {
  const ContactPickerView({super.key, required this.mode});

  final ContactPickerMode mode;

  @override
  State<ContactPickerView> createState() => _ContactPickerViewState();
}

class _ContactPickerViewState extends State<ContactPickerView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final query = _search.text.trim().toLowerCase();
    final filteredContacts = query.isEmpty
        ? app.contacts
        : app.contacts.where((contact) {
            return contact.name.toLowerCase().contains(query) ||
                contact.phone.toLowerCase().contains(query) ||
                contact.type.toLowerCase().contains(query);
          }).toList();
    return _ScrollPage(
      children: [
        Text(
          widget.mode == ContactPickerMode.call
              ? 'Selecione para quem deseja ligar'
              : 'Selecione para quem deseja enviar mensagem',
          style: const TextStyle(color: AuraColors.zinc400),
        ),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Pesquisar contato',
          hint: 'Nome, telefone ou tipo',
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (filteredContacts.isEmpty)
          _EmptyState(
            icon: Icons.contacts_rounded,
            title: app.contacts.isEmpty
                ? 'Nenhum contato disponivel'
                : 'Nenhum contato encontrado',
            subtitle: 'Importe contatos do celular ou cadastre um novo.',
            action: 'Adicionar contato',
            onTap: () => app.go(AuraRoute.communicateAddContact),
          )
        else
          for (final contact in filteredContacts) ...[
            AuraContactCard(
              contact: contact,
              onTap: () async {
                if (widget.mode == ContactPickerMode.call) {
                  await app.dialPhoneNumber(contact.phone);
                  app.startCall(contact.name, contactId: contact.id);
                  return;
                }
                app.startChat(contact);
              },
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(AuraController app) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await app.sendChatMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final contact = app.selectedContact;
    final group = app.selectedGroup;
    final messages = app.selectedConversationMessages;
    if (messages.isNotEmpty) _scrollToBottom();
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: group == null
                ? AuraColors.cyan500
                : AuraColors.purple500,
            backgroundImage: _imageProvider(
              group?.imageAsset ?? contact?.imageAsset,
            ),
            child:
                (group?.imageAsset ?? contact?.imageAsset ?? '')
                    .trim()
                    .isNotEmpty
                ? null
                : Text(
                    (group?.name ?? contact?.name ?? app.chatContact)
                            .characters
                            .firstOrNull ??
                        'U',
                  ),
          ),
          title: Text(group?.name ?? contact?.name ?? app.chatContact),
          subtitle: Text(
            group == null
                ? 'Editar Contato'
                : '${group.memberIds.length} membro(s)',
            style: const TextStyle(color: AuraColors.cyan400),
          ),
          trailing: const Icon(Icons.settings_rounded),
          onTap: group == null
              ? () => app.go(AuraRoute.communicateEditContact)
              : () => app.openGroupSettings(group),
        ),
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma mensagem ainda.',
                    style: TextStyle(color: AuraColors.zinc500),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final sent = message.direction == 'outgoing';
                    return Align(
                      alignment: sent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 290),
                        decoration: BoxDecoration(
                          color: sent ? AuraColors.cyan500 : AuraColors.zinc800,
                          borderRadius: BorderRadius.circular(AuraRadii.lg),
                        ),
                        child: Text(
                          message.body,
                          style: TextStyle(
                            color: sent ? AuraColors.black : AuraColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Escreva uma mensagem...',
                  ),
                  onSubmitted: (_) => _send(app),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _send(app),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DropInView extends StatelessWidget {
  const DropInView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        const Text(
          'Selecione um dispositivo para se conectar imediatamente',
          style: TextStyle(color: AuraColors.zinc400),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          children: [
            _DeviceShortcut(
              icon: Icons.speaker_rounded,
              title: 'Aura Echo Quarto',
              onTap: () => app.startCall('Drop In: Aura Echo Quarto'),
            ),
            _DeviceShortcut(
              icon: Icons.tv_rounded,
              title: 'Aura Show Cozinha',
              onTap: () => app.startCall('Drop In: Aura Show Cozinha'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeviceShortcut extends StatelessWidget {
  const _DeviceShortcut({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AuraSection(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFC084FC), size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final recording = app.audioStatus == 'recording';
    final uploading =
        app.audioStatus == 'uploading' || app.audioStatus == 'processing';
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              Icon(
                recording ? Icons.mic_rounded : Icons.campaign_rounded,
                color: recording
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFBBF24),
                size: 56,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Digite ou grave um aviso...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: uploading
                          ? null
                          : () async {
                              if (!recording) {
                                await app.startVoiceRecording();
                                return;
                              }
                              final text = await app
                                  .stopVoiceRecordingAndUpload();
                              if (!mounted) return;
                              if (text.trim().isEmpty) return;
                              setState(() {
                                _textController.text = text;
                              });
                            },
                      icon: Icon(
                        recording ? Icons.stop_rounded : Icons.mic_rounded,
                      ),
                      label: Text(
                        uploading
                            ? 'Enviando...'
                            : (recording ? 'Parar' : 'Gravar'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _textController.clear();
                        app.addNotification(
                          title: 'Aviso enviado',
                          body: 'Mensagem publicada para os membros.',
                          origin: 'Avisos',
                        );
                      },
                      child: const Text('Transmitir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CallingView extends StatefulWidget {
  const CallingView({super.key});

  @override
  State<CallingView> createState() => _CallingViewState();
}

class _CallingViewState extends State<CallingView> {
  bool muted = false;
  bool video = false;

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        const SizedBox(height: 42),
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 54,
                backgroundColor: AuraColors.zinc800,
                child: Icon(
                  Icons.person_rounded,
                  color: AuraColors.zinc400,
                  size: 52,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                app.callingContact.isEmpty
                    ? 'Chamada Aura'
                    : app.callingContact,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chamando...',
                style: TextStyle(color: AuraColors.cyan400),
              ),
              const SizedBox(height: 52),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundCallButton(
                    icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    active: muted,
                    onTap: () => setState(() => muted = !muted),
                  ),
                  const SizedBox(width: 24),
                  _RoundCallButton(
                    icon: Icons.call_end_rounded,
                    danger: true,
                    onTap: () => app.endActiveCall(),
                  ),
                  const SizedBox(width: 24),
                  _RoundCallButton(
                    icon: video
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    active: video,
                    onTap: () => setState(() => video = !video),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundCallButton extends StatelessWidget {
  const _RoundCallButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: danger || active ? AuraColors.white : AuraColors.zinc100,
      iconSize: 28,
      style: IconButton.styleFrom(
        fixedSize: const Size(64, 64),
        backgroundColor: danger
            ? const Color(0xFFEF4444)
            : (active
                  ? AuraColors.white.withValues(alpha: 0.18)
                  : AuraColors.zinc800),
      ),
    );
  }
}

class ContactFormView extends StatefulWidget {
  const ContactFormView({super.key, this.editing = false});

  final bool editing;

  @override
  State<ContactFormView> createState() => _ContactFormViewState();
}

class _ContactFormViewState extends State<ContactFormView> {
  late TextEditingController name;
  late TextEditingController phone;
  String deviceType = 'Celular';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final contact = AuraScope.of(context).selectedContact;
    name = TextEditingController(
      text: widget.editing ? contact?.name ?? '' : '',
    );
    phone = TextEditingController(
      text: widget.editing ? contact?.phone ?? '(11) 99999-9999' : '',
    );
    deviceType = widget.editing ? contact?.time ?? 'Celular' : 'Celular';
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final contact = app.selectedContact;
    return _ScrollPage(
      children: [
        if (widget.editing)
          Center(
            child: _ProfileAvatar(
              name: name.text.isEmpty ? 'Contato' : name.text,
              imageUrl: contact?.imageAsset,
              size: 92,
              onTap: () => app.updateContactPhoto(app.selectedContactId),
            ),
          ),
        if (widget.editing) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => app.updateContactPhoto(app.selectedContactId),
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Trocar foto'),
          ),
          const SizedBox(height: 20),
        ],
        AuraTextField(
          label: 'Nome do Contato',
          hint: 'Ex: João',
          controller: name,
        ),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Número de Telefone',
          hint: '(11) 99999-9999',
          controller: phone,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Celular',
                selected: deviceType == 'Celular' || deviceType == 'Casa',
                onTap: () => setState(() => deviceType = 'Celular'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentButton(
                label: 'Aura Echo',
                selected: deviceType == 'Aura Echo',
                onTap: () => setState(() => deviceType = 'Aura Echo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        AuraPrimaryButton(
          label: widget.editing ? 'Salvar Alterações' : 'Adicionar Contato',
          onPressed: () {
            if (widget.editing) {
              app.updateContact(
                app.selectedContactId,
                name.text,
                phone.text,
                deviceType,
              );
            } else {
              app.addContact(name.text, phone.text, deviceType);
            }
          },
        ),
        if (widget.editing) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final confirmed = await _confirmDestructiveAction(
                context,
                title: 'Excluir contato?',
                message: 'Este contato sera removido.',
              );
              if (!context.mounted || !confirmed) return;
              app.deleteContact(app.selectedContactId);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Apagar Contato'),
          ),
        ],
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        backgroundColor: selected
            ? AuraColors.cyan500.withValues(alpha: 0.16)
            : isDark
            ? AuraColors.zinc900
            : Colors.white,
        foregroundColor: selected
            ? AuraColors.cyan400
            : isDark
            ? AuraColors.zinc400
            : const Color(0xFF475569),
        side: BorderSide(
          color: selected
              ? AuraColors.cyan500
              : isDark
              ? AuraColors.zinc800
              : const Color(0xFFDCE6F2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadii.md),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class GroupFormView extends StatefulWidget {
  const GroupFormView({super.key});

  @override
  State<GroupFormView> createState() => _GroupFormViewState();
}

class _GroupFormViewState extends State<GroupFormView> {
  final name = TextEditingController();
  final search = TextEditingController();
  final selected = <String>{};
  String imagePath = '';
  String feedback = '';

  @override
  void dispose() {
    name.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final query = search.text.trim().toLowerCase();
    final contacts = query.isEmpty
        ? app.contacts
        : app.contacts
              .where(
                (contact) =>
                    contact.name.toLowerCase().contains(query) ||
                    contact.phone.toLowerCase().contains(query) ||
                    contact.type.toLowerCase().contains(query),
              )
              .toList();
    return _ScrollPage(
      children: [
        Center(
          child: InkWell(
            onTap: () async {
              final image = await AuraPlatformService.pickProfileImage();
              if (image == null) return;
              setState(() => imagePath = image.path);
            },
            borderRadius: BorderRadius.circular(48),
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AuraColors.purple500.withValues(alpha: 0.18),
              backgroundImage: imagePath.isEmpty
                  ? null
                  : FileImage(File(imagePath)),
              child: imagePath.isEmpty
                  ? const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: AuraColors.purple400,
                      size: 34,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 18),
        AuraTextField(
          label: 'Nome do Grupo',
          hint: 'Ex: Família',
          controller: name,
        ),
        const SizedBox(height: 18),
        AuraTextField(
          label: 'Pesquisar membros',
          hint: 'Nome, telefone ou tipo',
          controller: search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        const _ListTitle('Adicionar Membros'),
        for (final contact in contacts)
          CheckboxListTile(
            value: selected.contains(contact.id),
            onChanged: (_) => setState(
              () => selected.contains(contact.id)
                  ? selected.remove(contact.id)
                  : selected.add(contact.id),
            ),
            title: Text(contact.name),
          ),
        if (feedback.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(feedback, style: const TextStyle(color: Color(0xFFF87171))),
        ],
        const SizedBox(height: 18),
        AuraPrimaryButton(
          label: 'Criar Grupo',
          onPressed: () async {
            final error = await app.createGroup(
              name.text,
              selected,
              imageAsset: imagePath,
            );
            if (!mounted) return;
            if (error != null) {
              setState(() => feedback = error);
            }
          },
        ),
      ],
    );
  }
}

class GroupSettingsView extends StatefulWidget {
  const GroupSettingsView({super.key});

  @override
  State<GroupSettingsView> createState() => _GroupSettingsViewState();
}

class _GroupSettingsViewState extends State<GroupSettingsView> {
  final name = TextEditingController();
  String loadedGroupId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final group = AuraScope.of(context).selectedGroup;
    if (group == null || group.id == loadedGroupId) return;
    loadedGroupId = group.id;
    name.text = group.name;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final group = app.selectedGroup;
    if (group == null) {
      return _ScrollPage(
        children: [
          _EmptyState(
            icon: Icons.groups_rounded,
            title: 'Grupo não encontrado',
            subtitle: 'Volte para a lista e selecione outro grupo.',
            action: 'Voltar aos grupos',
            onTap: () => app.go(AuraRoute.communicate),
          ),
        ],
      );
    }
    final canManage = group.ownerId == app.activeUserId;
    final members = app.contacts
        .where((contact) => group.memberIds.contains(contact.id))
        .toList();
    return _ScrollPage(
      children: [
        Center(
          child: _ProfileAvatar(
            name: group.name,
            imageUrl: group.imageAsset,
            size: 108,
            onTap: canManage
                ? () => app.updateSelectedGroup(pickPhoto: true)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        if (canManage)
          TextButton.icon(
            onPressed: () => app.updateSelectedGroup(pickPhoto: true),
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Trocar foto do grupo'),
          ),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Nome do grupo',
          hint: 'Ex.: Família',
          controller: name,
          enabled: canManage,
        ),
        const SizedBox(height: 14),
        AuraPrimaryButton(
          label: 'Salvar configurações',
          onPressed: canManage
              ? () async {
                  await app.updateSelectedGroup(name: name.text);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grupo atualizado.')),
                  );
                }
              : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: _ListTitle('Membros')),
            Text(
              '${members.length}',
              style: const TextStyle(color: AuraColors.cyan400),
            ),
          ],
        ),
        if (members.isEmpty)
          const Text(
            'Nenhum membro vinculado.',
            style: TextStyle(color: AuraColors.zinc500),
          )
        else
          for (final member in members) ...[
            Dismissible(
              key: ValueKey('group-member-${group.id}-${member.id}'),
              direction: canManage
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
              background: const _SwipeDeleteBackground(),
              confirmDismiss: (_) => _confirmDestructiveAction(
                context,
                title: 'Remover membro?',
                message: '${member.name} será removido do grupo.',
                confirmLabel: 'Remover',
              ),
              onDismissed: (_) =>
                  unawaited(app.removeSelectedGroupMember(member.id)),
              child: AuraSection(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _ProfileAvatar(
                    name: member.name,
                    imageUrl: member.imageAsset,
                    size: 44,
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.phone),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        if (canManage) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmDestructiveAction(
                context,
                title: 'Excluir grupo?',
                message:
                    'O grupo "${group.name}" e suas conversas serão removidos.',
              );
              if (!context.mounted || !confirmed) return;
              await app.deleteGroup(group.id);
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Excluir grupo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

class MediaView extends StatefulWidget {
  const MediaView({super.key});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  double _draftPositionMs = 0;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPositionFromController();
  }

  void _syncPositionFromController() {
    if (_dragging) return;
    final media = AuraScope.of(context).currentMedia;
    final durationMs = media.duration.inMilliseconds;
    final positionMs = durationMs <= 0
        ? 0
        : media.position.inMilliseconds.clamp(0, durationMs).toInt();
    _draftPositionMs = positionMs.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final media = app.currentMedia;
    final controls = AuraMediaPlayerScope.maybeOf(context);
    final durationMs = media.duration.inMilliseconds;
    final positionMs = durationMs <= 0
        ? 0
        : media.position.inMilliseconds.clamp(0, durationMs).toInt();
    if (!_dragging) _draftPositionMs = positionMs.toDouble();
    final sliderMax = durationMs <= 0 ? 1.0 : durationMs.toDouble();
    final sliderValue = _draftPositionMs.clamp(0, sliderMax).toDouble();
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              if (app.musicErrorMessage.isNotEmpty) ...[
                _InlineErrorBanner(
                  message: app.musicErrorMessage,
                  onClose: app.clearMusicError,
                ),
                const SizedBox(height: 16),
              ],
              _NowPlayingArtwork(
                imageUrl: media.imageUrl,
                playing: media.isPlaying,
              ),
              const SizedBox(height: 22),
              Text(
                media.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                media.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              if (media.videoId.trim().isEmpty &&
                  media.audioUrl.trim().isEmpty &&
                  media.youtubeUrl.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Esta musica veio como YouTube. Abra no YouTube ou ajuste o backend para retornar audio_url para tocar dentro do app.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AuraColors.zinc400),
                ),
              ],
              const SizedBox(height: 24),
              Slider(
                value: sliderValue,
                min: 0,
                max: sliderMax,
                onChangeStart: (_) => setState(() => _dragging = true),
                onChanged: durationMs <= 0
                    ? null
                    : (value) => setState(() => _draftPositionMs = value),
                onChangeEnd: durationMs <= 0
                    ? null
                    : (value) {
                        final target = Duration(milliseconds: value.round());
                        setState(() {
                          _draftPositionMs = value;
                          _dragging = false;
                        });
                        unawaited(app.seekMusic(target));
                      },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatMediaDuration(
                      Duration(milliseconds: sliderValue.round()),
                    ),
                    style: const TextStyle(color: AuraColors.zinc500),
                  ),
                  Text(
                    _formatMediaDuration(media.duration),
                    style: const TextStyle(color: AuraColors.zinc500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: app.playPreviousMusic,
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 32,
                  ),
                  const SizedBox(width: 18),
                  IconButton.filled(
                    onPressed: () =>
                        controls?.toggle() ?? Future.sync(app.togglePlay),
                    icon: Icon(
                      media.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    iconSize: 38,
                    style: IconButton.styleFrom(
                      backgroundColor: AuraColors.white,
                      foregroundColor: AuraColors.black,
                      fixedSize: const Size(68, 68),
                    ),
                  ),
                  const SizedBox(width: 18),
                  IconButton.filledTonal(
                    onPressed: app.playNextMusic,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 32,
                  ),
                ],
              ),
              if (media.videoId.trim().isEmpty &&
                  media.audioUrl.trim().isEmpty &&
                  media.youtubeUrl.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(media.youtubeUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Abrir no YouTube'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _ListTitle('Tocados Recentemente'),
        if (app.recentlyPlayed.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in app.recentlyPlayed) ...[
                  AuraMediaCard(
                    imageUrl: item.imageUrl,
                    title: item.title,
                    subtitle: item.artist,
                    onTap: () => app.playRecentMedia(item),
                  ),
                  const SizedBox(width: 14),
                ],
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AuraMediaCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop',
                  title: 'Eletrônica Mix',
                  subtitle: 'Playlist',
                  onTap: () => app.playMusicFromPrompt('Tocar eletronica mix'),
                ),
                const SizedBox(width: 14),
                AuraMediaCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=300&fit=crop',
                  title: 'Daily Podcast',
                  subtitle: 'Ep. 42',
                  onTap: () => app.playMusicFromPrompt('Tocar podcast diario'),
                ),
                const SizedBox(width: 14),
                AuraMediaCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1493225457124-a1a2a5f5f924?w=300&h=300&fit=crop',
                  title: 'Jazz Focus',
                  subtitle: 'Álbum',
                  onTap: () => app.playMusicFromPrompt('Tocar jazz focus'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _formatMediaDuration(Duration value) {
  final totalSeconds = value.inSeconds.clamp(0, 24 * 60 * 60);
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _NowPlayingArtwork extends StatefulWidget {
  const _NowPlayingArtwork({required this.imageUrl, required this.playing});

  final String imageUrl;
  final bool playing;

  @override
  State<_NowPlayingArtwork> createState() => _NowPlayingArtworkState();
}

class _NowPlayingArtworkState extends State<_NowPlayingArtwork>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.playing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _NowPlayingArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.playing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              transform: GradientRotation(_controller.value * 6.28318),
              colors: const [
                AuraColors.cyan400,
                Color(0xFF7C3AED),
                Color(0xFF2563EB),
                AuraColors.cyan400,
              ],
            ),
          ),
          child: child,
        );
      },
      child: ClipOval(
        child: _NetworkSquare(imageUrl: widget.imageUrl, size: 196, radius: 98),
      ),
    );
  }
}

class DevicesView extends StatefulWidget {
  const DevicesView({super.key});

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  String filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final rooms =
        app.devices
            .map(
              (device) =>
                  device.room.trim().isEmpty ? 'Casa' : device.room.trim(),
            )
            .toSet()
            .toList()
          ..sort();
    if (filter != 'Todos' && !rooms.contains(filter)) {
      filter = 'Todos';
    }
    final devices = filter == 'Todos'
        ? app.devices
        : app.devices.where((d) => d.room == filter).toList();
    return _ScrollPage(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => app.go(AuraRoute.moreConfigDeviceAdd),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo dispositivo'),
          ),
        ),
        const SizedBox(height: 14),
        AuraListTile(
          icon: Icons.memory_rounded,
          title: 'Conecte-se com sua EcoMind',
          subtitle:
              '${app.esp32BleStatus}. Use Bluetooth e Wi-Fi em um fluxo guiado.',
          color: AuraColors.purple400,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => app.go(AuraRoute.moreConfigBluetooth),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AuraFilterChip(
                label: 'Todos os Dispositivos',
                selected: filter == 'Todos',
                onTap: () => setState(() => filter = 'Todos'),
              ),
              for (final room in rooms) ...[
                const SizedBox(width: 8),
                AuraFilterChip(
                  label: room,
                  selected: filter == room,
                  onTap: () => setState(() => filter = room),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (devices.isEmpty)
          _EmptyState(
            icon: Icons.devices_other_rounded,
            title: 'Nenhum aparelho conectado',
            subtitle:
                'Conecte por Wi-Fi, Bluetooth ou Zigbee e configure cada aparelho do seu jeito.',
            action: 'Adicionar aparelho',
            onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
          )
        else
          GridView.builder(
            itemCount: devices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width > 760 ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: MediaQuery.sizeOf(context).width > 760
                  ? 0.82
                  : 0.74,
            ),
            itemBuilder: (context, index) {
              final device = devices[index];
              return AuraDeviceCard(
                device: device,
                onTap: () => app.openDevice(device),
                onToggle: () => app.toggleDevice(device.id),
                onSettings: () => app.openDeviceConfig(device),
              );
            },
          ),
      ],
    );
  }
}

class DeviceDetailView extends StatelessWidget {
  const DeviceDetailView({super.key, required this.kind});

  final AuraDeviceType kind;

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final device = app.selectedDevice;
    if (device == null) {
      return const Center(child: Text('Dispositivo não encontrado'));
    }

    final activeColor = kind == AuraDeviceType.light
        ? const Color(0xFFFACC15)
        : const Color(0xFF60A5FA);
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              Icon(
                device.icon,
                size: 96,
                color: device.active ? activeColor : AuraColors.zinc500,
              ),
              const SizedBox(height: 16),
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                device.status,
                style: TextStyle(
                  color: device.active
                      ? AuraColors.cyan400
                      : AuraColors.zinc500,
                ),
              ),
              const SizedBox(height: 24),
              AuraSwitch(
                value: device.active,
                onChanged: (_) => app.toggleDevice(device.id),
              ),
              if (device.value != null) ...[
                const SizedBox(height: 28),
                Slider(
                  value: device.value!.toDouble(),
                  min: kind == AuraDeviceType.ac ? 16 : 0,
                  max: kind == AuraDeviceType.ac ? 30 : 100,
                  divisions: kind == AuraDeviceType.ac ? 14 : 20,
                  label: kind == AuraDeviceType.ac
                      ? '${device.value}°C'
                      : '${device.value}%',
                  onChanged: (value) =>
                      app.updateDeviceValue(device.id, value.round()),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: app.doNotDisturb
              ? Icons.do_not_disturb_on_rounded
              : Icons.notifications_active_rounded,
          title: app.doNotDisturb
              ? 'Nao Perturbe ativo'
              : 'Notificacoes ativas',
          subtitle: app.doNotDisturb
              ? 'A Aura esta silenciosa para alertas comuns'
              : 'Alertas comuns podem aparecer normalmente',
          onTap: () => app.go(AuraRoute.moreConfigNotifications),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.list_alt_rounded,
          title: 'Listas e Notas',
          onTap: () => app.go(AuraRoute.moreLists),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.alarm_rounded,
          title: 'Alarmes e Timers',
          onTap: () => app.go(AuraRoute.moreAlarms),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.calendar_month_rounded,
          title: 'Calendário',
          onTap: () => app.go(AuraRoute.moreCalendar),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.extension_rounded,
          title: 'Skills e Jogos',
          onTap: () => app.go(AuraRoute.moreSkills),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.settings_rounded,
          title: 'Configurações',
          onTap: () => app.go(AuraRoute.moreConfig),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.notifications_rounded,
          title: 'Atividades',
          onTap: () => app.go(AuraRoute.moreActivities),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.support_agent_rounded,
          title: 'Suporte',
          subtitle: 'Ajuda, termos, privacidade e contato',
          onTap: () => app.go(AuraRoute.moreSupport),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.star_rate_rounded,
          title: 'Avaliar Aura Mind',
          subtitle: 'Enviar opiniao para melhorar o app',
          onTap: () => app.go(AuraRoute.moreFeedback),
        ),
      ],
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(AuraRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_rounded, color: AuraColors.white),
          const SizedBox(width: 6),
          Text(
            'Excluir',
            style: const TextStyle(
              color: AuraColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: AuraColors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> _showInfoSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  List<Widget> actions = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AuraColors.cyan400, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(body, style: const TextStyle(color: AuraColors.zinc400)),
            if (actions.isNotEmpty) ...[const SizedBox(height: 18), ...actions],
          ],
        ),
      ),
    ),
  );
}

Future<void> _showDeviceInfoSheet(BuildContext context, AuraDevice device) {
  final details = [
    'Nome: ${device.name}',
    'Tipo: ${device.typeLabel}',
    'Ambiente: ${device.room}',
    'Conexao: ${device.connectionLabel}',
    'Status: ${device.status}',
    if (device.manufacturer.trim().isNotEmpty)
      'Fabricante: ${device.manufacturer}',
    if (device.model.trim().isNotEmpty) 'Modelo: ${device.model}',
    'Rotinas: ${device.routines.length}',
    'Firmware: gerenciado pelo Aura Mind quando o aparelho suporta integracao.',
  ].join('\n');
  return _showInfoSheet(
    context,
    icon: Icons.info_rounded,
    title: 'Informações do aparelho',
    body: details,
  );
}

class ListsAndNotesView extends StatefulWidget {
  const ListsAndNotesView({super.key});

  @override
  State<ListsAndNotesView> createState() => _ListsAndNotesViewState();
}

class _ListsAndNotesViewState extends State<ListsAndNotesView> {
  final entry = TextEditingController();

  @override
  void dispose() {
    entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final showingLists = app.listMode == 'listas';
    return _ScrollPage(
      children: [
        Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Listas',
                selected: showingLists,
                onTap: () => app.setListMode('listas'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentButton(
                label: 'Notas',
                selected: !showingLists,
                onTap: () => app.setListMode('notas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: entry,
                decoration: InputDecoration(
                  hintText: showingLists ? 'Nova lista...' : 'Nova nota...',
                ),
                onSubmitted: (_) => _submit(app, showingLists),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _submit(app, showingLists),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: showingLists
              ? Column(
                  key: const ValueKey('lists'),
                  children: [
                    for (final list in app.lists) ...[
                      Dismissible(
                        key: ValueKey('list-${list.id}'),
                        direction: DismissDirection.endToStart,
                        background: const _SwipeDeleteBackground(),
                        confirmDismiss: (_) => _confirmDestructiveAction(
                          context,
                          title: 'Excluir lista?',
                          message: 'A lista "${list.title}" sera removida.',
                        ),
                        onDismissed: (_) => app.deleteList(list.id),
                        child: AuraListTile(
                          icon: Icons.checklist_rounded,
                          title: list.title,
                          subtitle: '${list.items.length} itens',
                          onTap: () => app.selectList(list.id),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                )
              : Column(
                  key: const ValueKey('notes'),
                  children: [
                    for (final note in app.notes) ...[
                      Dismissible(
                        key: ValueKey('note-${note.id}'),
                        direction: DismissDirection.endToStart,
                        background: const _SwipeDeleteBackground(),
                        confirmDismiss: (_) => _confirmDestructiveAction(
                          context,
                          title: 'Excluir nota?',
                          message: 'A nota "${note.title}" sera removida.',
                        ),
                        onDismissed: (_) => app.deleteNote(note.id),
                        child: AuraListTile(
                          icon: Icons.sticky_note_2_rounded,
                          title: note.title,
                          subtitle: note.preview,
                          color: const Color(0xFFFACC15),
                          onTap: () => app.selectNote(note.id),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  void _submit(AuraController app, bool showingLists) {
    if (showingLists) {
      app.addList(entry.text);
    } else {
      app.addNote(entry.text);
    }
    entry.clear();
  }
}

class ListItemsView extends StatefulWidget {
  const ListItemsView({super.key});

  @override
  State<ListItemsView> createState() => _ListItemsViewState();
}

class _ListItemsViewState extends State<ListItemsView> {
  final item = TextEditingController();
  late TextEditingController title;
  String? listId;

  @override
  void initState() {
    super.initState();
    title = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final list = AuraScope.of(context).selectedList;
    if (list != null && list.id != listId) {
      listId = list.id;
      title.text = list.title;
    }
  }

  @override
  void dispose() {
    item.dispose();
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final list = app.selectedList;
    if (list == null) return const Center(child: Text('Lista não encontrada'));
    return _ScrollPage(
      children: [
        TextField(
          controller: title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Nome da lista',
          ),
          onSubmitted: app.renameSelectedList,
          onEditingComplete: () => app.renameSelectedList(title.text),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: item,
                decoration: const InputDecoration(hintText: 'Novo item'),
                onSubmitted: (_) => _addItem(app),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _addItem(app),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Column(
            children: [
              for (final entry in list.items) ...[
                Dismissible(
                  key: ValueKey('list-item-${entry.id}'),
                  direction: DismissDirection.endToStart,
                  background: const _SwipeDeleteBackground(),
                  confirmDismiss: (_) => _confirmDestructiveAction(
                    context,
                    title: 'Excluir item?',
                    message: 'O item "${entry.text}" sera removido.',
                  ),
                  onDismissed: (_) => app.deleteListItem(entry.id),
                  child: AuraSection(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: entry.checked,
                          onChanged: (_) => app.toggleListItem(entry.id),
                          activeColor: AuraColors.cyan500,
                        ),
                        Expanded(
                          child: Text(
                            entry.text,
                            style: TextStyle(
                              color: entry.checked
                                  ? AuraColors.zinc500
                                  : AuraColors.zinc100,
                              decoration: entry.checked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _addItem(AuraController app) {
    app.addListItem(item.text);
    item.clear();
  }
}

class NoteEditView extends StatefulWidget {
  const NoteEditView({super.key});

  @override
  State<NoteEditView> createState() => _NoteEditViewState();
}

class _NoteEditViewState extends State<NoteEditView> {
  late TextEditingController title;
  late TextEditingController body;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final note = AuraScope.of(context).selectedNote;
    title = TextEditingController(text: note?.title ?? '');
    body = TextEditingController(text: note?.preview ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraTextField(
          label: 'Título',
          hint: 'Título da nota',
          controller: title,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: body,
          maxLines: 8,
          decoration: const InputDecoration(hintText: 'Escreva sua nota...'),
        ),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Salvar Nota',
          onPressed: () => app.updateNote(title.text, body.text),
        ),
      ],
    );
  }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final reminder = TextEditingController();

  static const monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  void dispose() {
    reminder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final month = app.calendarMonth;
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayIndex = firstDay.weekday % 7;
    final selected = app.selectedCalendarDate;
    final selectedReminders = app.selectedDateReminders;
    final holiday = app.selectedDateHoliday;

    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: app.previousCalendarMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${monthNames[month.month - 1]} ${month.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AuraColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: app.nextCalendarMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final day in weekDays)
                    Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AuraColors.zinc500,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                itemCount: firstDayIndex + daysInMonth,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  if (index < firstDayIndex) {
                    return const SizedBox.shrink();
                  }

                  final day = index - firstDayIndex + 1;
                  final date = DateTime(month.year, month.month, day);
                  final isSelected = _sameDate(date, selected);
                  final isToday = _sameDate(date, app.today);
                  final dateHoliday = app.holidayFor(date);
                  final hasReminder = app.reminders[date]?.isNotEmpty ?? false;
                  final color = dateHoliday != null
                      ? const Color(0xFFF87171)
                      : isToday
                      ? AuraColors.cyan400
                      : AuraColors.zinc300;

                  return InkWell(
                    onTap: () => app.selectCalendarDate(date),
                    borderRadius: BorderRadius.circular(AuraRadii.full),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AuraColors.cyan500
                            : AuraColors.zinc800.withValues(alpha: 0.34),
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: AuraColors.cyan500)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? AuraColors.black : color,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: hasReminder || dateHoliday != null ? 4 : 0,
                            height: hasReminder || dateHoliday != null ? 4 : 0,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AuraColors.black
                                  : dateHoliday != null
                                  ? const Color(0xFFF87171)
                                  : AuraColors.cyan400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (holiday != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(AuraRadii.lg),
                    border: Border.all(
                      color: const Color(0xFFF87171).withValues(alpha: 0.34),
                    ),
                  ),
                  child: Text(
                    holiday,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lembretes de ${selected.day}/${selected.month}',
                style: const TextStyle(
                  color: AuraColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (selectedReminders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Nenhum lembrete marcado.',
                      style: TextStyle(color: AuraColors.zinc500),
                    ),
                  ),
                )
              else
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Column(
                    children: [
                      for (final item in selectedReminders) ...[
                        Dismissible(
                          key: ValueKey(
                            'reminder-${selected.toIso8601String()}-${item.id}',
                          ),
                          direction: DismissDirection.endToStart,
                          background: const _SwipeDeleteBackground(),
                          confirmDismiss: (_) => _confirmDestructiveAction(
                            context,
                            title: 'Excluir lembrete?',
                            message: 'O lembrete "${item.text}" sera removido.',
                          ),
                          onDismissed: (_) =>
                              app.deleteReminder(selected, item.id),
                          child: AuraListTile(
                            icon: Icons.event_rounded,
                            title: item.text,
                            subtitle: _reminderSubtitle(item),
                            onTap: () => app.selectReminder(selected, item),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: reminder,
                      decoration: const InputDecoration(
                        hintText: 'Adicionar lembrete...',
                      ),
                      onSubmitted: (_) => _addReminder(app),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _addReminder(app),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addReminder(AuraController app) {
    app.addReminderForSelectedDate(reminder.text);
    reminder.clear();
  }

  String _reminderSubtitle(AuraReminder item) {
    final timeLabel = item.time == null
        ? 'Sem horario'
        : item.endTime == null
        ? item.time!
        : '${item.time} - ${item.endTime}';
    final parts = <String>[
      timeLabel,
      if (item.repeat != 'none') 'repete ${item.repeat}',
      if (item.alertMinutesBefore > 0) '${item.alertMinutesBefore} min antes',
      item.active ? 'ativo' : 'pausado',
    ];
    return parts.join(' • ');
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class ReminderEditView extends StatefulWidget {
  const ReminderEditView({super.key});

  @override
  State<ReminderEditView> createState() => _ReminderEditViewState();
}

class _ReminderEditViewState extends State<ReminderEditView> {
  final text = TextEditingController();
  final time = TextEditingController();
  final endTime = TextEditingController();
  DateTime? reminderDate;
  String? reminderId;
  String repeat = 'none';
  int alertMinutesBefore = 0;
  bool active = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AuraScope.of(context);
    final reminder = app.selectedReminder;
    if (reminder?.id == reminderId) return;
    reminderId = reminder?.id;
    text.text = reminder?.text ?? '';
    time.text = reminder?.time ?? '';
    endTime.text = reminder?.endTime ?? '';
    repeat = reminder?.repeat ?? 'none';
    alertMinutesBefore = reminder?.alertMinutesBefore ?? 0;
    active = reminder?.active ?? true;
    reminderDate = app.selectedReminderDate ?? app.selectedCalendarDate;
  }

  @override
  void dispose() {
    text.dispose();
    time.dispose();
    endTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final date = reminderDate ?? app.selectedCalendarDate;
    return _ScrollPage(
      children: [
        AuraTextField(
          label: 'Lembrete',
          hint: 'Texto do lembrete',
          controller: text,
        ),
        const SizedBox(height: 16),
        AuraTextField(label: 'Horário', hint: '14:00', controller: time),
        const SizedBox(height: 16),
        AuraTextField(label: 'Fim', hint: '15:00', controller: endTime),
        const SizedBox(height: 16),
        const Text('Repetir'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in const {
              'none': 'Nao repetir',
              'daily': 'Diario',
              'weekly': 'Semanal',
              'monthly': 'Mensal',
            }.entries)
              ChoiceChip(
                label: Text(option.value),
                selected: repeat == option.key,
                onSelected: (_) => setState(() => repeat = option.key),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Avisar antes'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in const {
              0: 'Na hora',
              5: '5 min',
              15: '15 min',
              30: '30 min',
            }.entries)
              ChoiceChip(
                label: Text(option.value),
                selected: alertMinutesBefore == option.key,
                onSelected: (_) =>
                    setState(() => alertMinutesBefore = option.key),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _FullWidthToggleTile(
          icon: Icons.notifications_active_rounded,
          title: 'Lembrete ativo',
          value: active,
          onChanged: (value) => setState(() => active = value),
        ),
        const SizedBox(height: 16),
        AuraListTile(
          icon: Icons.calendar_month_rounded,
          title: '${date.day}/${date.month}/${date.year}',
          subtitle: 'Tocar para trocar a data',
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(DateTime.now().year - 2),
              lastDate: DateTime(DateTime.now().year + 5),
            );
            if (picked != null) {
              setState(() => reminderDate = picked);
            }
          },
        ),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Salvar Lembrete',
          onPressed: () => app.updateReminder(
            text.text,
            time.text,
            date,
            endTime.text,
            repeat,
            alertMinutesBefore,
            active,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: app.selectedReminder == null
              ? null
              : () async {
                  final confirmed = await _confirmDestructiveAction(
                    context,
                    title: 'Excluir lembrete?',
                    message: 'Este lembrete sera removido.',
                  );
                  if (!context.mounted || !confirmed) return;
                  app.deleteReminder(date, app.selectedReminder!.id);
                },
          icon: const Icon(Icons.delete_rounded),
          label: const Text('Excluir Lembrete'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

class AlarmsView extends StatelessWidget {
  const AlarmsView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final alarmsMode = app.alarmMode == 'alarmes';
    final timersMode = app.alarmMode == 'timers';
    final stopwatchMode = app.alarmMode == 'cronometro';
    return _ScrollPage(
      children: [
        Row(
          children: [
            Expanded(
              child: _SegmentButton(
                label: 'Alarmes',
                selected: alarmsMode,
                onTap: () => app.setAlarmMode('alarmes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentButton(
                label: 'Timer',
                selected: timersMode,
                onTap: () => app.setAlarmMode('timers'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentButton(
                label: 'Cronômetro',
                selected: stopwatchMode,
                onTap: () => app.setAlarmMode('cronometro'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _SegmentButton(
            label: 'Relogio global',
            selected: app.alarmMode == 'global',
            onTap: () => app.setAlarmMode('global'),
          ),
        ),
        const SizedBox(height: 20),
        if (alarmsMode || timersMode) ...[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.filled(
              onPressed: () => app.go(AuraRoute.moreAlarmNew),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: alarmsMode
              ? _AlarmList(app: app)
              : timersMode
              ? _TimerList(app: app)
              : stopwatchMode
              ? _StopwatchPanel(app: app)
              : _WorldClockPanel(app: app),
        ),
      ],
    );
  }
}

class _AlarmList extends StatelessWidget {
  const _AlarmList({required this.app});

  final AuraController app;

  @override
  Widget build(BuildContext context) {
    if (app.alarms.isEmpty) {
      return _EmptyState(
        icon: Icons.alarm_add_rounded,
        title: 'Nenhum alarme ainda',
        subtitle: 'Crie seu primeiro alarme com nome, dias e som.',
        action: 'Criar alarme',
        onTap: () => app.go(AuraRoute.moreAlarmNew),
      );
    }
    return AnimatedSize(
      key: const ValueKey('alarms'),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Column(
        children: [
          for (final alarm in app.alarms) ...[
            Dismissible(
              key: ValueKey('alarm-${alarm.id}'),
              direction: DismissDirection.endToStart,
              background: const _SwipeDeleteBackground(),
              confirmDismiss: (_) => _confirmDestructiveAction(
                context,
                title: 'Excluir alarme?',
                message: 'O alarme das ${alarm.time} sera removido.',
              ),
              onDismissed: (_) => app.deleteAlarm(alarm.id),
              child: AuraListTile(
                icon: Icons.alarm_rounded,
                title: alarm.time,
                subtitle: '${alarm.label} • ${_nextAlarmLabel(alarm)}',
                trailing: AuraSwitch(
                  value: alarm.active,
                  onChanged: (_) => app.toggleAlarm(alarm.id),
                ),
                onTap: () => app.selectAlarm(alarm.id),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  String _nextAlarmLabel(AuraAlarm alarm) {
    if (!alarm.active) return 'Desativado';
    final next = alarm.nextOccurrence();
    final today = DateTime.now();
    final sameDay =
        next.day == today.day &&
        next.month == today.month &&
        next.year == today.year;
    return 'Próximo ${sameDay ? 'hoje' : 'amanhã'} às ${alarm.time}';
  }
}

class _TimerList extends StatelessWidget {
  const _TimerList({required this.app});

  final AuraController app;

  @override
  Widget build(BuildContext context) {
    if (app.timers.isEmpty) {
      return _EmptyState(
        icon: Icons.timer_outlined,
        title: 'Nenhum timer criado',
        subtitle: 'Adicione timers com presets, som e duracao personalizada.',
        action: 'Criar timer',
        onTap: () => app.go(AuraRoute.moreAlarmNew),
      );
    }
    AuraTimerItem? activeTimer;
    for (final timer in app.timers) {
      if (timer.active) {
        activeTimer = timer;
        break;
      }
    }

    return AnimatedSize(
      key: const ValueKey('timers'),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activeTimer != null) ...[
            AuraSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('active_timer'),
                    style: const TextStyle(
                      color: AuraColors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    activeTimer.label,
                    style: const TextStyle(
                      color: AuraColors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activeTimer.duration,
                    style: const TextStyle(
                      color: AuraColors.cyan400,
                      fontWeight: FontWeight.w900,
                      fontSize: 54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => app.toggleTimer(activeTimer!.id),
                          icon: const Icon(Icons.pause_rounded),
                          label: Text(context.tr('pause')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          // CORREÇÃO: Adicionado o operador '!' para garantir a não-nulidade na closure
                          onPressed: () => app.resetTimer(activeTimer!.id),
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: Text(context.tr('reset')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          for (final timer in app.timers) ...[
            Dismissible(
              key: ValueKey('timer-${timer.id}'),
              direction: DismissDirection.endToStart,
              background: const _SwipeDeleteBackground(),
              confirmDismiss: (_) => _confirmDestructiveAction(
                context,
                title: 'Excluir timer?',
                message: 'O timer "${timer.label}" sera removido.',
              ),
              onDismissed: (_) => app.deleteTimer(timer.id),
              child: AuraListTile(
                icon: timer.active
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_fill_rounded,
                title: timer.duration,
                subtitle: _timerSubtitle(timer),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => app.toggleTimer(timer.id),
                      icon: Icon(
                        timer.active
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      color: timer.active
                          ? const Color(0xFFF87171)
                          : AuraColors.cyan400,
                    ),
                    IconButton(
                      onPressed: () => app.resetTimer(timer.id),
                      icon: const Icon(Icons.restart_alt_rounded),
                      color: AuraColors.zinc400,
                    ),
                  ],
                ),
                onTap: () => app.toggleTimer(timer.id),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  String _timerSubtitle(AuraTimerItem timer) {
    if (timer.completed) {
      return '${timer.label} • finalizado ha ${AuraTimerItem.formatDuration(timer.elapsedAfterFinishSeconds)}';
    }
    if (timer.active) return '${timer.label} • rodando';
    return '${timer.label} • duração ${timer.totalDuration}';
  }
}

class _ClockActionButton extends StatelessWidget {
  const _ClockActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
    final style = filled
        ? FilledButton.styleFrom(
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          )
        : OutlinedButton.styleFrom(
            minimumSize: const Size(0, 46),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
    return filled
        ? FilledButton(onPressed: onPressed, style: style, child: content)
        : OutlinedButton(onPressed: onPressed, style: style, child: content);
  }
}

class _StopwatchPanel extends StatelessWidget {
  const _StopwatchPanel({required this.app});

  final AuraController app;

  @override
  Widget build(BuildContext context) {
    return AuraSection(
      key: const ValueKey('stopwatch'),
      child: Column(
        children: [
          const Icon(Icons.timer_rounded, color: AuraColors.cyan400, size: 42),
          const SizedBox(height: 16),
          Text(
            app.stopwatch.displayTime,
            style: const TextStyle(
              color: AuraColors.white,
              fontSize: 46,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ClockActionButton(
                  onPressed: app.resetStopwatch,
                  icon: Icons.restart_alt_rounded,
                  label: 'Zerar',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClockActionButton(
                  onPressed: app.toggleStopwatch,
                  icon: app.stopwatch.active
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: app.stopwatch.active ? 'Pausar' : 'Iniciar',
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ClockActionButton(
                  onPressed: app.lapStopwatch,
                  icon: Icons.flag_rounded,
                  label: 'Volta',
                ),
              ),
            ],
          ),
          if (app.stopwatch.laps.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final lap in app.stopwatch.laps.take(5)) ...[
              AuraListTile(
                icon: Icons.flag_rounded,
                title: AuraTimerItem.formatDuration(lap),
                subtitle: 'Volta registrada',
                trailing: const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _WorldClockPanel extends StatelessWidget {
  const _WorldClockPanel({required this.app});

  final AuraController app;

  @override
  Widget build(BuildContext context) {
    final selected = app.selectedWorldClock;
    final selectedTime = _clockTime(selected);
    return AuraSection(
      key: const ValueKey('world-clock'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                color: AuraColors.cyan400,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.city,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${selected.country} • UTC ${_offsetLabel(selected.utcOffsetMinutes)}',
                      style: const TextStyle(color: AuraColors.zinc400),
                    ),
                  ],
                ),
              ),
              Text(
                _formatClockTime(selectedTime),
                style: const TextStyle(
                  color: AuraColors.cyan400,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Escolha seu pais ou cidade',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final clock in app.worldClocks) ...[
            AuraListTile(
              icon: clock.id == selected.id
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              title: clock.city,
              subtitle:
                  '${clock.country} • ${_formatClockTime(_clockTime(clock))}',
              trailing: Text(
                'UTC ${_offsetLabel(clock.utcOffsetMinutes)}',
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              onTap: () => app.setWorldClock(clock.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  DateTime _clockTime(AuraWorldClock clock) {
    return DateTime.now().toUtc().add(
      Duration(minutes: clock.utcOffsetMinutes),
    );
  }

  String _formatClockTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _offsetLabel(int minutes) {
    final sign = minutes >= 0 ? '+' : '-';
    final absolute = minutes.abs();
    final hour = (absolute ~/ 60).toString().padLeft(2, '0');
    final minute = (absolute % 60).toString().padLeft(2, '0');
    return '$sign$hour:$minute';
  }
}

class AlarmFormView extends StatefulWidget {
  const AlarmFormView({super.key, this.editing = false});

  final bool editing;

  @override
  State<AlarmFormView> createState() => _AlarmFormViewState();
}

class _AlarmFormViewState extends State<AlarmFormView> {
  final time = TextEditingController();
  final label = TextEditingController();
  final name = TextEditingController(text: 'Alarme');
  final selectedDays = <String>{'Seg', 'Ter', 'Qua', 'Qui', 'Sex'};
  String tone = 'Radar';
  int snoozeMinutes = 10;
  bool vibrate = true;
  int volume = 100;
  int ringDurationSeconds = 90;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final app = AuraScope.of(context);
    final alarm = app.selectedAlarm;
    final timerMode = app.alarmMode == 'timers' && !widget.editing;
    time.text = widget.editing
        ? alarm?.time ?? '07:00'
        : timerMode
        ? '15:00'
        : '08:00';
    label.text = widget.editing
        ? alarm?.label ?? 'Todos os dias'
        : timerMode
        ? 'Novo Timer'
        : 'Todos os dias';
    name.text = widget.editing ? alarm?.name ?? 'Alarme' : 'Alarme';
    tone = widget.editing ? alarm?.tone ?? 'Radar' : app.ringtone;
    if (widget.editing && alarm != null) {
      selectedDays
        ..clear()
        ..addAll(alarm.days);
      snoozeMinutes = alarm.snoozeMinutes;
      vibrate = alarm.vibrate;
      volume = alarm.volume;
      ringDurationSeconds = alarm.ringDurationSeconds;
    }
  }

  @override
  void dispose() {
    time.dispose();
    label.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final timerMode = app.alarmMode == 'timers' && !widget.editing;
    return _ScrollPage(
      children: [
        if (!timerMode) ...[
          AuraTextField(
            label: 'Nome do alarme',
            hint: 'Acordar',
            controller: name,
          ),
          const SizedBox(height: 16),
        ],
        AuraTextField(
          label: timerMode ? 'Duração' : 'Horário',
          hint: timerMode ? '15:00' : '08:00',
          controller: time,
        ),
        const SizedBox(height: 10),
        if (!timerMode)
          OutlinedButton.icon(
            onPressed: () async {
              final parts = time.text.split(':');
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: int.tryParse(parts.first) ?? 8,
                  minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(alwaysUse24HourFormat: true),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
              if (picked == null) return;
              time.text =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              setState(() {});
            },
            icon: const Icon(Icons.access_time_rounded),
            label: const Text('Escolher horário em 24h'),
          ),
        if (timerMode)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in const {
                '00:05:00': '5 min',
                '00:15:00': '15 min',
                '00:25:00': '25 min',
                '01:00:00': '1 h',
              }.entries)
                ActionChip(
                  label: Text(preset.value),
                  onPressed: () => setState(() => time.text = preset.key),
                ),
            ],
          ),
        const SizedBox(height: 16),
        AuraTextField(
          label: timerMode ? 'Nome' : 'Repetição',
          hint: timerMode ? 'Pizza' : 'Todos os dias',
          controller: label,
        ),
        if (!timerMode) ...[
          const SizedBox(height: 16),
          const Text('Dias da semana'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final day in const [
                'Dom',
                'Seg',
                'Ter',
                'Qua',
                'Qui',
                'Sex',
                'Sáb',
              ])
                FilterChip(
                  label: Text(day),
                  selected: selectedDays.contains(day),
                  onSelected: (selected) => setState(() {
                    selected ? selectedDays.add(day) : selectedDays.remove(day);
                    label.text = selectedDays.isEmpty
                        ? 'Uma vez'
                        : selectedDays.join(', ');
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Toque do alarme'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final item in app.notificationTones)
                ChoiceChip(
                  label: Text(item.title),
                  selected:
                      tone == item.id ||
                      (item.systemPicker && tone.startsWith('system:')),
                  onSelected: (_) async {
                    if (item.systemPicker) {
                      final picked =
                          await AuraPlatformService.pickSystemRingtone();
                      if (picked == null) return;
                      setState(() => tone = picked);
                      await AuraPlatformService.previewTone(picked);
                    } else {
                      setState(() => tone = item.id);
                      await AuraPlatformService.previewTone(item.id);
                    }
                  },
                ),
              ChoiceChip(
                label: const Text('Spotify'),
                selected: tone == 'Spotify',
                onSelected: (_) => setState(() => tone = 'Spotify'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Soneca: $snoozeMinutes min'),
          Slider(
            value: snoozeMinutes.toDouble(),
            min: 5,
            max: 30,
            divisions: 5,
            label: '$snoozeMinutes min',
            onChanged: (value) => setState(() => snoozeMinutes = value.round()),
          ),
          Text('Volume ao despertar: $volume%'),
          Slider(
            value: volume.toDouble(),
            min: 20,
            max: 100,
            divisions: 8,
            label: '$volume%',
            onChanged: (value) => setState(() => volume = value.round()),
          ),
          Text('Toque real: ${ringDurationSeconds}s'),
          Slider(
            value: ringDurationSeconds.toDouble(),
            min: 30,
            max: 180,
            divisions: 5,
            label: '${ringDurationSeconds}s',
            onChanged: (value) =>
                setState(() => ringDurationSeconds = value.round()),
          ),
          _FullWidthToggleTile(
            icon: Icons.vibration_rounded,
            title: 'Vibrar ao despertar',
            value: vibrate,
            onChanged: (value) => setState(() => vibrate = value),
          ),
        ],
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: widget.editing
              ? 'Salvar Alarme'
              : timerMode
              ? 'Adicionar Timer'
              : 'Adicionar Alarme',
          onPressed: () => widget.editing
              ? app.updateAlarm(
                  time.text,
                  label.text,
                  name: name.text,
                  days: selectedDays.toList(),
                  tone: tone,
                  source: tone == 'Spotify' ? 'Spotify' : 'Aura',
                  snoozeMinutes: snoozeMinutes,
                  vibrate: vibrate,
                  volume: volume,
                  ringDurationSeconds: ringDurationSeconds,
                )
              : timerMode
              ? app.addTimer(time.text, label.text)
              : app.addAlarm(
                  time.text,
                  label.text,
                  name: name.text,
                  days: selectedDays.toList(),
                  tone: tone,
                  source: tone == 'Spotify' ? 'Spotify' : 'Aura',
                  snoozeMinutes: snoozeMinutes,
                  vibrate: vibrate,
                  volume: volume,
                  ringDurationSeconds: ringDurationSeconds,
                ),
        ),
        if (widget.editing) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmDestructiveAction(
                context,
                title: 'Excluir alarme?',
                message: 'Este alarme sera removido.',
              );
              if (!context.mounted || !confirmed) return;
              app.deleteAlarm(app.selectedAlarmId);
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Excluir Alarme'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

class SkillsView extends StatelessWidget {
  const SkillsView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        for (final skill in app.skills) ...[
          AuraListTile(
            icon: skill.icon,
            title: skill.title,
            subtitle: skill.subtitle,
            color: skill.color,
            trailing: AuraSwitch(
              value: skill.permission,
              onChanged: (_) => app.toggleSkill(skill.id),
            ),
            onTap: () => app.openSkillLogin(skill.id),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.devices_rounded,
          title: 'Configurações do Dispositivo',
          onTap: () => app.go(AuraRoute.moreConfigDevice),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.notifications_rounded,
          title: 'Notificações',
          onTap: () => app.go(AuraRoute.moreConfigNotifications),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.account_circle_rounded,
          title: 'Contas e Perfis',
          onTap: () => app.go(AuraRoute.moreConfigAccounts),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.lock_rounded,
          title: 'Privacidade da Conta',
          onTap: () => app.go(AuraRoute.profilePrivacy),
        ),
      ],
    );
  }
}

class ConfigDeviceView extends StatelessWidget {
  const ConfigDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.wifi_rounded,
          title: 'Rede Wi-Fi',
          onTap: () => app.go(AuraRoute.moreConfigWifi),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.bluetooth_rounded,
          title: 'Bluetooth e Zigbee',
          onTap: () => app.go(AuraRoute.moreConfigBluetooth),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.brightness_6_rounded,
          title: 'Tela e Brilho',
          onTap: () => app.go(AuraRoute.moreConfigDisplay),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.language_rounded,
          title: 'Idioma da Aura',
          onTap: () => app.go(AuraRoute.moreConfigLanguage),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.settings_input_component_rounded,
          title: 'Dispositivos',
          onTap: () => app.go(AuraRoute.moreConfigDeviceSettings),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.add_circle_rounded,
          title: 'Adicionar novo dispositivo',
          onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
        ),
      ],
    );
  }
}

class DeviceAddView extends StatefulWidget {
  const DeviceAddView({super.key});

  @override
  State<DeviceAddView> createState() => _DeviceAddViewState();
}

class _DeviceAddViewState extends State<DeviceAddView> {
  final name = TextEditingController();
  final room = TextEditingController();
  final manufacturer = TextEditingController();
  final model = TextEditingController();
  AuraDeviceType type = AuraDeviceType.light;
  AuraConnectionType connection = AuraConnectionType.wifi;
  bool supportsColor = true;
  bool supportsDimming = true;

  @override
  void dispose() {
    name.dispose();
    room.dispose();
    manufacturer.dispose();
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraTextField(
          label: 'Nome do dispositivo',
          hint: 'Ex: Luz da mesa',
          controller: name,
        ),
        const SizedBox(height: 16),
        AuraTextField(label: 'Cômodo', hint: 'Ex: Quarto', controller: room),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Marca',
          hint: 'Ex: Philips, Samsung, Intelbras',
          controller: manufacturer,
        ),
        const SizedBox(height: 16),
        AuraTextField(
          label: 'Modelo',
          hint: 'Ex: Hue E27, Smart Plug Mini',
          controller: model,
        ),
        const SizedBox(height: 16),
        const Text(
          'Tipo de aparelho',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in AuraDeviceType.values)
              ChoiceChip(
                label: Text(_deviceTypeName(option)),
                selected: type == option,
                onSelected: (_) => setState(() {
                  type = option;
                  if (type != AuraDeviceType.light) supportsColor = false;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Conexão', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final option in AuraConnectionType.values)
              ChoiceChip(
                label: Text(_connectionName(option)),
                selected: connection == option,
                onSelected: (_) => setState(() => connection = option),
              ),
          ],
        ),
        if (type == AuraDeviceType.light) ...[
          const SizedBox(height: 16),
          _FullWidthToggleTile(
            icon: Icons.palette_rounded,
            title: 'Tem cores RGB',
            subtitle: 'Mostra paleta de cores nas configuracoes',
            value: supportsColor,
            onChanged: (value) => setState(() => supportsColor = value),
          ),
          const SizedBox(height: 10),
          _FullWidthToggleTile(
            icon: Icons.tune_rounded,
            title: 'Permite dimmer',
            subtitle: 'Mostra controle de intensidade',
            value: supportsDimming,
            onChanged: (value) => setState(() => supportsDimming = value),
          ),
        ],
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Adicionar dispositivo',
          onPressed: () => app.addDevice(
            name.text,
            room.text,
            type,
            connection: connection,
            manufacturer: manufacturer.text,
            model: model.text,
            supportsColor: supportsColor,
            supportsDimming: supportsDimming,
          ),
        ),
      ],
    );
  }

  String _connectionName(AuraConnectionType value) {
    return switch (value) {
      AuraConnectionType.wifi => 'Wi-Fi',
      AuraConnectionType.bluetooth => 'Bluetooth',
      AuraConnectionType.zigbee => 'Zigbee',
    };
  }

  String _deviceTypeName(AuraDeviceType value) {
    return switch (value) {
      AuraDeviceType.light => 'Lâmpada',
      AuraDeviceType.tv => 'TV',
      AuraDeviceType.speaker => 'Som',
      AuraDeviceType.ac => 'Ar-condicionado',
      AuraDeviceType.plug => 'Tomada',
      AuraDeviceType.camera => 'Câmera',
      AuraDeviceType.lock => 'Fechadura',
      AuraDeviceType.sensor => 'Sensor',
      AuraDeviceType.curtain => 'Cortina',
      AuraDeviceType.vacuum => 'Aspirador',
      AuraDeviceType.thermostat => 'Termostato',
      AuraDeviceType.hub => 'Hub Zigbee',
    };
  }
}

class DeviceAddFlowView extends StatefulWidget {
  const DeviceAddFlowView({super.key});

  @override
  State<DeviceAddFlowView> createState() => _DeviceAddFlowViewState();
}

class _DeviceAddFlowViewState extends State<DeviceAddFlowView> {
  final name = TextEditingController();
  AuraDeviceType type = AuraDeviceType.light;
  String room = 'Quarto';
  String brand = '';
  String model = '';
  Set<AuraConnectionType> connections = {AuraConnectionType.wifi};
  bool supportsColor = true;
  bool supportsDimming = true;

  @override
  void initState() {
    super.initState();
    _syncBrandAndModel();
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final brands = _brandsFor(type);
    final models = _modelsFor(type, brand);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.memory_rounded,
          title: 'Adicionar EcoMind',
          subtitle: 'Hub Aura com Bluetooth, Wi-Fi e luz de status',
          color: AuraColors.purple400,
          trailing: const Icon(Icons.add_circle_rounded),
          onTap: () => app.addDevice(
            'EcoMind',
            'Casa inteira',
            AuraDeviceType.hub,
            connections: const {
              AuraConnectionType.bluetooth,
              AuraConnectionType.wifi,
            },
            manufacturer: 'Aura Mind',
            model: 'Eco Mind',
            supportsColor: false,
            supportsDimming: true,
          ),
        ),
        const SizedBox(height: 18),
        AuraTextField(
          label: 'Nome do dispositivo',
          hint: 'Ex: Luz da mesa',
          controller: name,
        ),
        const SizedBox(height: 16),
        _DropdownField<AuraDeviceType>(
          label: 'Tipo de aparelho',
          value: type,
          values: AuraDeviceType.values,
          itemLabel: _deviceTypeName,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              type = value;
              supportsColor = type == AuraDeviceType.light;
              supportsDimming = true;
              _syncBrandAndModel();
            });
          },
        ),
        const SizedBox(height: 16),
        _DropdownField<String>(
          label: 'Comodo',
          value: room,
          values: _rooms,
          itemLabel: (value) => value,
          onChanged: (value) => setState(() => room = value ?? room),
        ),
        const SizedBox(height: 16),
        _DropdownField<String>(
          label: 'Marca',
          value: brand,
          values: brands,
          itemLabel: (value) => value,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              brand = value;
              model = _modelsFor(type, brand).first;
            });
          },
        ),
        const SizedBox(height: 16),
        _DropdownField<String>(
          label: 'Modelo',
          value: models.contains(model) ? model : models.first,
          values: models,
          itemLabel: (value) => value,
          onChanged: (value) => setState(() => model = value ?? model),
        ),
        const SizedBox(height: 16),
        const Text('Conexoes', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in AuraConnectionType.values)
              FilterChip(
                label: Text(option.label),
                selected: connections.contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      connections.add(option);
                    } else if (connections.length > 1) {
                      connections.remove(option);
                    }
                  });
                },
              ),
          ],
        ),
        if (type == AuraDeviceType.light) ...[
          const SizedBox(height: 16),
          _FullWidthToggleTile(
            icon: Icons.palette_rounded,
            title: 'Tem cores RGB',
            subtitle: 'Mostra paleta de cores nas configuracoes',
            value: supportsColor,
            onChanged: (value) => setState(() => supportsColor = value),
          ),
          const SizedBox(height: 10),
          _FullWidthToggleTile(
            icon: Icons.tune_rounded,
            title: 'Permite dimmer',
            subtitle: 'Mostra controle de intensidade',
            value: supportsDimming,
            onChanged: (value) => setState(() => supportsDimming = value),
          ),
        ],
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Adicionar dispositivo',
          onPressed: () => app.addDevice(
            name.text.trim().isEmpty ? '$brand $model' : name.text,
            room,
            type,
            connections: connections,
            manufacturer: brand,
            model: model,
            supportsColor: supportsColor,
            supportsDimming: supportsDimming,
          ),
        ),
      ],
    );
  }

  void _syncBrandAndModel() {
    final brands = _brandsFor(type);
    brand = brands.first;
    model = _modelsFor(type, brand).first;
  }

  static const _rooms = [
    'Quarto',
    'Sala',
    'Cozinha',
    'Banheiro',
    'Escritorio',
    'Garagem',
    'Varanda',
    'Area de servico',
    'Corredor',
    'Casa inteira',
  ];

  List<String> _brandsFor(AuraDeviceType type) {
    return switch (type) {
      AuraDeviceType.light => [
        'Philips Hue',
        'Positivo',
        'Intelbras',
        'Elgin',
        'Tuya',
      ],
      AuraDeviceType.tv => ['Samsung', 'LG', 'TCL', 'Sony', 'Philips'],
      AuraDeviceType.speaker => [
        'JBL',
        'Amazon Echo',
        'Google Nest',
        'Sony',
        'Bose',
      ],
      AuraDeviceType.ac => ['LG', 'Samsung', 'Midea', 'Elgin', 'Daikin'],
      AuraDeviceType.plug => [
        'Positivo',
        'Intelbras',
        'Tuya',
        'Sonoff',
        'TP-Link',
      ],
      AuraDeviceType.camera => [
        'Intelbras',
        'TP-Link Tapo',
        'Hikvision',
        'Eufy',
        'Tuya',
      ],
      AuraDeviceType.lock => ['Intelbras', 'Yale', 'Samsung', 'Tuya', 'August'],
      AuraDeviceType.sensor => [
        'Aqara',
        'Sonoff',
        'Tuya',
        'Intelbras',
        'Philips Hue',
      ],
      AuraDeviceType.curtain => [
        'Aqara',
        'Tuya',
        'Sonoff',
        'SwitchBot',
        'Intelbras',
      ],
      AuraDeviceType.vacuum => [
        'Xiaomi',
        'iRobot',
        'Eufy',
        'Roborock',
        'Samsung',
      ],
      AuraDeviceType.thermostat => [
        'Nest',
        'Ecobee',
        'Honeywell',
        'Tuya',
        'Aqara',
      ],
      AuraDeviceType.hub => [
        'Aqara',
        'Sonoff',
        'Philips Hue',
        'SmartThings',
        'Tuya',
      ],
    };
  }

  List<String> _modelsFor(AuraDeviceType type, String brand) {
    final generic = switch (type) {
      AuraDeviceType.light => [
        'E27 RGB',
        'GU10 Branco',
        'Fita LED',
        'Painel Smart',
      ],
      AuraDeviceType.tv => ['Smart TV 4K', 'OLED', 'QLED', 'Android TV'],
      AuraDeviceType.speaker => [
        'Bluetooth Speaker',
        'Smart Speaker',
        'Soundbar',
        'Home Theater',
      ],
      AuraDeviceType.ac => [
        'Split Inverter',
        'Janela Smart',
        'Portatil',
        'Cassete',
      ],
      AuraDeviceType.plug => [
        'Smart Plug 10A',
        'Smart Plug 16A',
        'Tomada com medidor',
      ],
      AuraDeviceType.camera => [
        'Camera interna',
        'Camera externa',
        'Video porteiro',
      ],
      AuraDeviceType.lock => [
        'Fechadura digital',
        'Trava smart',
        'Teclado + app',
      ],
      AuraDeviceType.sensor => [
        'Presenca',
        'Porta e janela',
        'Temperatura',
        'Vazamento',
      ],
      AuraDeviceType.curtain => [
        'Motor de cortina',
        'Trilho smart',
        'Persiana smart',
      ],
      AuraDeviceType.vacuum => [
        'Aspirador robo',
        'Robo com mop',
        'Base autolimpante',
      ],
      AuraDeviceType.thermostat => [
        'Termostato Wi-Fi',
        'Termostato Zigbee',
        'Controle HVAC',
      ],
      AuraDeviceType.hub => ['Hub Zigbee 3.0', 'Bridge Pro', 'Matter Hub'],
    };
    return generic.map((model) => '$brand $model').toList();
  }

  String _deviceTypeName(AuraDeviceType value) {
    return switch (value) {
      AuraDeviceType.light => 'Lampada',
      AuraDeviceType.tv => 'TV',
      AuraDeviceType.speaker => 'Som',
      AuraDeviceType.ac => 'Ar-condicionado',
      AuraDeviceType.plug => 'Tomada',
      AuraDeviceType.camera => 'Camera',
      AuraDeviceType.lock => 'Fechadura',
      AuraDeviceType.sensor => 'Sensor',
      AuraDeviceType.curtain => 'Cortina',
      AuraDeviceType.vacuum => 'Aspirador',
      AuraDeviceType.thermostat => 'Termostato',
      AuraDeviceType.hub => 'Hub Zigbee',
    };
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? AuraColors.zinc400 : const Color(0xFF334155),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: [
            for (final option in values)
              DropdownMenuItem<T>(
                value: option,
                child: Text(itemLabel(option), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class DeviceSettingsListView extends StatelessWidget {
  const DeviceSettingsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => app.go(AuraRoute.moreConfigDeviceAdd),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Novo'),
          ),
        ),
        const SizedBox(height: 14),
        if (app.devices.isEmpty)
          _EmptyState(
            icon: Icons.settings_input_component_rounded,
            title: 'Nenhum dispositivo configurado',
            subtitle: 'A pessoa começa do zero e adiciona apenas o que tiver.',
            action: 'Adicionar dispositivo',
            onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
          )
        else
          for (final device in app.devices) ...[
            AuraListTile(
              icon: device.icon,
              title: device.name,
              subtitle: '${device.room} • ${device.connectionLabel}',
              onTap: () => app.openDeviceConfig(device),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class DeviceConfigView extends StatelessWidget {
  const DeviceConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final device = app.selectedDevice;
    if (device == null) {
      return _ScrollPage(
        children: [
          _EmptyState(
            icon: Icons.devices_other_rounded,
            title: 'Nenhum dispositivo selecionado',
            subtitle: 'Adicione um aparelho para abrir as configurações.',
            action: 'Adicionar dispositivo',
            onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
          ),
        ],
      );
    }
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              Icon(device.icon, color: AuraColors.cyan400, size: 72),
              const SizedBox(height: 12),
              Text(
                device.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                device.room,
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 22),
              _FullWidthToggleTile(
                icon: Icons.power_settings_new_rounded,
                title: 'Ligar / Desligar',
                value: device.active,
                onChanged: (_) => app.toggleDevice(device.id),
              ),
              const SizedBox(height: 10),
              AuraListTile(
                icon: Icons.schedule_rounded,
                title: 'Rotinas',
                subtitle: 'Automação diária ativa',
                onTap: () {
                  app.selectedDeviceId = device.id;
                  app.go(AuraRoute.deviceConfigLight1);
                },
              ),
              const SizedBox(height: 10),
              AuraListTile(
                icon: Icons.info_rounded,
                title: 'Informações',
                subtitle: 'Firmware atualizado',
                onTap: () => _showDeviceInfoSheet(context, device),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DeviceConfigUpgradedView extends StatelessWidget {
  const DeviceConfigUpgradedView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final device = app.selectedDevice;
    if (device == null) {
      return _ScrollPage(
        children: [
          _EmptyState(
            icon: Icons.devices_other_rounded,
            title: 'Nenhum dispositivo selecionado',
            subtitle: 'Adicione um aparelho para personalizar as opções.',
            action: 'Adicionar dispositivo',
            onTap: () => app.go(AuraRoute.moreConfigDeviceAdd),
          ),
        ],
      );
    }
    final isEcoMind =
        device.type == AuraDeviceType.hub ||
        device.name.toLowerCase().replaceAll(' ', '').contains('ecomind');
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(device.icon, color: AuraColors.cyan400, size: 72),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${device.room} • ${device.typeLabel} • ${device.connectionLabel}',
                  style: const TextStyle(color: AuraColors.zinc400),
                ),
              ),
              const SizedBox(height: 22),
              _FullWidthToggleTile(
                icon: Icons.power_settings_new_rounded,
                title: 'Ligar / Desligar',
                value: device.active,
                onChanged: (_) => app.toggleDevice(device.id),
              ),
              const SizedBox(height: 16),
              if (isEcoMind) _EcoMindDeviceSettings(app: app, device: device),
              if (!isEcoMind && device.type == AuraDeviceType.light)
                _DeviceLightSettings(app: app, device: device),
              if (!isEcoMind && device.type == AuraDeviceType.tv)
                _DeviceTvSettings(app: app, device: device),
              if (!isEcoMind && device.type == AuraDeviceType.ac)
                _DeviceAcSettings(app: app, device: device),
              if (!isEcoMind && device.type == AuraDeviceType.speaker)
                const Text(
                  'Música, volume e integrações ficam disponíveis na aba Mídia.',
                  style: TextStyle(color: AuraColors.zinc400),
                ),
              if (!isEcoMind &&
                  !{
                    AuraDeviceType.light,
                    AuraDeviceType.tv,
                    AuraDeviceType.ac,
                    AuraDeviceType.speaker,
                  }.contains(device.type))
                _GenericDeviceSettings(app: app, device: device),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DeviceRoutineEditor(app: app, device: device),
        const SizedBox(height: 16),
        AuraSection(
          child: Column(
            children: [
              AuraListTile(
                icon: Icons.info_rounded,
                title: 'Informações',
                subtitle: 'Firmware atualizado • conectado ao Aura Mind',
                onTap: () => _showDeviceInfoSheet(context, device),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await _confirmDestructiveAction(
                    context,
                    title: 'Excluir dispositivo?',
                    message: 'O dispositivo "${device.name}" sera removido.',
                  );
                  if (!context.mounted || !confirmed) return;
                  app.deleteDevice(device.id);
                },
                icon: const Icon(Icons.delete_rounded),
                label: const Text('Excluir dispositivo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceLightSettings extends StatelessWidget {
  const _DeviceLightSettings({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  Widget build(BuildContext context) {
    final colors = [
      0xFFFFFFFF,
      0xFFFFF7A8,
      0xFFFACC15,
      0xFFF97316,
      0xFFEF4444,
      0xFFEC4899,
      0xFFA855F7,
      0xFF6366F1,
      0xFF38BDF8,
      0xFF22C55E,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FullWidthToggleTile(
          icon: Icons.palette_rounded,
          title: 'Tem cores RGB',
          value: device.supportsColor,
          onChanged: (value) =>
              app.updateLightSettings(device.id, supportsColor: value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.tune_rounded,
          title: 'Permite controlar intensidade',
          value: device.supportsDimming,
          onChanged: (value) =>
              app.updateLightSettings(device.id, supportsDimming: value),
        ),
        if (device.supportsDimming) ...[
          Text('Intensidade padrão: ${device.value ?? 80}%'),
          _LargeSliderTile(
            icon: Icons.light_mode_rounded,
            title: 'Intensidade padrao',
            valueText: '${device.value ?? 80}%',
            value: (device.value ?? 80).toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (value) =>
                app.updateLightSettings(device.id, intensity: value.round()),
          ),
        ],
        if (device.supportsColor) ...[
          const Text('Cor da lâmpada'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in colors)
                InkWell(
                  onTap: () =>
                      app.updateLightSettings(device.id, colorHex: color),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: device.colorHex == color
                            ? AuraColors.cyan400
                            : AuraColors.zinc700,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DeviceTvSettings extends StatelessWidget {
  const _DeviceTvSettings({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volume padrão: ${device.tvVolume}%'),
        _LargeSliderTile(
          icon: Icons.volume_up_rounded,
          title: 'Volume padrao',
          valueText: '${device.tvVolume}%',
          value: device.tvVolume.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) =>
              app.updateTvSettings(device.id, volume: value.round()),
        ),
        Row(
          children: [
            const Expanded(child: Text('Canal inicial')),
            IconButton(
              onPressed: () => app.updateTvSettings(
                device.id,
                channel: (device.tvChannel - 1).clamp(1, 999),
              ),
              icon: const Icon(Icons.remove_rounded),
            ),
            Text('${device.tvChannel}'),
            IconButton(
              onPressed: () => app.updateTvSettings(
                device.id,
                channel: device.tvChannel + 1,
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        Text('Brilho da imagem: ${device.tvBrightness}%'),
        _LargeSliderTile(
          icon: Icons.brightness_6_rounded,
          title: 'Brilho da imagem',
          valueText: '${device.tvBrightness}%',
          value: device.tvBrightness.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) =>
              app.updateTvSettings(device.id, brightness: value.round()),
        ),
        Text('Contraste: ${device.tvContrast}%'),
        _LargeSliderTile(
          icon: Icons.contrast_rounded,
          title: 'Contraste',
          valueText: '${device.tvContrast}%',
          value: device.tvContrast.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) =>
              app.updateTvSettings(device.id, contrast: value.round()),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['Frio', 'Normal', 'Quente'])
              ChoiceChip(
                label: Text(option),
                selected: device.tvColorTemperature == option,
                onSelected: (_) =>
                    app.updateTvSettings(device.id, colorTemperature: option),
              ),
          ],
        ),
        _FullWidthToggleTile(
          icon: Icons.settings_input_hdmi_rounded,
          title: 'HDMI-CEC',
          subtitle: 'Controle dispositivos conectados',
          value: device.hdmiCec,
          onChanged: (value) => app.updateTvSettings(device.id, hdmiCec: value),
        ),
      ],
    );
  }
}

class _DeviceAcSettings extends StatelessWidget {
  const _DeviceAcSettings({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperatura padrão: ${device.value ?? 23}°C'),
        _LargeSliderTile(
          icon: Icons.thermostat_rounded,
          title: 'Temperatura padrao',
          valueText: '${device.value ?? 23}C',
          value: (device.value ?? 23).toDouble(),
          min: 16,
          max: 30,
          divisions: 14,
          onChanged: (value) =>
              app.updateAcSettings(device.id, temperature: value.round()),
        ),
        const Text('Modo padrão'),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['Resfriar', 'Ventilar', 'Auto'])
              ChoiceChip(
                label: Text(option),
                selected: device.acMode == option,
                onSelected: (_) =>
                    app.updateAcSettings(device.id, mode: option),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Velocidade do ventilador'),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['Baixa', 'Média', 'Alta', 'Auto'])
              ChoiceChip(
                label: Text(option),
                selected: device.fanSpeed == option,
                onSelected: (_) =>
                    app.updateAcSettings(device.id, fanSpeed: option),
              ),
          ],
        ),
        _FullWidthToggleTile(
          icon: Icons.eco_rounded,
          title: 'Modo Eco',
          subtitle: 'Economiza energia',
          value: device.ecoMode,
          onChanged: (value) => app.updateAcSettings(device.id, ecoMode: value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.bolt_rounded,
          title: 'Modo Turbo',
          subtitle: 'Resfriamento rapido',
          value: device.turboMode,
          onChanged: (value) =>
              app.updateAcSettings(device.id, turboMode: value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.nightlight_round,
          title: 'Modo Sono',
          subtitle: 'Ajuste gradual de temperatura',
          value: device.sleepMode,
          onChanged: (value) =>
              app.updateAcSettings(device.id, sleepMode: value),
        ),
      ],
    );
  }
}

class _EcoMindDeviceSettings extends StatefulWidget {
  const _EcoMindDeviceSettings({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  State<_EcoMindDeviceSettings> createState() => _EcoMindDeviceSettingsState();
}

class _EcoMindDeviceSettingsState extends State<_EcoMindDeviceSettings> {
  String selectedColor = 'branco';
  final ssid = TextEditingController();
  final password = TextEditingController();

  static const colors = <(String, String, Color)>[
    ('azul', 'Azul', Color(0xFF3B82F6)),
    ('roxo', 'Roxo', Color(0xFF8B5CF6)),
    ('ciano', 'Ciano', Color(0xFF22D3EE)),
    ('verde', 'Verde', Color(0xFF22C55E)),
    ('ambar', 'Âmbar', Color(0xFFF59E0B)),
    ('vermelho', 'Vermelho', Color(0xFFEF4444)),
    ('branco', 'Branco', Color(0xFFFFFFFF)),
    ('apagar', 'Apagar', Color(0xFF27272A)),
  ];

  @override
  void dispose() {
    ssid.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _send(Map<String, Object?> command) async {
    final result = await widget.app.sendEsp32Command(command);
    if (!mounted || result == 'sent') return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> _openWifiDialog() async {
    String status = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Conectar Wi-Fi na EcoMind'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ssid,
                decoration: const InputDecoration(labelText: 'Nome da rede'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(status, style: const TextStyle(color: AuraColors.zinc400)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final result = await widget.app.provisionWifiToEsp32(
                  ssid: ssid.text,
                  password: password.text,
                );
                if (!dialogContext.mounted) return;
                setDialogState(() => status = result);
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final device = widget.device;
    final canSend = app.esp32BleConnected && !app.esp32BleBusy;
    final candidates = app.bluetoothDevices.where((network) {
      final name = network.name.toLowerCase().replaceAll(' ', '');
      return name.contains('ecomind') ||
          name.contains('auramind') ||
          name.contains('esp');
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuraSection(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (app.esp32BleConnected
                                  ? AuraColors.cyan500
                                  : AuraColors.zinc700)
                              .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AuraRadii.lg),
                    ),
                    child: Icon(
                      app.esp32BleConnected
                          ? Icons.bluetooth_connected_rounded
                          : Icons.bluetooth_disabled_rounded,
                      color: app.esp32BleConnected
                          ? AuraColors.cyan400
                          : AuraColors.zinc400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Conexão da EcoMind',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          app.esp32BleStatus,
                          style: const TextStyle(color: AuraColors.zinc400),
                        ),
                      ],
                    ),
                  ),
                  if (app.esp32BleBusy)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: app.esp32BleBusy ? null : app.scanEsp32Bluetooth,
                  icon: const Icon(Icons.bluetooth_searching_rounded),
                  label: Text(
                    app.esp32BleConnected ? 'Buscar outra EcoMind' : 'Conectar',
                  ),
                ),
              ),
              for (final network in candidates.where((item) => !item.connected))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.memory_rounded),
                  title: Text(network.name),
                  subtitle: Text(network.signal),
                  trailing: TextButton(
                    onPressed: () => app.connectEsp32(network),
                    child: const Text('Parear'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Luz e cores',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Toque em uma cor para aplicá-la na EcoMind.',
          style: TextStyle(color: AuraColors.zinc400),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 14,
          children: [
            for (final option in colors)
              Semantics(
                button: true,
                label: option.$2,
                child: InkWell(
                  onTap: canSend
                      ? () {
                          setState(() => selectedColor = option.$1);
                          unawaited(_send({'cmd': 'led', 'color': option.$1}));
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AuraRadii.full),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: option.$3,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == option.$1
                                ? AuraColors.cyan400
                                : AuraColors.zinc700,
                            width: selectedColor == option.$1 ? 4 : 2,
                          ),
                          boxShadow: selectedColor == option.$1
                              ? [
                                  BoxShadow(
                                    color: option.$3.withValues(alpha: 0.45),
                                    blurRadius: 14,
                                  ),
                                ]
                              : null,
                        ),
                        child: option.$1 == 'apagar'
                            ? const Icon(
                                Icons.power_settings_new_rounded,
                                color: AuraColors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(option.$2, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _LargeSliderTile(
          icon: Icons.brightness_6_rounded,
          title: 'Brilho da EcoMind',
          valueText: '${device.value ?? 70}%',
          value: (device.value ?? 70).toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) {
            widget.app.updateDeviceValue(device.id, value.round());
            if (canSend) {
              unawaited(_send({'cmd': 'brightness', 'value': value.round()}));
            }
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Rede e integração',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: canSend ? _openWifiDialog : null,
              icon: const Icon(Icons.wifi_password_rounded),
              label: const Text('Configurar Wi-Fi'),
            ),
            OutlinedButton.icon(
              onPressed: canSend
                  ? () => _send({'cmd': 'backend_health'})
                  : null,
              icon: const Icon(Icons.cloud_done_rounded),
              label: const Text('Testar backend'),
            ),
            OutlinedButton.icon(
              onPressed: canSend ? () => _send({'cmd': 'status'}) : null,
              icon: const Icon(Icons.monitor_heart_rounded),
              label: const Text('Ver status'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Diagnóstico Bluetooth'),
          subtitle: const Text('Eventos técnicos e teste de conexão'),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: canSend ? () => _send({'cmd': 'ping'}) : null,
                icon: const Icon(Icons.network_ping_rounded),
                label: const Text('Enviar ping'),
              ),
            ),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 150),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AuraColors.zinc950.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(AuraRadii.lg),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  app.esp32BleLog.isEmpty
                      ? 'Nenhum evento registrado.'
                      : app.esp32BleLog.join('\n'),
                  style: const TextStyle(
                    color: AuraColors.zinc400,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenericDeviceSettings extends StatelessWidget {
  const _GenericDeviceSettings({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  Widget build(BuildContext context) {
    final hasLevel = {
      AuraDeviceType.curtain,
      AuraDeviceType.thermostat,
    }.contains(device.type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações abertas para ${device.typeLabel}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Conexão: ${device.connectionLabel}${device.manufacturer.isEmpty ? '' : ' • ${device.manufacturer}'}${device.model.isEmpty ? '' : ' • ${device.model}'}',
          style: const TextStyle(color: AuraColors.zinc400),
        ),
        if (hasLevel && device.value != null) ...[
          const SizedBox(height: 16),
          Text(
            device.type == AuraDeviceType.thermostat
                ? 'Temperatura: ${device.value}°C'
                : 'Abertura: ${device.value}%',
          ),
          _LargeSliderTile(
            icon: device.type == AuraDeviceType.thermostat
                ? Icons.thermostat_rounded
                : Icons.open_in_full_rounded,
            title: device.type == AuraDeviceType.thermostat
                ? 'Temperatura'
                : 'Abertura',
            valueText: device.type == AuraDeviceType.thermostat
                ? '${device.value}C'
                : '${device.value}%',
            value: device.value!.toDouble(),
            min: device.type == AuraDeviceType.thermostat ? 10 : 0,
            max: device.type == AuraDeviceType.thermostat ? 35 : 100,
            divisions: device.type == AuraDeviceType.thermostat ? 25 : 20,
            onChanged: (value) =>
                app.updateDeviceValue(device.id, value.round()),
          ),
        ],
        const SizedBox(height: 12),
        _FullWidthToggleTile(
          icon: Icons.auto_mode_rounded,
          title: 'Automacao local',
          subtitle: 'Permite rotinas e comandos da Aura',
          value: device.adaptiveBrightness,
          onChanged: (value) => app.updateDeviceAutomation(device.id, value),
        ),
      ],
    );
  }
}

class _DeviceRoutineEditor extends StatefulWidget {
  const _DeviceRoutineEditor({required this.app, required this.device});

  final AuraController app;
  final AuraDevice device;

  @override
  State<_DeviceRoutineEditor> createState() => _DeviceRoutineEditorState();
}

class _DeviceRoutineEditorState extends State<_DeviceRoutineEditor> {
  final title = TextEditingController(text: 'Desligar automaticamente');
  TimeOfDay time = const TimeOfDay(hour: 22, minute: 0);
  String? editingRoutineId;
  String errorText = '';

  static const _routineSuggestions = [
    'Hora de acordar',
    'Hora de dormir',
    'Esta escurecendo',
    'Desligar automaticamente',
  ];

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  String get displayTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  void _editRoutine(AuraRoutine routine) {
    final parts = routine.time.split(':');
    final hour = int.tryParse(parts.first) ?? 22;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    setState(() {
      editingRoutineId = routine.id;
      title.text = routine.title;
      time = TimeOfDay(
        hour: hour.clamp(0, 23).toInt(),
        minute: minute.clamp(0, 59).toInt(),
      );
      errorText = '';
    });
  }

  void _resetEditor() {
    setState(() {
      editingRoutineId = null;
      title.text = 'Desligar automaticamente';
      time = const TimeOfDay(hour: 22, minute: 0);
      errorText = '';
    });
  }

  void _saveRoutine() {
    final error = widget.app.upsertRoutine(
      widget.device.id,
      title.text,
      displayTime,
      routineId: editingRoutineId,
    );
    if (error != null) {
      setState(() => errorText = error);
      return;
    }
    _resetEditor();
  }

  @override
  Widget build(BuildContext context) {
    final editing = editingRoutineId != null;
    return AuraSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rotinas do aparelho',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AuraColors.cyan500.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AuraRadii.full),
                ),
                child: Text(
                  '${widget.device.routines.length}',
                  style: const TextStyle(
                    color: AuraColors.cyan400,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.device.routines.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Nenhuma rotina criada.',
                style: TextStyle(color: AuraColors.zinc500),
              ),
            )
          else
            for (final routine in widget.device.routines) ...[
              Dismissible(
                key: ValueKey('routine-${widget.device.id}-${routine.id}'),
                direction: DismissDirection.endToStart,
                background: const _SwipeDeleteBackground(),
                confirmDismiss: (_) => _confirmDestructiveAction(
                  context,
                  title: 'Excluir rotina?',
                  message: 'A rotina "${routine.title}" será removida.',
                ),
                onDismissed: (_) {
                  widget.app.deleteRoutine(widget.device.id, routine.id);
                  if (editingRoutineId == routine.id) _resetEditor();
                },
                child: AuraListTile(
                  icon: routine.enabled
                      ? Icons.schedule_rounded
                      : Icons.schedule_outlined,
                  title: routine.title,
                  subtitle:
                      '${routine.enabled ? 'Ativa' : 'Pausada'} • todos os dias às ${routine.time}\nDeslize para excluir',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar rotina',
                        onPressed: () => _editRoutine(routine),
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      AuraSwitch(
                        value: routine.enabled,
                        onChanged: (_) => widget.app.toggleRoutine(
                          widget.device.id,
                          routine.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in _routineSuggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () => setState(() {
                    title.text = suggestion;
                    errorText = '';
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AuraTextField(
            label: 'Nome da rotina',
            hint: 'Desligar em horário específico',
            controller: title,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(alwaysUse24HourFormat: true),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
              if (picked != null) setState(() => time = picked);
            },
            icon: const Icon(Icons.access_time_rounded),
            label: Text('Definir horário $displayTime'),
          ),
          if (errorText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(errorText, style: const TextStyle(color: Color(0xFFF87171))),
          ],
          const SizedBox(height: 12),
          AuraPrimaryButton(
            label: editing ? 'Atualizar rotina' : 'Salvar rotina',
            onPressed: _saveRoutine,
          ),
          if (editing) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _resetEditor,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancelar edicao'),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsDetailView extends StatelessWidget {
  const SettingsDetailView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              Icon(icon, color: AuraColors.cyan400, size: 58),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: AuraColors.zinc400)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final row in rows) ...[
          AuraListTile(
            icon: icon,
            title: row,
            subtitle: row == title
                ? context.tr('connected')
                : context.tr('available'),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class WifiSettingsView extends StatefulWidget {
  const WifiSettingsView({super.key});

  @override
  State<WifiSettingsView> createState() => _WifiSettingsViewState();
}

class _WifiSettingsViewState extends State<WifiSettingsView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openProvisionDialog(
    BuildContext context,
    AuraController app, {
    String initialSsid = '',
  }) async {
    final ssidController = TextEditingController(text: initialSsid);
    final passwordController = TextEditingController();
    String status = '';
    var showPassword = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enviar Wi-Fi para EcoMind'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ssidController,
                    decoration: const InputDecoration(labelText: 'SSID'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => showPassword = !showPassword),
                        icon: Icon(
                          showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      status,
                      style: const TextStyle(color: AuraColors.zinc400),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await app.provisionWifiToEsp32(
                      ssid: ssidController.text,
                      password: passwordController.text,
                    );
                    if (!context.mounted) return;
                    setState(() => status = result);
                  },
                  child: const Text('Provisionar'),
                ),
              ],
            );
          },
        );
      },
    );
    ssidController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final query = _search.text.trim().toLowerCase();
    final networks = query.isEmpty
        ? app.wifiNetworks
        : app.wifiNetworks
              .where((network) => network.name.toLowerCase().contains(query))
              .toList();
    final connected = app.wifiNetworks.isEmpty
        ? null
        : app.wifiNetworks.firstWhere(
            (item) => item.connected,
            orElse: () => app.wifiNetworks.first,
          );

    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              const Icon(
                Icons.wifi_rounded,
                color: AuraColors.cyan400,
                size: 58,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('moreConfigWifi'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                connected == null
                    ? 'Nenhuma rede carregada'
                    : '${connected.name} • ${connected.signal}',
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => app.refreshNearbyNetworks('Wi-Fi'),
                    icon: const Icon(Icons.phone_android_rounded),
                    label: const Text('Buscar no celular'),
                  ),
                  FilledButton.icon(
                    onPressed: app.esp32BleBusy
                        ? null
                        : () async {
                            final result = await app.scanEcoMindWifiNetworks();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(result)));
                          },
                    icon: const Icon(Icons.wifi_find_rounded),
                    label: const Text('Buscar na EcoMind'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AuraTextField(
          label: 'Pesquisar rede',
          hint: 'Digite o nome do Wi-Fi',
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        for (final network in networks) ...[
          AuraListTile(
            icon: Icons.wifi_rounded,
            title: network.name,
            subtitle: network.connected
                ? context.tr('connected_status')
                : context.tr('available'),
            onTap: () async {
              final isManual =
                  network.id == 'wifi-manual' ||
                  network.name.toLowerCase().contains('manual');
              await _openProvisionDialog(
                context,
                app,
                initialSsid: isManual ? '' : network.name,
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class NearbyBluetoothView extends StatelessWidget {
  const NearbyBluetoothView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final devices = app.bluetoothDevices.where((network) {
      final normalized = network.name.toLowerCase().replaceAll(' ', '');
      return !normalized.contains('ecomind') &&
          network.id != 'bt-scan' &&
          network.id != 'bt-fallback';
    }).toList();
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AuraColors.cyan500.withValues(alpha: 0.24),
                      AuraColors.blue500.withValues(alpha: 0.18),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AuraColors.cyan400,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Aparelhos Bluetooth',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Encontre fones, caixas de som e acessórios próximos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => app.refreshNearbyNetworks('Bluetooth'),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Buscar aparelhos'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (devices.isEmpty)
          _EmptyState(
            icon: Icons.bluetooth_disabled_rounded,
            title: 'Nenhum aparelho encontrado',
            subtitle:
                'Ative o Bluetooth e deixe o acessório em modo de pareamento.',
            action: 'Buscar novamente',
            onTap: () => app.refreshNearbyNetworks('Bluetooth'),
          )
        else
          for (final network in devices) ...[
            AuraSection(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AuraColors.cyan500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AuraRadii.lg),
                    ),
                    child: const Icon(
                      Icons.bluetooth_rounded,
                      color: AuraColors.cyan400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          network.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          network.signal.isEmpty
                              ? 'Disponível'
                              : network.signal,
                          style: const TextStyle(color: AuraColors.zinc400),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => app.connectNetwork(network),
                    child: Text(network.connected ? 'Conectado' : 'Conectar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class BluetoothSettingsView extends StatefulWidget {
  const BluetoothSettingsView({super.key});

  @override
  State<BluetoothSettingsView> createState() => _BluetoothSettingsViewState();
}

class _BluetoothSettingsViewState extends State<BluetoothSettingsView> {
  final _speakController = TextEditingController(
    text: 'Ola Lucas, eu sou o AuraMind.',
  );
  final _ssidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();

  @override
  void dispose() {
    _speakController.dispose();
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _send(
    BuildContext context,
    AuraController app,
    Map<String, Object?> command,
  ) async {
    final result = await app.sendEsp32Command(command);
    if (!context.mounted || result == 'sent') return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  Future<void> _openWifiDialog(BuildContext context, AuraController app) async {
    String status = '';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Conectar Wi-Fi na EcoMind'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _ssidController,
                    decoration: const InputDecoration(labelText: 'SSID'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _wifiPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha'),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      status,
                      style: const TextStyle(color: AuraColors.zinc400),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final result = await app.provisionWifiToEsp32(
                      ssid: _ssidController.text,
                      password: _wifiPasswordController.text,
                    );
                    if (!context.mounted) return;
                    setState(() => status = result);
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _commandButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _commandGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final connected = app.bluetoothDevices.isEmpty
        ? null
        : app.bluetoothDevices.firstWhere(
            (item) => item.connected,
            orElse: () => app.bluetoothDevices.first,
          );
    final canSend = app.esp32BleConnected && !app.esp32BleBusy;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              const Icon(
                Icons.bluetooth_rounded,
                color: AuraColors.cyan400,
                size: 58,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('moreConfigBluetooth'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                connected == null
                    ? 'Nenhum Bluetooth carregado'
                    : '${connected.name} • ${connected.signal}',
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => app.refreshNearbyNetworks('Bluetooth'),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Identificar Bluetooth próximo'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.developer_board_rounded,
                    color: AuraColors.purple400,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'EcoMind',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (app.esp32BleBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                app.esp32BleStatus,
                style: const TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 14),
              _commandGroup(
                title: 'Conexao e status',
                children: [
                  FilledButton.icon(
                    onPressed: app.esp32BleBusy ? null : app.scanEsp32Bluetooth,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Procurar EcoMind'),
                  ),
                  _commandButton(
                    label: 'Ping',
                    icon: Icons.network_ping_rounded,
                    onPressed: canSend
                        ? () => _send(context, app, {'cmd': 'ping'})
                        : null,
                  ),
                  _commandButton(
                    label: 'Status',
                    icon: Icons.monitor_heart_rounded,
                    onPressed: canSend
                        ? () => _send(context, app, {'cmd': 'status'})
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _commandGroup(
                title: 'Luz e cores',
                children: [
                  for (final color in const [
                    'azul',
                    'roxo',
                    'ambar',
                    'ciano',
                    'verde',
                    'vermelho',
                    'branco',
                    'amarelo',
                    'apagar',
                  ])
                    _commandButton(
                      label: color,
                      icon: color == 'apagar'
                          ? Icons.lightbulb_outline_rounded
                          : Icons.lightbulb_rounded,
                      onPressed: canSend
                          ? () => _send(context, app, {
                              'cmd': 'led',
                              'color': color,
                            })
                          : null,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _commandGroup(
                title: 'Wi-Fi e backend',
                children: [
                  _commandButton(
                    label: 'Buscar redes',
                    icon: Icons.wifi_find_rounded,
                    onPressed: canSend
                        ? () => _send(context, app, {'cmd': 'wifi_scan'})
                        : null,
                  ),
                  _commandButton(
                    label: 'Conectar Wi-Fi',
                    icon: Icons.wifi_password_rounded,
                    onPressed: canSend
                        ? () => _openWifiDialog(context, app)
                        : null,
                  ),
                  _commandButton(
                    label: 'Backend',
                    icon: Icons.cloud_done_rounded,
                    onPressed: canSend
                        ? () => _send(context, app, {'cmd': 'backend_health'})
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _commandGroup(
                title: 'Controle por voz',
                children: [
                  _commandButton(
                    label: 'Ouvir comando',
                    icon: Icons.mic_rounded,
                    onPressed: app.isListening ? null : app.toggleListening,
                  ),
                  _commandButton(
                    label: 'Exemplo roxo',
                    icon: Icons.tips_and_updates_rounded,
                    onPressed: canSend
                        ? () => _send(context, app, {
                            'cmd': 'led',
                            'color': 'roxo',
                          })
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AuraTextField(
                label: 'Texto para speak',
                hint: 'Mensagem que a EcoMind devolve como evento',
                controller: _speakController,
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: canSend
                    ? () => _send(context, app, {
                        'cmd': 'speak',
                        'text': _speakController.text.trim().isEmpty
                            ? 'Ola Lucas, eu sou o AuraMind.'
                            : _speakController.text.trim(),
                      })
                    : null,
                icon: const Icon(Icons.record_voice_over_rounded),
                label: const Text('Enviar speak'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Log BLE',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: app.esp32BleLog.isEmpty
                        ? null
                        : app.clearEsp32BleLog,
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('Limpar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AuraColors.zinc950.withValues(alpha: 0.55)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AuraRadii.lg),
                  border: Border.all(
                    color: isDark
                        ? AuraColors.zinc800
                        : const Color(0xFFDCE6F2),
                  ),
                ),
                child: SelectableText(
                  app.esp32BleLog.isEmpty
                      ? 'Sem eventos ainda. Toque em Procurar EcoMind.'
                      : app.esp32BleLog.join('\n'),
                  style: TextStyle(
                    color: isDark
                        ? AuraColors.zinc300
                        : const Color(0xFF334155),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final network in app.bluetoothDevices) ...[
          AuraListTile(
            icon: Icons.bluetooth_rounded,
            title: network.name,
            subtitle: network.connected
                ? context.tr('connected_status')
                : context.tr('available'),
            onTap: () async {
              if (network.available) {
                final result = await app.connectEsp32(network);
                if (!context.mounted || result == 'connected') return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Falha ao conectar: $result')),
                );
              }
            },
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        const _ListTitle('Zigbee'),
        for (final hub in app.zigbeeHubs) ...[
          AuraListTile(
            icon: Icons.hub_rounded,
            title: hub.name,
            subtitle: hub.signal,
            onTap: () => app.connectNetwork(hub),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class DisplaySettingsView extends StatefulWidget {
  const DisplaySettingsView({super.key});

  @override
  State<DisplaySettingsView> createState() => _DisplaySettingsViewState();
}

class _DisplaySettingsViewState extends State<DisplaySettingsView> {
  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LargeSliderTile(
                icon: Icons.brightness_6_rounded,
                title: 'Brilho do aplicativo',
                valueText: '${(app.appBrightness * 100).round()}%',
                value: app.appBrightness,
                min: 0.25,
                max: 1,
                divisions: 15,
                onChanged: (value) async {
                  app.setAppBrightness(value);
                  await AuraPlatformService.setAppBrightness(value);
                },
              ),
              const SizedBox(height: 10),
              _LargeSliderTile(
                icon: Icons.lightbulb_rounded,
                title: 'Brilho dos aparelhos',
                valueText: '${(app.deviceBrightness * 100).round()}%',
                value: app.deviceBrightness,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: app.setDeviceBrightness,
              ),
              const SizedBox(height: 10),
              _FullWidthToggleTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Brilho adaptativo',
                subtitle: 'Economiza energia no app e nos aparelhos',
                value: app.adaptiveBrightness,
                onChanged: app.setAdaptiveBrightness,
              ),
              const SizedBox(height: 12),
              const Text('Tema do aplicativo'),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in const {
                    'system': 'Sistema',
                    'light': 'Claro',
                    'dark': 'Escuro',
                  }.entries)
                    ChoiceChip(
                      label: Text(option.value),
                      selected: app.themeMode == option.key,
                      onSelected: (_) => app.setThemeMode(option.key),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LanguageSettingsView extends StatelessWidget {
  const LanguageSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final langs = {'pt': 'Português', 'en': 'English', 'es': 'Español'};
    return _ScrollPage(
      children: [
        for (final entry in langs.entries) ...[
          AuraListTile(
            icon: Icons.language_rounded,
            title: entry.value,
            subtitle: entry.key == app.lang ? 'Selecionado' : 'Disponível',
            trailing: entry.key == app.lang
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AuraColors.cyan400,
                  )
                : const Icon(Icons.circle_outlined, color: AuraColors.zinc600),
            onTap: () => app.setLanguage(entry.key),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.do_not_disturb_on_rounded,
          title: 'Não Perturbe',
          subtitle: app.doNotDisturb
              ? 'Ativo: notificacoes comuns e voz ficam silenciosas'
              : 'Inativo',
          trailing: AuraSwitch(
            value: app.doNotDisturb,
            onChanged: app.setDoNotDisturb,
          ),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.local_shipping_rounded,
          title: 'Entregas e Alertas',
          trailing: AuraSwitch(
            value: app.notificationDelivery,
            onChanged: app.setNotificationDelivery,
          ),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Permissões do celular',
          subtitle: 'Microfone, camera, notificacoes, contatos, telefone e SMS',
          onTap: () => app.go(AuraRoute.moreConfigPermissions),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.music_note_rounded,
          title: 'Toque de Notificação',
          subtitle: app.ringtone,
          onTap: () => app.go(AuraRoute.moreConfigNotificationsRingtone),
        ),
      ],
    );
  }
}

class PermissionsStatusView extends StatefulWidget {
  const PermissionsStatusView({super.key});

  @override
  State<PermissionsStatusView> createState() => _PermissionsStatusViewState();
}

class _PermissionsStatusViewState extends State<PermissionsStatusView> {
  Map<String, bool> statuses = const {};
  bool loading = true;

  static const _items = [
    ('microphone', Icons.mic_rounded, 'Microfone', 'Gravar comandos de voz'),
    ('camera', Icons.photo_camera_rounded, 'Câmera', 'Anexar imagens ao chat'),
    (
      'notifications',
      Icons.notifications_active_rounded,
      'Notificações',
      'Alarmes, timers e avisos',
    ),
    ('location', Icons.location_on_rounded, 'Localização', 'Clima local'),
    ('bluetooth', Icons.bluetooth_rounded, 'Bluetooth', 'Conectar a EcoMind'),
    ('wifi', Icons.wifi_rounded, 'Wi-Fi próximo', 'Buscar redes pela EcoMind'),
    ('contacts', Icons.contacts_rounded, 'Contatos', 'Chamadas e mensagens'),
    ('callPhone', Icons.call_rounded, 'Telefone', 'Iniciar chamadas'),
    ('sms', Icons.sms_rounded, 'SMS', 'Enviar mensagens pelo Android'),
    (
      'callLog',
      Icons.history_rounded,
      'Histórico de chamadas',
      'Mostrar registros recentes',
    ),
  ];

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final result = await AuraPlatformService.readPermissionStatus();
    if (!mounted) return;
    setState(() {
      statuses = result;
      loading = false;
    });
  }

  Future<void> _requestAll() async {
    setState(() => loading = true);
    final app = AuraScope.of(context);
    final core = await AuraPlatformService.requestCorePermissions();
    final telephony = await AuraPlatformService.requestTelephonyPermissions();
    app.updatePermissions(
      microphone: core['microphone'],
      camera: core['camera'],
      contacts: core['contacts'],
      notifications: core['notifications'],
      callPhone: telephony['callPhone'],
      sms: telephony['sendSms'] == true || telephony['readSms'] == true,
      callLog: telephony['readCallLog'],
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.privacy_tip_rounded,
                color: AuraColors.cyan400,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Permissões do celular',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aqui ficam as permissões usadas por voz, câmera, notificações, EcoMind, contatos, chamadas e mensagens. O app só pede novamente quando você tocar no botão abaixo.',
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 16),
              AuraPrimaryButton(
                label: loading ? 'Atualizando...' : 'Solicitar permissões',
                onPressed: loading ? () {} : _requestAll,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final item in _items) ...[
          AuraListTile(
            icon: item.$2,
            title: item.$3,
            subtitle: item.$4,
            color: statuses[item.$1] == true
                ? AuraColors.green400
                : AuraColors.amber400,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    (statuses[item.$1] == true
                            ? AuraColors.green400
                            : AuraColors.amber400)
                        .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AuraRadii.full),
              ),
              child: Text(
                statuses[item.$1] == true ? 'Permitida' : 'Pendente',
                style: TextStyle(
                  color: statuses[item.$1] == true
                      ? AuraColors.green400
                      : AuraColors.amber400,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            onTap: _requestAll,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class RingtoneView extends StatelessWidget {
  const RingtoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        for (final tone in app.notificationTones) ...[
          Builder(
            builder: (context) {
              final selected =
                  tone.id == app.ringtone ||
                  (tone.systemPicker && app.ringtone.startsWith('system:'));
              return AuraListTile(
                icon: Icons.music_note_rounded,
                title: tone.title,
                subtitle: selected
                    ? 'Toque atual • ${tone.description}'
                    : 'Toque disponível • ${tone.description}',
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AuraColors.cyan400,
                      )
                    : const Icon(
                        Icons.circle_outlined,
                        color: AuraColors.zinc600,
                      ),
                onTap: () async {
                  if (tone.systemPicker) {
                    final picked =
                        await AuraPlatformService.pickSystemRingtone();
                    if (picked == null) return;
                    app.setRingtone(picked);
                    await AuraPlatformService.previewTone(picked);
                    return;
                  }
                  app.setRingtone(tone.id);
                  await AuraPlatformService.previewTone(tone.id);
                },
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        for (final account in app.accounts) ...[
          Dismissible(
            key: ValueKey('account-${account.id}'),
            direction: account.id == app.activeUserId
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: const _SwipeDeleteBackground(),
            confirmDismiss: (_) => _confirmDestructiveAction(
              context,
              title: 'Excluir conta?',
              message: 'A conta "${account.name}" será removida deste app.',
            ),
            onDismissed: (_) => unawaited(app.deleteAccount(account.id)),
            child: AuraSection(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _ProfileAvatar(
                  name: account.name,
                  imageUrl: account.imageAsset,
                  size: 48,
                ),
                title: Text(account.name),
                subtitle: Text(
                  '${account.role}${account.email.isEmpty ? '' : ' • ${account.email}'}\n${_accountPermissions(account)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => app.openAccountSettings(account.id),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: () => app.go(AuraRoute.moreConfigAccountsAdd),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Adicionar conta'),
        ),
      ],
    );
  }

  String _accountPermissions(AuraAccount account) {
    final permissions = <String>[
      if (account.canManageDevices) 'dispositivos',
      if (account.canManageMembers) 'membros',
      if (account.canUseVoice) 'voz',
      if (account.canUseMedia) 'midia',
      if (account.canViewHistory) 'historico',
    ];
    return permissions.isEmpty ? 'sem permissoes' : permissions.join(', ');
  }
}

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  final name = TextEditingController();
  final email = TextEditingController();
  String accountId = '';
  String role = 'Membro';
  bool notificationsEnabled = true;
  bool canManageDevices = true;
  bool canManageMembers = false;
  bool canUseVoice = true;
  bool canUseMedia = true;
  bool canViewHistory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = AuraScope.of(context).selectedAccount;
    if (account == null || account.id == accountId) return;
    accountId = account.id;
    name.text = account.name;
    email.text = account.email;
    role = account.role;
    notificationsEnabled = account.notificationsEnabled;
    canManageDevices = account.canManageDevices;
    canManageMembers = account.canManageMembers;
    canUseVoice = account.canUseVoice;
    canUseMedia = account.canUseMedia;
    canViewHistory = account.canViewHistory;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final account = app.selectedAccount;
    if (account == null) {
      return _ScrollPage(
        children: [
          _EmptyState(
            icon: Icons.manage_accounts_rounded,
            title: 'Perfil não encontrado',
            subtitle: 'Volte e selecione outro perfil.',
            action: 'Voltar aos perfis',
            onTap: () => app.go(AuraRoute.moreConfigAccounts),
          ),
        ],
      );
    }
    final isOwner = account.id == app.activeUserId;
    return _ScrollPage(
      children: [
        Center(
          child: _ProfileAvatar(
            name: account.name,
            imageUrl: account.imageAsset,
            size: 108,
            onTap: () => app.updateAccountPhoto(account.id),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => app.updateAccountPhoto(account.id),
          icon: const Icon(Icons.photo_camera_rounded),
          label: const Text('Trocar foto'),
        ),
        const SizedBox(height: 18),
        AuraTextField(label: 'Nome', hint: 'Nome do perfil', controller: name),
        const SizedBox(height: 12),
        AuraTextField(
          label: 'E-mail',
          hint: 'email@exemplo.com',
          controller: email,
        ),
        const SizedBox(height: 14),
        if (!isOwner)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in ['Membro', 'Administrador', 'Convidado'])
                ChoiceChip(
                  label: Text(option),
                  selected: role == option,
                  onSelected: (_) => setState(() => role = option),
                ),
            ],
          ),
        const SizedBox(height: 18),
        _FullWidthToggleTile(
          icon: Icons.notifications_rounded,
          title: 'Notificações',
          value: notificationsEnabled,
          onChanged: (value) => setState(() => notificationsEnabled = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.devices_rounded,
          title: 'Gerenciar dispositivos',
          value: canManageDevices,
          onChanged: isOwner
              ? null
              : (value) => setState(() => canManageDevices = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.group_rounded,
          title: 'Gerenciar membros',
          value: canManageMembers,
          onChanged: isOwner
              ? null
              : (value) => setState(() => canManageMembers = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.mic_rounded,
          title: 'Usar voz e câmera',
          value: canUseVoice,
          onChanged: isOwner
              ? null
              : (value) => setState(() => canUseVoice = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.play_circle_rounded,
          title: 'Usar mídia e skills',
          value: canUseMedia,
          onChanged: isOwner
              ? null
              : (value) => setState(() => canUseMedia = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.history_rounded,
          title: 'Ver histórico',
          value: canViewHistory,
          onChanged: isOwner
              ? null
              : (value) => setState(() => canViewHistory = value),
        ),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Salvar perfil',
          onPressed: () {
            app.updateAccount(
              account.id,
              name: name.text,
              email: email.text,
              role: role,
              notificationsEnabled: notificationsEnabled,
              canManage: canManageDevices,
              canManageMembers: canManageMembers,
              canUseVoice: canUseVoice,
              canUseMedia: canUseMedia,
              canViewHistory: canViewHistory,
            );
            app.go(AuraRoute.moreConfigAccounts);
          },
        ),
        if (!isOwner) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await _confirmDestructiveAction(
                context,
                title: 'Excluir conta?',
                message: 'A conta "${account.name}" será removida deste app.',
              );
              if (!context.mounted || !confirmed) return;
              await app.deleteAccount(account.id);
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Excluir perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

class AccountAddView extends StatefulWidget {
  const AccountAddView({super.key});

  @override
  State<AccountAddView> createState() => _AccountAddViewState();
}

class _AccountAddViewState extends State<AccountAddView> {
  final name = TextEditingController();
  final email = TextEditingController();
  String role = 'Membro';
  bool canManageDevices = true;
  bool canManageMembers = false;
  bool canUseVoice = true;
  bool canUseMedia = true;
  bool canViewHistory = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: AuraColors.zinc800,
          child: Icon(Icons.person_add_rounded, size: 46),
        ),
        const SizedBox(height: 24),
        const Text(
          'Adicione uma conta direto pelo aplicativo e ajuste permissões depois.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AuraColors.zinc400),
        ),
        const SizedBox(height: 20),
        AuraTextField(label: 'Nome', hint: 'Nome do perfil', controller: name),
        const SizedBox(height: 12),
        AuraTextField(
          label: 'E-mail',
          hint: 'email@exemplo.com',
          controller: email,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final option in ['Membro', 'Administrador', 'Convidado'])
              ChoiceChip(
                label: Text(option),
                selected: role == option,
                onSelected: (_) => setState(() {
                  role = option;
                  _applyRoleDefaults(option);
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _FullWidthToggleTile(
          icon: Icons.devices_rounded,
          title: 'Gerenciar dispositivos',
          value: canManageDevices,
          onChanged: (value) => setState(() => canManageDevices = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.group_rounded,
          title: 'Gerenciar membros',
          value: canManageMembers,
          onChanged: (value) => setState(() => canManageMembers = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.mic_rounded,
          title: 'Usar voz e camera',
          value: canUseVoice,
          onChanged: (value) => setState(() => canUseVoice = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.play_circle_rounded,
          title: 'Usar midia e skills',
          value: canUseMedia,
          onChanged: (value) => setState(() => canUseMedia = value),
        ),
        const SizedBox(height: 10),
        _FullWidthToggleTile(
          icon: Icons.history_rounded,
          title: 'Ver historico',
          value: canViewHistory,
          onChanged: (value) => setState(() => canViewHistory = value),
        ),
        const SizedBox(height: 30),
        AuraPrimaryButton(
          label: 'Adicionar e convidar',
          onPressed: () => _submit(app),
        ),
      ],
    );
  }

  void _applyRoleDefaults(String value) {
    if (value == 'Administrador') {
      canManageDevices = true;
      canManageMembers = true;
      canUseVoice = true;
      canUseMedia = true;
      canViewHistory = true;
    } else if (value == 'Convidado') {
      canManageDevices = false;
      canManageMembers = false;
      canUseVoice = false;
      canUseMedia = true;
      canViewHistory = false;
    } else {
      canManageDevices = true;
      canManageMembers = false;
      canUseVoice = true;
      canUseMedia = true;
      canViewHistory = false;
    }
  }

  Future<void> _submit(AuraController app) async {
    final memberEmail = email.text.trim();
    final inviteUrl = await app.addAccount(
      name.text,
      memberEmail,
      role,
      canManageDevices: canManageDevices,
      canManageMembers: canManageMembers,
      canUseVoice: canUseVoice,
      canUseMedia: canUseMedia,
      canViewHistory: canViewHistory,
    );
    if (memberEmail.isEmpty || inviteUrl == null) return;
    final subject = Uri.encodeComponent('Convite para Aura Mind');
    final body = Uri.encodeComponent(
      'Ola!\n\n'
      'Voce foi convidado para entrar no Aura Mind como $role.\n\n'
      'Abra este convite no celular com o app instalado:\n$inviteUrl\n\n'
      'Depois, entre usando este e-mail: $memberEmail\n\n'
      'Equipe Aura Mind',
    );
    final uri = Uri.parse('mailto:$memberEmail?subject=$subject&body=$body');
    await launchUrl(uri);
  }
}

class ActivitiesView extends StatelessWidget {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        for (final activity in app.recentActivities) ...[
          AuraListTile(
            icon: Icons.history_rounded,
            title: activity.text,
            subtitle:
                '${activity.time} • ${activity.device} • ${activity.origin}',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.text,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(activity.details),
                      const SizedBox(height: 8),
                      Text('Dispositivo: ${activity.device}'),
                      Text('Origem: ${activity.origin}'),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.size,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final double size;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final letter = name.characters.firstOrNull?.toUpperCase() ?? 'A';
    final url = imageUrl?.trim() ?? '';
    final child = ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AuraColors.cyan500,
        alignment: Alignment.center,
        child: url.startsWith('http')
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  letter,
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : url.isNotEmpty
            ? Image.file(
                File(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  letter,
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            : Text(
                letter,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final account = app.currentAccount;
    final name = account?.name ?? 'Nova conta';
    final email = account?.email ?? '';
    return _ScrollPage(
      children: [
        Center(
          child: _ProfileAvatar(
            name: name,
            imageUrl: account?.imageAsset,
            size: 116,
            onTap: account == null
                ? null
                : () => app.updateAccountPhoto(account.id),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: account == null
              ? null
              : () => app.updateAccountPhoto(account.id),
          icon: const Icon(Icons.photo_camera_rounded),
          label: const Text('Trocar foto'),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(
          email.isEmpty ? 'Conta local do Aura Mind' : email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AuraColors.zinc400),
        ),
        const SizedBox(height: 26),
        AuraListTile(
          icon: Icons.person_rounded,
          title: 'Dados Pessoais',
          onTap: () => app.go(AuraRoute.profileData),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.record_voice_over_rounded,
          title: 'Voz da Aura',
          onTap: () => app.go(AuraRoute.profileVoice),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.shield_rounded,
          title: 'Privacidade',
          onTap: () => app.go(AuraRoute.profilePrivacy),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.manage_accounts_rounded,
          title: 'Configurações da conta',
          onTap: account == null
              ? null
              : () => app.openAccountSettings(account.id),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.logout_rounded,
          title: 'Sair',
          color: const Color(0xFFF87171),
          onTap: app.logout,
        ),
      ],
    );
  }
}

class ProfileDataView extends StatelessWidget {
  const ProfileDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final account = app.currentAccount;
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.badge_rounded,
          title: 'Nome',
          subtitle: account?.name ?? 'Nova conta',
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.email_rounded,
          title: 'E-mail',
          subtitle: account?.email.isNotEmpty == true
              ? account!.email
              : 'Não informado',
        ),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Editar Dados',
          onPressed: () => app.go(AuraRoute.profileDataEdit),
        ),
      ],
    );
  }
}

class ProfileDataEditView extends StatefulWidget {
  const ProfileDataEditView({super.key});

  @override
  State<ProfileDataEditView> createState() => _ProfileDataEditViewState();
}

class _ProfileDataEditViewState extends State<ProfileDataEditView> {
  final name = TextEditingController();
  final email = TextEditingController();
  String? accountId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = AuraScope.of(context).currentAccount;
    if (accountId == account?.id) return;
    accountId = account?.id;
    name.text = account?.name ?? '';
    email.text = account?.email ?? '';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final account = app.currentAccount;
    return _ScrollPage(
      children: [
        if (account != null) ...[
          Center(
            child: InkWell(
              onTap: () => app.updateAccountPhoto(account.id),
              borderRadius: BorderRadius.circular(52),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AuraColors.purple500.withValues(alpha: 0.18),
                backgroundImage: _imageProvider(account.imageAsset),
                child: (account.imageAsset ?? '').trim().isEmpty
                    ? const Icon(
                        Icons.add_a_photo_rounded,
                        color: AuraColors.purple400,
                        size: 34,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
        AuraTextField(label: 'Nome', hint: 'Seu nome', controller: name),
        const SizedBox(height: 16),
        AuraTextField(label: 'E-mail', hint: 'Seu e-mail', controller: email),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Salvar Dados',
          onPressed: () {
            if (account != null) {
              app.updateAccount(account.id, name: name.text, email: email.text);
            }
            app.go(AuraRoute.profileData);
          },
        ),
      ],
    );
  }
}

class ProfileVoiceView extends StatelessWidget {
  const ProfileVoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraListTile(
          icon: Icons.language_rounded,
          title: 'Idioma da Voz',
          subtitle: 'Português',
          onTap: () => app.go(AuraRoute.profileVoiceLanguage),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.speed_rounded,
          title: 'Velocidade da Voz',
          subtitle: 'Normal',
          onTap: () => app.go(AuraRoute.profileVoiceSpeed),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.mic_rounded,
          title: 'Palavra de Ativação',
          subtitle: 'Aura',
          onTap: () => app.go(AuraRoute.profileVoiceWakeWord),
        ),
      ],
    );
  }
}

class VoiceLanguageView extends StatelessWidget {
  const VoiceLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageSettingsView();
  }
}

class VoiceSpeedView extends StatefulWidget {
  const VoiceSpeedView({super.key});

  @override
  State<VoiceSpeedView> createState() => _VoiceSpeedViewState();
}

class _VoiceSpeedViewState extends State<VoiceSpeedView> {
  double speed = 1;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Velocidade',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Slider(
                value: speed,
                min: 0.5,
                max: 1.5,
                divisions: 4,
                label: '${speed.toStringAsFixed(1)}x',
                onChanged: (value) => setState(() => speed = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WakeWordView extends StatelessWidget {
  const WakeWordView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        const AuraListTile(
          icon: Icons.mic_rounded,
          title: 'Aura',
          subtitle: 'Palavra atual',
        ),
        const SizedBox(height: 10),
        const AuraListTile(
          icon: Icons.auto_awesome_rounded,
          title: 'Echo',
          subtitle: 'Alternativa disponível',
        ),
        const SizedBox(height: 24),
        AuraPrimaryButton(
          label: 'Salvar Palavra',
          onPressed: () => app.go(AuraRoute.profileVoice),
        ),
      ],
    );
  }
}

class ProfilePrivacyView extends StatelessWidget {
  const ProfilePrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    final privacy = app.effectivePrivacy;
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacidade da conta',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Controle dados, permissões e integrações usadas pelo Aura Mind.',
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 14),
              _FullWidthToggleTile(
                icon: Icons.location_on_rounded,
                title: 'Usar localizacao',
                subtitle: 'Clima local e rotinas por presenca',
                value: privacy.allowLocationTracking,
                onChanged: (value) =>
                    app.updatePrivacy(allowLocationTracking: value),
              ),
              const SizedBox(height: 10),
              _FullWidthToggleTile(
                icon: Icons.analytics_rounded,
                title: 'Analytics do aplicativo',
                subtitle: 'Metricas agregadas para melhoria',
                value: privacy.allowAnalytics,
                onChanged: (value) => app.updatePrivacy(allowAnalytics: value),
              ),
              const SizedBox(height: 10),
              _FullWidthToggleTile(
                icon: Icons.extension_rounded,
                title: 'Integracoes de terceiros',
                subtitle: 'Skills como YouTube Music e SmartThings',
                value: privacy.allowThirdPartyIntegration,
                onChanged: (value) =>
                    app.updatePrivacy(allowThirdPartyIntegration: value),
              ),
              const SizedBox(height: 10),
              _LargeSliderTile(
                icon: Icons.event_repeat_rounded,
                title: 'Retencao de dados',
                valueText: '${privacy.dataRetentionDays} dias',
                value: privacy.dataRetentionDays.toDouble(),
                min: 30,
                max: 365,
                divisions: 11,
                onChanged: (value) =>
                    app.updatePrivacy(dataRetentionDays: value.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuraListTile(
          icon: Icons.history_rounded,
          title: 'Histórico de Voz',
          onTap: () => app.go(AuraRoute.profilePrivacyHistory),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.extension_rounded,
          title: 'Permissões de Skills',
          onTap: () => app.go(AuraRoute.profilePrivacySkills),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.lock_rounded,
          title: 'Privacidade da Conta',
          subtitle: 'Proteção padrão ativada',
          onTap: () => _showInfoSheet(
            context,
            icon: Icons.lock_rounded,
            title: 'Privacidade da conta',
            body:
                'Sua conta controla perfil, membros, histórico, skills e permissões. Quando há Supabase disponível, nome e foto ficam sincronizados com seu perfil; quando não há conexão, o app mantém um cache local para não perder seus dados.',
            actions: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  app.go(AuraRoute.legalPrivacy);
                },
                icon: const Icon(Icons.shield_rounded),
                label: const Text('Ver política de privacidade'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.enhanced_encryption_rounded,
          title: 'Criptografia',
          subtitle:
              'Dados em transito usam HTTPS/TLS; segredos do backend ficam fora do APK.',
          onTap: () => _showInfoSheet(
            context,
            icon: Icons.enhanced_encryption_rounded,
            title: 'Criptografia e segurança',
            body:
                'As chamadas do app para o backend usam HTTPS/TLS. Tokens de login não são enviados para o backend local/ngrok de chat, voz e música. Fotos de perfil usam URL assinada quando passam pelo Supabase. Senhas de Wi-Fi só são enviadas para a EcoMind por BLE quando você confirma a rede.',
          ),
        ),
      ],
    );
  }
}

class PrivacyHistoryView extends StatelessWidget {
  const PrivacyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      children: const [
        AuraListTile(
          icon: Icons.mic_rounded,
          title: 'Ligar luzes da sala',
          subtitle: 'Hoje, 14:08',
        ),
        SizedBox(height: 10),
        AuraListTile(
          icon: Icons.mic_rounded,
          title: 'Tocar jazz',
          subtitle: 'Hoje, 13:32',
        ),
        SizedBox(height: 10),
        AuraListTile(
          icon: Icons.mic_rounded,
          title: 'Qual a previsão?',
          subtitle: 'Ontem, 19:40',
        ),
      ],
    );
  }
}

class PrivacySkillsView extends StatelessWidget {
  const PrivacySkillsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkillsView();
  }
}

class SkillLoginView extends StatelessWidget {
  const SkillLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            children: [
              const Icon(
                Icons.extension_rounded,
                color: AuraColors.cyan400,
                size: 62,
              ),
              const SizedBox(height: 14),
              Text(
                'Conectar ${app.activeSkill}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Autorize a integracao para usar comandos de voz com esta skill. O backend da Aura podera concluir a conexao segura depois.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 24),
              AuraPrimaryButton(
                label: 'Conectar',
                onPressed: () async {
                  await app.connectActiveSkill();
                  app.go(AuraRoute.profilePrivacySkills);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final subject = TextEditingController(text: 'Preciso de ajuda com Aura Mind');
  final message = TextEditingController();
  String feedback = '';

  @override
  void dispose() {
    subject.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool email}) async {
    final app = AuraScope.of(context);
    final ok = await app.submitSupportRequest(
      subject: subject.text,
      message: message.text,
      openEmail: email,
    );
    if (!mounted) return;
    setState(() {
      feedback = ok
          ? 'Solicitação registrada.'
          : 'Registro salvo, mas não consegui abrir o e-mail.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AuraScope.of(context);
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: AuraColors.cyan400,
                size: 46,
              ),
              const SizedBox(height: 12),
              const Text(
                'Suporte Aura Mind',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Registre o problema no app ou abra um e-mail para ${AppConfig.supportEmail}.',
                style: const TextStyle(color: AuraColors.zinc400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuraTextField(
          label: 'Assunto',
          hint: 'Ex.: EcoMind não conectou',
          controller: subject,
        ),
        const SizedBox(height: 12),
        AuraTextField(
          label: 'Mensagem',
          hint: 'Descreva o que aconteceu',
          controller: message,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        AuraPrimaryButton(
          label: 'Registrar no app',
          onPressed: () => _submit(email: false),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _submit(email: true),
          icon: const Icon(Icons.email_rounded),
          label: const Text('Abrir e-mail de suporte'),
        ),
        if (feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InlineErrorBanner(message: feedback),
        ],
        const SizedBox(height: 18),
        AuraListTile(
          icon: Icons.description_rounded,
          title: 'Termos de Uso',
          subtitle: 'Regras de uso do app, IA, EcoMind e alarmes',
          onTap: () => app.go(AuraRoute.legalTerms),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.shield_rounded,
          title: 'Política de Privacidade',
          subtitle: 'Dados, permissões, backend e exclusão',
          onTap: () => app.go(AuraRoute.legalPrivacy),
        ),
        const SizedBox(height: 10),
        AuraListTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Permissões do celular',
          subtitle: 'Veja o que está permitido no Android',
          onTap: () => app.go(AuraRoute.moreConfigPermissions),
        ),
      ],
    );
  }
}

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final message = TextEditingController();
  int rating = 5;
  String feedback = '';

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool email}) async {
    final app = AuraScope.of(context);
    final ok = await app.submitSupportRequest(
      subject: 'Avaliação Aura Mind: $rating/5',
      message: message.text.trim().isEmpty
          ? 'Avaliação enviada sem comentário.'
          : message.text,
      origin: 'Avaliação',
      openEmail: email,
    );
    if (!mounted) return;
    setState(() {
      feedback = ok
          ? 'Avaliação registrada. Obrigado!'
          : 'Avaliação salva no app.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.star_rate_rounded,
                color: AuraColors.amber400,
                size: 46,
              ),
              const SizedBox(height: 12),
              const Text(
                'Avaliar Aura Mind',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sua avaliação ajuda a ajustar chat, voz, EcoMind, alarmes e experiência geral.',
                style: TextStyle(color: AuraColors.zinc400),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var value = 1; value <= 5; value++)
                    ChoiceChip(
                      label: Text('$value'),
                      selected: rating == value,
                      onSelected: (_) => setState(() => rating = value),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AuraTextField(
          label: 'Comentário',
          hint: 'O que funcionou ou precisa melhorar?',
          controller: message,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        AuraPrimaryButton(
          label: 'Enviar avaliação',
          onPressed: () => _submit(email: false),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _submit(email: true),
          icon: const Icon(Icons.email_rounded),
          label: const Text('Enviar também por e-mail'),
        ),
        if (feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InlineErrorBanner(message: feedback),
        ],
      ],
    );
  }
}

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({super.key, required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final isTerms = kind == 'terms';
    final sections = isTerms ? _termsSections : _privacySections;
    return _ScrollPage(
      children: [
        AuraSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                kind == 'terms'
                    ? Icons.description_rounded
                    : Icons.shield_rounded,
                color: AuraColors.cyan400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                isTerms ? 'Termos de Uso' : 'Política de Privacidade',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Resumo claro para uso do app Aura Mind, backend de IA e EcoMind.',
                style: TextStyle(color: AuraColors.zinc400, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final section in sections) ...[
          AuraSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.$1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  section.$2,
                  style: const TextStyle(color: AuraColors.zinc400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  static const _termsSections = [
    (
      'Uso permitido',
      'Use o Aura Mind para conversar com a Aura, controlar dispositivos, organizar listas, notas, alarmes, timers e rotinas. Não use o app para atividades ilegais, abuso de serviços ou comandos que coloquem pessoas ou bens em risco.',
    ),
    (
      'Conta e perfil',
      'Nome, e-mail e foto podem ficar salvos localmente e sincronizados com Supabase quando você estiver logado. Você é responsável por manter o celular protegido e revisar membros adicionados à sua casa.',
    ),
    (
      'IA, voz e backend',
      'Mensagens, transcrições e pedidos de música podem ser enviados ao backend configurado para gerar respostas. A Aura pode errar; confirme informações importantes antes de agir.',
    ),
    (
      'Dispositivos e EcoMind',
      'Comandos de Bluetooth, Wi-Fi e rotinas dependem do firmware, permissões do Android e conexão local. Teste automações críticas antes de confiar nelas no dia a dia.',
    ),
    (
      'Alarmes e timers',
      'O app agenda notificações nativas para tocar com o app fechado, mas economia de bateria, permissões negadas ou restrições do fabricante podem impedir alertas. Mantenha permissões de notificação e alarme ativadas.',
    ),
    (
      'Suporte',
      'Use a área de suporte para registrar problemas e abrir e-mail para ${AppConfig.supportEmail}.',
    ),
  ];

  static const _privacySections = [
    (
      'Dados coletados',
      'O app pode armazenar perfil, foto, preferências, mensagens, listas, notas, alarmes, timers, rotinas, dispositivos, atividades e notificações. Parte fica local no celular e parte pode sincronizar com Supabase quando disponível.',
    ),
    (
      'Permissões do celular',
      'Microfone grava comandos de voz; câmera e fotos permitem anexos/perfil; notificações tocam alarmes; localização ajuda clima; Bluetooth e Wi-Fi conectam a EcoMind; contatos, telefone, SMS e histórico só são usados em recursos de comunicação.',
    ),
    (
      'IA e backend',
      'Chat, transcrição, TTS e música usam o backend configurado em HTTPS. Essas chamadas para o backend local/ngrok não exigem token Supabase no app.',
    ),
    (
      'EcoMind e Wi-Fi',
      'Senha de Wi-Fi é enviada para a EcoMind por BLE somente quando você escolhe a rede e confirma. O app não mostra essa senha depois do envio.',
    ),
    (
      'Segurança',
      'Dados em trânsito usam HTTPS/TLS quando enviados ao backend. Fotos no Supabase usam URLs assinadas quando disponíveis. Segredos do backend não ficam embutidos visualmente no app.',
    ),
    (
      'Controle e exclusão',
      'Exclusões importantes pedem confirmação. Você pode remover notas, listas, dispositivos, contas gerenciadas e rotinas no próprio app. Para suporte, use ${AppConfig.supportEmail}.',
    ),
  ];
}
