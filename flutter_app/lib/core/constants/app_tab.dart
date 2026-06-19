enum AppTab { home, communicate, play, devices, more }

extension AppTabLabel on AppTab {
  String get label {
    switch (this) {
      case AppTab.home:
        return 'Início';
      case AppTab.communicate:
        return 'Mensagens';
      case AppTab.play:
        return 'Play';
      case AppTab.devices:
        return 'Dispositivos';
      case AppTab.more:
        return 'Mais';
    }
  }
}
