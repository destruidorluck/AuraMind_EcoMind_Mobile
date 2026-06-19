enum AuraRoute {
  home,
  homeLocation,
  auraAsk,
  communicate,
  communicateCall,
  communicateMessage,
  communicateChat,
  communicateDropIn,
  communicateAnnouncements,
  communicateCalling,
  communicateAddContact,
  communicateEditContact,
  communicateAddGroup,
  communicateGroupSettings,
  play,
  devices,
  deviceLight,
  deviceAc,
  more,
  moreLists,
  moreListItems,
  moreNoteEdit,
  moreCalendar,
  moreCalendarEdit,
  moreAlarms,
  moreAlarmEdit,
  moreAlarmNew,
  moreSkills,
  moreConfig,
  moreConfigDevice,
  moreConfigDeviceSettings,
  moreConfigDeviceAdd,
  deviceConfigLight1,
  deviceConfigLight2,
  deviceConfigTv,
  deviceConfigAc,
  deviceConfigEcho,
  moreConfigWifi,
  moreConfigBluetooth,
  moreConfigDisplay,
  moreConfigLanguage,
  moreConfigNotifications,
  moreConfigPermissions,
  moreConfigNotificationsRingtone,
  moreConfigAccounts,
  moreConfigAccountsAdd,
  moreConfigAccountSettings,
  moreActivities,
  moreSupport,
  moreFeedback,
  profile,
  profileData,
  profileDataEdit,
  profileVoice,
  profileVoiceLanguage,
  profileVoiceSpeed,
  profileVoiceWakeWord,
  profilePrivacy,
  profilePrivacyHistory,
  profilePrivacySkills,
  legalTerms,
  legalPrivacy,
  skillLogin,
}

extension AuraRouteInfo on AuraRoute {
  bool get isSubRoute =>
      name.contains(RegExp('[A-Z]')) || this == AuraRoute.skillLogin;

  bool get showBottomNavigation {
    return switch (this) {
      AuraRoute.home ||
      AuraRoute.communicate ||
      AuraRoute.play ||
      AuraRoute.devices ||
      AuraRoute.more => true,
      _ => false,
    };
  }

  AuraRoute get mainRoute {
    return switch (this) {
      AuraRoute.home ||
      AuraRoute.homeLocation ||
      AuraRoute.auraAsk => AuraRoute.home,
      AuraRoute.communicate ||
      AuraRoute.communicateCall ||
      AuraRoute.communicateMessage ||
      AuraRoute.communicateChat ||
      AuraRoute.communicateDropIn ||
      AuraRoute.communicateAnnouncements ||
      AuraRoute.communicateCalling ||
      AuraRoute.communicateAddContact ||
      AuraRoute.communicateEditContact ||
      AuraRoute.communicateAddGroup ||
      AuraRoute.communicateGroupSettings => AuraRoute.communicate,
      AuraRoute.play => AuraRoute.play,
      AuraRoute.devices ||
      AuraRoute.deviceLight ||
      AuraRoute.deviceAc => AuraRoute.devices,
      AuraRoute.more ||
      AuraRoute.moreLists ||
      AuraRoute.moreListItems ||
      AuraRoute.moreNoteEdit ||
      AuraRoute.moreCalendar ||
      AuraRoute.moreCalendarEdit ||
      AuraRoute.moreAlarms ||
      AuraRoute.moreAlarmEdit ||
      AuraRoute.moreAlarmNew ||
      AuraRoute.moreSkills ||
      AuraRoute.moreConfig ||
      AuraRoute.moreConfigDevice ||
      AuraRoute.moreConfigDeviceSettings ||
      AuraRoute.moreConfigDeviceAdd ||
      AuraRoute.deviceConfigLight1 ||
      AuraRoute.deviceConfigLight2 ||
      AuraRoute.deviceConfigTv ||
      AuraRoute.deviceConfigAc ||
      AuraRoute.deviceConfigEcho ||
      AuraRoute.moreConfigWifi ||
      AuraRoute.moreConfigBluetooth ||
      AuraRoute.moreConfigDisplay ||
      AuraRoute.moreConfigLanguage ||
      AuraRoute.moreConfigNotifications ||
      AuraRoute.moreConfigPermissions ||
      AuraRoute.moreConfigNotificationsRingtone ||
      AuraRoute.moreConfigAccounts ||
      AuraRoute.moreConfigAccountsAdd ||
      AuraRoute.moreConfigAccountSettings ||
      AuraRoute.moreActivities ||
      AuraRoute.moreSupport ||
      AuraRoute.moreFeedback => AuraRoute.more,
      AuraRoute.profile ||
      AuraRoute.profileData ||
      AuraRoute.profileDataEdit ||
      AuraRoute.profileVoice ||
      AuraRoute.profileVoiceLanguage ||
      AuraRoute.profileVoiceSpeed ||
      AuraRoute.profileVoiceWakeWord ||
      AuraRoute.profilePrivacy ||
      AuraRoute.profilePrivacyHistory ||
      AuraRoute.profilePrivacySkills ||
      AuraRoute.legalTerms ||
      AuraRoute.legalPrivacy ||
      AuraRoute.skillLogin => AuraRoute.profile,
    };
  }

  AuraRoute get parentRoute {
    return switch (this) {
      AuraRoute.homeLocation || AuraRoute.auraAsk => AuraRoute.home,
      AuraRoute.communicateChat => AuraRoute.communicateMessage,
      AuraRoute.communicateCalling => AuraRoute.communicateCall,
      AuraRoute.communicateCall ||
      AuraRoute.communicateMessage ||
      AuraRoute.communicateDropIn ||
      AuraRoute.communicateAnnouncements ||
      AuraRoute.communicateAddContact ||
      AuraRoute.communicateEditContact ||
      AuraRoute.communicateAddGroup ||
      AuraRoute.communicateGroupSettings => AuraRoute.communicate,
      AuraRoute.deviceLight || AuraRoute.deviceAc => AuraRoute.devices,
      AuraRoute.moreListItems || AuraRoute.moreNoteEdit => AuraRoute.moreLists,
      AuraRoute.moreCalendarEdit => AuraRoute.moreCalendar,
      AuraRoute.moreAlarmEdit || AuraRoute.moreAlarmNew => AuraRoute.moreAlarms,
      AuraRoute.moreConfigDevice ||
      AuraRoute.moreConfig ||
      AuraRoute.moreLists ||
      AuraRoute.moreCalendar ||
      AuraRoute.moreAlarms ||
      AuraRoute.moreSkills ||
      AuraRoute.moreActivities ||
      AuraRoute.moreSupport ||
      AuraRoute.moreFeedback => AuraRoute.more,
      AuraRoute.moreConfigDeviceSettings ||
      AuraRoute.moreConfigDeviceAdd ||
      AuraRoute.moreConfigWifi ||
      AuraRoute.moreConfigBluetooth ||
      AuraRoute.moreConfigDisplay ||
      AuraRoute.moreConfigLanguage => AuraRoute.moreConfigDevice,
      AuraRoute.deviceConfigLight1 ||
      AuraRoute.deviceConfigLight2 ||
      AuraRoute.deviceConfigTv ||
      AuraRoute.deviceConfigAc ||
      AuraRoute.deviceConfigEcho => AuraRoute.moreConfigDeviceSettings,
      AuraRoute.moreConfigNotificationsRingtone =>
        AuraRoute.moreConfigNotifications,
      AuraRoute.moreConfigPermissions => AuraRoute.moreConfigNotifications,
      AuraRoute.moreConfigNotifications ||
      AuraRoute.moreConfigAccounts => AuraRoute.moreConfig,
      AuraRoute.moreConfigAccountsAdd => AuraRoute.moreConfigAccounts,
      AuraRoute.moreConfigAccountSettings => AuraRoute.moreConfigAccounts,
      AuraRoute.profileDataEdit => AuraRoute.profileData,
      AuraRoute.profileVoiceLanguage ||
      AuraRoute.profileVoiceSpeed ||
      AuraRoute.profileVoiceWakeWord => AuraRoute.profileVoice,
      AuraRoute.profilePrivacyHistory ||
      AuraRoute.profilePrivacySkills ||
      AuraRoute.legalTerms ||
      AuraRoute.legalPrivacy ||
      AuraRoute.skillLogin => AuraRoute.profilePrivacy,
      AuraRoute.profileData ||
      AuraRoute.profileVoice ||
      AuraRoute.profilePrivacy => AuraRoute.profile,
      _ => mainRoute,
    };
  }

  String get title {
    return switch (this) {
      AuraRoute.home => 'Aura Mind',
      AuraRoute.homeLocation => 'Localização',
      AuraRoute.communicate => 'Comunicação',
      AuraRoute.auraAsk => 'Perguntar para Aura',
      AuraRoute.communicateCall => 'Ligar',
      AuraRoute.communicateMessage => 'Mensagem',
      AuraRoute.communicateChat => 'Chat',
      AuraRoute.communicateDropIn => 'Drop In',
      AuraRoute.communicateAnnouncements => 'Avisos',
      AuraRoute.communicateCalling => 'Chamada',
      AuraRoute.communicateAddContact => 'Novo Contato',
      AuraRoute.communicateEditContact => 'Editar Contato',
      AuraRoute.communicateAddGroup => 'Novo Grupo',
      AuraRoute.communicateGroupSettings => 'Configurações do Grupo',
      AuraRoute.play => 'Mídia',
      AuraRoute.devices => 'Dispositivos',
      AuraRoute.deviceLight => 'Luz Principal',
      AuraRoute.deviceAc => 'Ar Condicionado',
      AuraRoute.more => 'Mais',
      AuraRoute.moreLists => 'Listas e Notas',
      AuraRoute.moreListItems => 'Lista',
      AuraRoute.moreNoteEdit => 'Nota',
      AuraRoute.moreCalendar => 'Calendário',
      AuraRoute.moreCalendarEdit => 'Lembrete',
      AuraRoute.moreAlarms => 'Alarmes e Timers',
      AuraRoute.moreAlarmEdit => 'Editar Alarme',
      AuraRoute.moreAlarmNew => 'Novo Alarme/Timer',
      AuraRoute.moreSkills => 'Skills e Jogos',
      AuraRoute.moreConfig => 'Configurações',
      AuraRoute.moreConfigDevice => 'Dispositivo',
      AuraRoute.moreConfigDeviceSettings => 'Dispositivos',
      AuraRoute.moreConfigDeviceAdd => 'Novo Dispositivo',
      AuraRoute.deviceConfigLight1 ||
      AuraRoute.deviceConfigLight2 ||
      AuraRoute.deviceConfigTv ||
      AuraRoute.deviceConfigAc ||
      AuraRoute.deviceConfigEcho => 'Configurações do Dispositivo',
      AuraRoute.moreConfigWifi => 'Rede Wi-Fi',
      AuraRoute.moreConfigBluetooth => 'Bluetooth',
      AuraRoute.moreConfigDisplay => 'Tela e Brilho',
      AuraRoute.moreConfigLanguage => 'Idioma da Aura',
      AuraRoute.moreConfigNotifications => 'Notificações',
      AuraRoute.moreConfigPermissions => 'Permissões',
      AuraRoute.moreConfigNotificationsRingtone => 'Toque de Notificação',
      AuraRoute.moreConfigAccounts => 'Contas e Perfis',
      AuraRoute.moreConfigAccountsAdd => 'Adicionar Conta',
      AuraRoute.moreConfigAccountSettings => 'Configurações do Perfil',
      AuraRoute.moreActivities => 'Atividades',
      AuraRoute.moreSupport => 'Suporte',
      AuraRoute.moreFeedback => 'Avaliar Aura Mind',
      AuraRoute.profile => 'Perfil',
      AuraRoute.profileData => 'Dados Pessoais',
      AuraRoute.profileDataEdit => 'Editar Dados',
      AuraRoute.profileVoice => 'Voz da Aura',
      AuraRoute.profileVoiceLanguage => 'Idioma da Voz',
      AuraRoute.profileVoiceSpeed => 'Velocidade da Voz',
      AuraRoute.profileVoiceWakeWord => 'Palavra de Ativação',
      AuraRoute.profilePrivacy => 'Privacidade',
      AuraRoute.profilePrivacyHistory => 'Histórico de Voz',
      AuraRoute.profilePrivacySkills => 'Permissões',
      AuraRoute.legalTerms => 'Termos de Uso',
      AuraRoute.legalPrivacy => 'Política de Privacidade',
      AuraRoute.skillLogin => 'Conectar Skill',
    };
  }
}
