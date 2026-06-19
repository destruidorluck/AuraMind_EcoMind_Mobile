import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Toaster, toast } from "sonner";
import {
  Home,
  MessageSquare,
  PlayCircle,
  LayoutGrid,
  Menu,
  Mic,
  Sun,
  CloudRain,
  Music,
  Lightbulb,
  ChevronRight,
  ChevronLeft,
  User,
  Settings,
  Bell,
  Shield,
  LogOut,
  Phone,
  Video,
  Radio,
  Tv,
  Speaker,
  Thermometer,
  List,
  Clock,
  Puzzle,
  Mic2,
  Trash,
  Plus,
  Minus,
  Globe,
  Languages,
  MicOff,
  VideoOff,
  ChevronDown,
  Calendar as CalendarIcon,
  Check,
  X,
} from "lucide-react";

const LangContext = React.createContext({
  lang: "pt",
  setLang: (l: string) => {},
  t: (k: string) => k,
});

export function useLang() {
  return React.useContext(LangContext);
}

const DICTIONARY: Record<string, Record<string, string>> = {
  pt: {
    Início: "Início",
    Mensagens: "Mensagens",
    Dispositivos: "Dispositivos",
    Perfil: "Perfil",
    Configurações: "Configurações",
    "Idioma da Aura": "Idioma da Aura",
    Mais: "Mais",
    "Listas e Notas": "Listas e Notas",
    "Alarmes e Timers": "Alarmes e Timers",
    Calendário: "Calendário",
    Atividades: "Atividades",
    "Seus Dispositivos": "Seus Dispositivos",
    "Adicionar Lembrete": "Adicionar Lembrete",
    "Ligar / Desligar": "Ligar / Desligar",
    "Rede Wi-Fi": "Rede Wi-Fi",
    "Tela e Brilho": "Tela e Brilho",
    Notificações: "Notificações",
    "Contas e Perfis": "Contas e Perfis",
    "Privacidade da Conta": "Privacidade da Conta",
    Sair: "Sair",
    "Todos os Dispositivos": "Todos os Dispositivos",
    "Sala de Estar": "Sala de Estar",
    Quarto: "Quarto",
    "Configurações do Dispositivo":
      "Configurações do Dispositivo",
    "Configurações dos Dispositivos":
      "Configurações dos Dispositivos",
    "Skills e Jogos": "Skills e Jogos",
    "Toque de Notificação": "Toque de Notificação",
    "Bem-vindo(a)": "Bem-vindo(a)",
    Entrar: "Entrar",
  },
  en: {
    Início: "Home",
    Mensagens: "Messages",
    Dispositivos: "Devices",
    Perfil: "Profile",
    Configurações: "Settings",
    "Idioma da Aura": "Aura Language",
    Mais: "More",
    "Listas e Notas": "Lists & Notes",
    "Alarmes e Timers": "Alarms & Timers",
    Calendário: "Calendar",
    Atividades: "Activities",
    "Seus Dispositivos": "Your Devices",
    "Adicionar Lembrete": "Add Reminder",
    "Ligar / Desligar": "On / Off",
    "Rede Wi-Fi": "Wi-Fi Network",
    "Tela e Brilho": "Display & Brightness",
    Notificações: "Notifications",
    "Contas e Perfis": "Accounts & Profiles",
    "Privacidade da Conta": "Account Privacy",
    Sair: "Log Out",
    "Todos os Dispositivos": "All Devices",
    "Sala de Estar": "Living Room",
    Quarto: "Bedroom",
    "Configurações do Dispositivo": "Device Settings",
    "Configurações dos Dispositivos": "Device Settings",
    "Skills e Jogos": "Skills & Games",
    "Toque de Notificação": "Notification Ringtone",
    "Bem-vindo(a)": "Welcome",
    Entrar: "Sign In",
  },
  es: {
    Início: "Inicio",
    Mensagens: "Mensajes",
    Dispositivos: "Dispositivos",
    Perfil: "Perfil",
    Configurações: "Configuraciones",
    "Idioma da Aura": "Idioma de Aura",
    Mais: "Más",
    "Listas e Notas": "Listas y Notas",
    "Alarmes e Timers": "Alarmas y Temp",
    Calendário: "Calendario",
    Atividades: "Actividades",
    "Seus Dispositivos": "Tus Dispositivos",
    "Adicionar Lembrete": "Agregar Recordatorio",
    "Ligar / Desligar": "Encender / Apagar",
    "Rede Wi-Fi": "Red Wi-Fi",
    "Tela e Brilho": "Pantalla y Brillo",
    Notificações: "Notificaciones",
    "Contas e Perfis": "Cuentas y Perfiles",
    "Privacidade da Conta": "Privacidad",
    Sair: "Salir",
    "Todos os Dispositivos": "Todos los Disp.",
    "Sala de Estar": "Sala de Estar",
    Quarto: "Habitación",
    "Configurações do Dispositivo": "Config. del Dispositivo",
    "Configurações dos Dispositivos": "Config. de Dispositivos",
    "Skills e Jogos": "Skills y Juegos",
    "Toque de Notificação": "Tono de Notificación",
    "Bem-vindo(a)": "Bienvenido(a)",
    Entrar: "Entrar",
  },
};

export default function App() {
  const [activeTab, setActiveTab] = useState("home");
  const [isListening, setIsListening] = useState(false);
  const [greeting, setGreeting] = useState("Olá");
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentTemp, setCurrentTemp] = useState(24);
  const [themeMode, setThemeMode] = useState<
    "light" | "dark" | "system"
  >("dark");
  const [lang, setLang] = useState("pt");
  const [activeSkill, setActiveSkill] = useState("");
  const [location, setLocation] = useState("São Paulo");
  const [activeListTab, setActiveListTab] = useState<
    "listas" | "notas"
  >("listas");
  const [activeAlarmTab, setActiveAlarmTab] = useState<
    "alarmes" | "timers"
  >("alarmes");

  // ==========================================
  // ESTADOS GLOBAIS
  // ==========================================

  const [callingContact, setCallingContact] = useState("");
  const [chatContact, setChatContact] = useState("");
  const [selectedNoteId, setSelectedNoteId] = useState("");
  const [selectedAlarmId, setSelectedAlarmId] = useState("");
  const [selectedDeviceId, setSelectedDeviceId] = useState("");

  const [alarms, setAlarms] = useState([
    {
      id: "1",
      time: "07:00",
      label: "Seg, Ter, Qua, Qui, Sex",
      active: true,
    },
  ]);

  const [timers, setTimers] = useState([
    {
      id: "1",
      duration: "15:00",
      label: "Pizza",
      active: false,
    },
  ]);

  const [lists, setLists] = useState([
    {
      id: "1",
      title: "Compras",
      items: [
        { id: "1", text: "Leite Integral", checked: false },
        { id: "2", text: "Pão de Forma", checked: false },
        { id: "3", text: "Café", checked: true },
      ],
    },
  ]);
  const [selectedListId, setSelectedListId] = useState("");

  const [contacts, setContacts] = useState([
    {
      id: "1",
      name: "Daiany",
      time: "Celular",
      type: "Membro Aura",
    },
    { id: "2", name: "Mãe", time: "Casa", type: "Membro Aura" },
    {
      id: "3",
      name: "Lucas Tome",
      time: "Celular",
      type: "Membro Aura",
    },
    {
      id: "4",
      name: "Primo",
      time: "Celular",
      type: "Membro Aura",
    },
    {
      id: "5",
      name: "Tio Claudinho",
      time: "Casa",
      type: "Membro Aura",
    },
  ]);
  const [selectedContactId, setSelectedContactId] =
    useState("");

  const [reminders, setReminders] = useState<
    Record<
      string,
      { id: string; text: string; time?: string }[]
    >
  >({
    [`${new Date().getFullYear()}-${new Date().getMonth()}-${new Date().getDate()}`]:
      [
        { id: "1", text: "Reunião de design", time: "14:00" },
        { id: "2", text: "Comprar presente do João" },
      ],
  });
  const [selectedReminder, setSelectedReminder] =
    useState<any>(null);

  const [accounts, setAccounts] = useState([
    {
      id: "1",
      name: "Leonardo Carvalho",
      role: "Proprietário",
      image:
        "/src/imports/Captura_de_tela_2025-05-08_111333.png",
    },
  ]);

  const [ringtone, setRingtone] = useState("Radar");

  const [notes, setNotes] = useState([
    {
      id: "1",
      title: "Ideias de Presentes",
      preview: "Livro de design, fone de ouvido...",
    },
  ]);

  const [devices, setDevices] = useState([
    {
      id: "1",
      name: "Luz Principal",
      room: "Sala de Estar",
      status: "Ligado • 80%",
      active: true,
      type: "light",
      value: 80,
      icon: "lightbulb",
    },
    {
      id: "2",
      name: "Abajur",
      room: "Quarto",
      status: "Desligado",
      active: false,
      type: "light",
      value: 50,
      icon: "lightbulb",
    },
    {
      id: "3",
      name: "Smart TV",
      room: "Sala de Estar",
      status: "Desligado",
      active: false,
      type: "tv",
      icon: "tv",
    },
    {
      id: "4",
      name: "Aura Echo",
      room: "Quarto",
      status: "Pausado",
      active: true,
      type: "speaker",
      icon: "speaker",
    },
    {
      id: "5",
      name: "Ar Condicionado",
      room: "Quarto",
      status: "23°C",
      active: true,
      type: "ac",
      value: 23,
      icon: "thermometer",
    },
  ]);

  const [currentMedia, setCurrentMedia] = useState({
    title: "Midnight City",
    artist: "M83 • Hurry Up, We're Dreaming",
    img: "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=200&h=200&fit=crop",
    isPlaying: false,
  });

  // ==========================================
  // FUNÇÕES DE AÇÃO GLOBAIS
  // ==========================================

  const toggleDevice = (id: string) => {
    setDevices((prevDevices) => {
      const newDevices = prevDevices.map((d) => {
        if (d.id === id) {
          const newActive = !d.active;
          let newStatus = newActive ? "Ligado" : "Desligado";

          if (d.type === "light" && newActive)
            newStatus = `Ligado • ${d.value || 100}%`;
          if (d.type === "ac")
            newStatus = newActive
              ? `${d.value}°C`
              : "Desligado";
          if (d.type === "speaker")
            newStatus = newActive ? "Pausado" : "Desligado";

          return { ...d, active: newActive, status: newStatus };
        }
        return d;
      });

      const device = newDevices.find((d) => d.id === id);
      if (device) {
        toast.success(
          `${device.name} ${device.active ? "ligado" : "desligado"}`,
        );
      }
      return newDevices;
    });
  };

  const togglePlay = (e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    setCurrentMedia((prev) => {
      const newState = !prev.isPlaying;
      toast(newState ? "Reproduzindo" : "Pausado", {
        description: prev.title,
        icon: <PlayCircle className="w-4 h-4 text-cyan-400" />,
      });
      return { ...prev, isPlaying: newState };
    });
  };

  const playNewMedia = (media: any) => {
    setCurrentMedia({
      title: media.title,
      artist: media.subtitle || "Aura Music",
      img: media.img,
      isPlaying: true,
    });
    toast.success(`Tocando agora: ${media.title}`);
    setActiveTab("play");
  };

  // Atualizar a saudação baseada no horário
  useEffect(() => {
    const updateGreeting = () => {
      const hour = new Date().getHours();
      if (hour >= 5 && hour < 12) setGreeting("Bom dia");
      else if (hour >= 12 && hour < 18)
        setGreeting("Boa tarde");
      else setGreeting("Boa noite");
    };

    updateGreeting();
    const interval = setInterval(updateGreeting, 60000);
    return () => clearInterval(interval);
  }, []);

  // Simular temperatura em tempo real (removido interval)
  useEffect(() => {
    setCurrentTemp(24);
  }, []);

  // Simulação de comandos de voz
  useEffect(() => {
    if (isListening) {
      const timer = setTimeout(() => {
        setIsListening(false);
        toast("Entendido!", {
          description: "Processando seu comando...",
          icon: <Mic className="w-4 h-4 text-cyan-400" />,
        });
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [isListening]);

  // ==========================================
  // RENDERIZAÇÃO DAS VIEWS
  // ==========================================

  const renderView = () => {
    switch (activeTab) {
      case "home":
        return (
          <HomeView
            isListening={isListening}
            setIsListening={setIsListening}
            devices={devices}
            toggleDevice={toggleDevice}
            currentMedia={currentMedia}
            togglePlay={togglePlay}
            setActiveTab={setActiveTab}
            playNewMedia={playNewMedia}
            setSelectedDeviceId={setSelectedDeviceId}
          />
        );
      case "home_location":
        return (
          <HomeLocationView
            location={location}
            setLocation={setLocation}
            setActiveTab={setActiveTab}
          />
        );
      case "communicate":
        return (
          <CommunicateView
            setActiveTab={setActiveTab}
            setCallingContact={setCallingContact}
            contacts={contacts}
            setSelectedContactId={setSelectedContactId}
          />
        );
      case "communicate_ligar":
        return (
          <CommunicateLigarView
            contacts={contacts}
            setActiveTab={setActiveTab}
            setCallingContact={setCallingContact}
          />
        );
      case "communicate_mensagem":
        return (
          <CommunicateMensagemView
            contacts={contacts}
            setActiveTab={setActiveTab}
            setChatContact={setChatContact}
            setSelectedContactId={setSelectedContactId}
          />
        );
      case "communicate_chat":
        return (
          <CommunicateChatView
            contact={chatContact}
            contactId={selectedContactId}
            contacts={contacts}
            setContacts={setContacts}
            setActiveTab={setActiveTab}
          />
        );
      case "communicate_dropin":
        return (
          <CommunicateDropInView
            setActiveTab={setActiveTab}
            setCallingContact={setCallingContact}
          />
        );
      case "communicate_avisos":
        return <CommunicateAvisosView />;
      case "communicate_calling":
        return (
          <CommunicateCallingView
            callingContact={callingContact}
            setActiveTab={setActiveTab}
          />
        );
      case "communicate_add_contact":
        return (
          <CommunicateAddContactView
            setContacts={setContacts}
            setActiveTab={setActiveTab}
          />
        );
      case "communicate_edit_contact":
        return (
          <CommunicateEditContactView
            contactId={selectedContactId}
            contacts={contacts}
            setContacts={setContacts}
            setActiveTab={setActiveTab}
          />
        );
      case "communicate_add_group":
        return (
          <CommunicateAddGroupView
            contacts={contacts}
            setContacts={setContacts}
            setActiveTab={setActiveTab}
          />
        );

      case "play":
        return (
          <MediaView
            currentMedia={currentMedia}
            togglePlay={togglePlay}
            playNewMedia={playNewMedia}
          />
        );
      case "devices":
        return (
          <DevicesView
            devices={devices}
            toggleDevice={toggleDevice}
            setActiveTab={setActiveTab}
            setSelectedDeviceId={setSelectedDeviceId}
          />
        );
      case "device_light":
        return (
          <DeviceLightView
            device={devices.find(
              (d) => d.id === selectedDeviceId,
            )}
            toggleDevice={toggleDevice}
            setDevices={setDevices}
            setActiveTab={setActiveTab}
          />
        );
      case "device_ac":
        return (
          <DeviceAcView
            device={devices.find(
              (d) => d.id === selectedDeviceId,
            )}
            toggleDevice={toggleDevice}
            setDevices={setDevices}
            setActiveTab={setActiveTab}
          />
        );
      case "more":
        return <MoreView setActiveTab={setActiveTab} />;
      case "profile":
        return (
          <ProfileView
            setActiveTab={setActiveTab}
            onLogout={() => setIsLoggedIn(false)}
          />
        );

      // Sub-views Perfil
      case "profile_dados":
        return <ProfileDadosView setActiveTab={setActiveTab} />;
      case "profile_dados_editar":
        return (
          <ProfileDadosEditarView setActiveTab={setActiveTab} />
        );
      case "profile_voz":
        return <ProfileVozView setActiveTab={setActiveTab} />;
      case "profile_voz_idioma":
        return (
          <ProfileVozIdiomaView setActiveTab={setActiveTab} />
        );
      case "profile_voz_velocidade":
        return (
          <ProfileVozVelocidadeView
            setActiveTab={setActiveTab}
          />
        );
      case "profile_voz_palavra":
        return (
          <ProfileVozPalavraView setActiveTab={setActiveTab} />
        );
      case "profile_privacidade":
        return (
          <ProfilePrivacidadeView setActiveTab={setActiveTab} />
        );
      case "profile_privacidade_historico":
        return <ProfilePrivacidadeHistoricoView />;
      case "profile_privacidade_skills":
        return (
          <ProfilePrivacidadeSkillsView
            setActiveTab={setActiveTab}
            setActiveSkill={setActiveSkill}
          />
        );
      case "skill_login":
        return (
          <SkillLoginView
            skill={activeSkill}
            setActiveTab={setActiveTab}
          />
        );

      // Sub-views Mais
      case "more_listas":
        return (
          <MoreListasView
            lists={lists}
            setLists={setLists}
            notes={notes}
            setNotes={setNotes}
            setActiveTab={setActiveTab}
            setSelectedNoteId={setSelectedNoteId}
            activeListTab={activeListTab}
            setActiveListTab={setActiveListTab}
            setSelectedListId={setSelectedListId}
          />
        );
      case "more_lista_items":
        return (
          <MoreListaItemsView
            listId={selectedListId}
            lists={lists}
            setLists={setLists}
            setActiveTab={setActiveTab}
          />
        );
      case "more_notas_edit":
        return (
          <MoreNotasEditView
            noteId={selectedNoteId}
            notes={notes}
            setNotes={setNotes}
            setActiveTab={setActiveTab}
          />
        );
      case "more_calendario":
        return (
          <MoreCalendarioView
            reminders={reminders}
            setReminders={setReminders}
            setActiveTab={setActiveTab}
            setSelectedReminder={setSelectedReminder}
          />
        );
      case "more_calendario_edit":
        return (
          <MoreCalendarioEditView
            reminder={selectedReminder}
            reminders={reminders}
            setReminders={setReminders}
            setActiveTab={setActiveTab}
          />
        );
      case "more_alarmes":
        return (
          <MoreAlarmesView
            alarms={alarms}
            setAlarms={setAlarms}
            timers={timers}
            setTimers={setTimers}
            setActiveTab={setActiveTab}
            setSelectedAlarmId={setSelectedAlarmId}
            activeAlarmTab={activeAlarmTab}
            setActiveAlarmTab={setActiveAlarmTab}
          />
        );
      case "more_alarmes_edit":
        return (
          <MoreAlarmesEditView
            alarmId={selectedAlarmId}
            alarms={alarms}
            setAlarms={setAlarms}
            setActiveTab={setActiveTab}
          />
        );
      case "more_alarmes_new":
        return (
          <MoreAlarmesNewView
            setAlarms={setAlarms}
            setTimers={setTimers}
            setActiveTab={setActiveTab}
            activeAlarmTab={activeAlarmTab}
          />
        );
      case "more_skills":
        return (
          <MoreSkillsView
            setActiveTab={setActiveTab}
            setActiveSkill={setActiveSkill}
          />
        );
      case "more_config":
        return <MoreConfigView setActiveTab={setActiveTab} />;
      case "more_config_device":
        return (
          <MoreConfigDeviceView setActiveTab={setActiveTab} />
        );
      case "more_config_devices_settings":
        return (
          <MoreConfigDevicesSettingsView
            setActiveTab={setActiveTab}
            devices={devices}
          />
        );
      case "device_config_light_1":
        return (
          <DeviceConfigLightView
            deviceId="1"
            devices={devices}
            setDevices={setDevices}
            setActiveTab={setActiveTab}
          />
        );
      case "device_config_light_2":
        return (
          <DeviceConfigLightView
            deviceId="2"
            devices={devices}
            setDevices={setDevices}
            setActiveTab={setActiveTab}
          />
        );
      case "device_config_tv":
        return (
          <DeviceConfigTvView
            devices={devices}
            setActiveTab={setActiveTab}
          />
        );
      case "device_config_ac":
        return (
          <DeviceConfigAcView
            devices={devices}
            setActiveTab={setActiveTab}
          />
        );
      case "device_config_echo":
        return (
          <DeviceConfigEchoView
            devices={devices}
            setActiveTab={setActiveTab}
          />
        );
      case "more_config_wifi":
        return <MoreConfigWifiView />;
      case "more_config_bluetooth":
        return <MoreConfigBluetoothView />;
      case "more_config_display":
        return (
          <MoreConfigDisplayView
            themeMode={themeMode}
            setThemeMode={setThemeMode}
          />
        );
      case "more_config_language":
        return <MoreConfigLanguageView />;
      case "more_config_notifications":
        return (
          <MoreConfigNotificationsView
            setActiveTab={setActiveTab}
          />
        );
      case "more_config_notifications_ringtone":
        return (
          <MoreConfigNotificationsRingtoneView
            ringtone={ringtone}
            setRingtone={setRingtone}
          />
        );
      case "more_config_accounts":
        return (
          <MoreConfigAccountsView
            accounts={accounts}
            setActiveTab={setActiveTab}
          />
        );
      case "more_config_accounts_add":
        return (
          <MoreConfigAccountsAddView
            accounts={accounts}
            setAccounts={setAccounts}
            setActiveTab={setActiveTab}
          />
        );
      case "more_atividades":
        return <MoreAtividadesView />;

      default:
        return (
          <HomeView
            isListening={isListening}
            setIsListening={setIsListening}
            devices={devices}
            toggleDevice={toggleDevice}
            currentMedia={currentMedia}
            togglePlay={togglePlay}
            setActiveTab={setActiveTab}
            playNewMedia={playNewMedia}
            setSelectedDeviceId={setSelectedDeviceId}
          />
        );
    }
  };

  const getTabTitle = () => {
    switch (activeTab) {
      case "home_location":
        return "Localização";
      case "communicate":
        return "Conversa";
      case "communicate_ligar":
        return "Ligar";
      case "communicate_mensagem":
        return "Mensagem";
      case "communicate_dropin":
        return "Drop In";
      case "communicate_avisos":
        return "Avisos";
      case "communicate_calling":
        return "Chamada em Andamento";
      case "communicate_add_contact":
        return "Novo Contato";
      case "communicate_edit_contact":
        return "Editar Contato";
      case "communicate_add_group":
        return "Novo Grupo";
      case "play":
        return "Mídia";
      case "devices":
        return "Dispositivos";
      case "more":
        return "Mais Opções";
      case "profile":
        return "Meu Perfil";
      case "profile_dados":
        return "Meus Dados";
      case "profile_dados_editar":
        return "Editar Dados";
      case "profile_voz":
        return "Voz e Respostas";
      case "profile_voz_idioma":
        return "Idioma da Aura";
      case "profile_voz_velocidade":
        return "Velocidade da Voz";
      case "profile_voz_palavra":
        return "Palavra de Ativação";
      case "profile_privacidade":
        return "Privacidade";
      case "profile_privacidade_historico":
        return "Histórico de Voz";
      case "profile_privacidade_skills":
        return "Permissões de Skills";
      case "skill_login":
        return "Conectar Conta";
      case "more_calendario":
        return "Calendário";
      case "more_listas":
        return "Listas e Notas";
      case "more_alarmes":
        return "Alarmes e Timers";
      case "more_alarmes_new":
        return "Novo Alarme/Timer";
      case "more_skills":
        return "Skills e Jogos";
      case "more_config":
        return "Configurações";
      case "more_config_device":
        return "Dispositivo";
      case "more_config_devices_settings":
        return "Configurações dos Dispositivos";
      case "device_config_light_1":
        return "Luz Principal";
      case "device_config_light_2":
        return "Abajur";
      case "device_config_tv":
        return "Smart TV";
      case "device_config_ac":
        return "Ar Condicionado";
      case "device_config_echo":
        return "Aura Echo";
      case "more_config_wifi":
        return "Rede Wi-Fi";
      case "more_config_bluetooth":
        return "Bluetooth";
      case "more_config_display":
        return "Tela e Brilho";
      case "more_config_language":
        return "Idioma da Aura";
      case "more_config_notifications":
        return "Notificações";
      case "more_config_notifications_ringtone":
        return "Toque de Notificação";
      case "more_config_accounts":
        return "Contas e Perfis";
      case "more_atividades":
        return "Atividades";
      default:
        return "Aura Mind";
    }
  };

  const isSubView = activeTab.includes("_");
  let parentTab = isSubView
    ? activeTab.split("_")[0]
    : activeTab;

  if (activeTab === "home_location") parentTab = "home";
  if (activeTab.startsWith("profile_dados_"))
    parentTab = "profile_dados";
  if (activeTab.startsWith("profile_voz_"))
    parentTab = "profile_voz";
  if (activeTab.startsWith("profile_privacidade_"))
    parentTab = "profile_privacidade";
  if (activeTab === "skill_login")
    parentTab = "profile_privacidade_skills";
  if (
    activeTab === "more_config_wifi" ||
    activeTab === "more_config_bluetooth" ||
    activeTab === "more_config_display" ||
    activeTab === "more_config_language"
  )
    parentTab = "more_config_device";
  if (activeTab === "more_config_devices_settings")
    parentTab = "more_config_device";
  if (activeTab.startsWith("device_config_"))
    parentTab = "more_config_devices_settings";
  if (activeTab === "more_config_notifications_ringtone")
    parentTab = "more_config_notifications";
  if (activeTab === "more_notas_edit")
    parentTab = "more_listas";
  if (activeTab === "more_calendario_edit")
    parentTab = "more_calendario";
  if (activeTab === "more_alarmes_edit")
    parentTab = "more_alarmes";
  if (activeTab === "more_config_accounts_add")
    parentTab = "more_config_accounts";
  if (activeTab === "device_light" || activeTab === "device_ac")
    parentTab = "devices";
  if (activeTab === "communicate_chat")
    parentTab = "communicate_mensagem";
  if (activeTab === "communicate_add_contact")
    parentTab = "communicate";
  if (activeTab === "communicate_edit_contact")
    parentTab = "communicate";
  if (activeTab === "communicate_add_group")
    parentTab = "communicate";

  const t = (k: string) => DICTIONARY[lang]?.[k] || k;

  if (!isLoggedIn) {
    return (
      <LangContext.Provider value={{ lang, setLang, t }}>
        <LoginView onLogin={() => setIsLoggedIn(true)} />
      </LangContext.Provider>
    );
  }

  const systemPrefersDark =
    typeof window !== "undefined" &&
    window.matchMedia("(prefers-color-scheme: dark)").matches;
  const effectiveTheme =
    themeMode === "system"
      ? systemPrefersDark
        ? "dark"
        : "light"
      : themeMode;
  const isLightMode = effectiveTheme === "light";

  return (
    <LangContext.Provider value={{ lang, setLang, t }}>
      <div
        className={`flex justify-center bg-black min-h-screen ${isLightMode ? "theme-light" : ""}`}
      >
        <Toaster
          theme={isLightMode ? "light" : "dark"}
          position="top-center"
          className="mt-8"
        />
        <style>{`
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* ===== LIGHT THEME: Override Tailwind v4 zinc CSS custom properties ===== */
        /* This automatically handles ALL opacity modifiers: /60, /50, /40, /80, etc. */
        .theme-light {
          --color-zinc-950: #f0f4f8;
          --color-zinc-900: #ffffff;
          --color-zinc-800: #e8e8ed;
          --color-zinc-700: #d4d4d8;
          --color-zinc-600: #a1a1aa;
          --color-zinc-500: #71717a;
          --color-zinc-400: #52525b;
          --color-zinc-300: #3f3f46;
          --color-zinc-200: #27272a;
          --color-zinc-100: #18181b;
        }

        /* Outer wrapper bg-black (same element as theme-light) */
        .theme-light.bg-black { background-color: #f0f4f8 !important; }

        /* Tailwind white is not a CSS variable - must override explicitly */
        .theme-light .text-white { color: #09090b !important; }

        /* Cyan — darken for better contrast on light backgrounds */
        .theme-light .text-cyan-400 { color: #0e7490 !important; }
        .theme-light .text-cyan-300 { color: #0891b2 !important; }
        .theme-light .text-cyan-500 { color: #06b6d4 !important; }

        /* Indigo/purple text on gradient media card */
        .theme-light .text-indigo-300 { color: #3730a3 !important; }
        .theme-light .text-indigo-200 { color: #4338ca !important; }

        /* Inputs and form elements */
        .theme-light input:not([type="range"]):not([type="time"]),
        .theme-light textarea,
        .theme-light select {
          color: #09090b !important;
          background-color: #f4f4f5 !important;
          border-color: #d4d4d8 !important;
        }
        .theme-light ::placeholder { color: #a1a1aa !important; }

        /* Header */
        .theme-light header {
          background-color: rgba(240, 244, 248, 0.97) !important;
          border-bottom-color: #d4d4d8 !important;
        }

        /* Media gradient card - lighten indigo/purple tint */
        .theme-light .border-indigo-500\\/20 { border-color: rgba(99, 102, 241, 0.3) !important; }
        .theme-light .border-indigo-500\\/50 { border-color: rgba(99, 102, 241, 0.5) !important; }

        /* Active/connected device cards */
        .theme-light .border-cyan-900\\/50 { border-color: rgba(14, 116, 144, 0.35) !important; }
        .theme-light .bg-cyan-950\\/10 { background-color: rgba(14, 116, 144, 0.06) !important; }
        .theme-light .bg-cyan-900\\/20 { background-color: rgba(14, 116, 144, 0.08) !important; }
        .theme-light .bg-cyan-900\\/30 { background-color: rgba(14, 116, 144, 0.12) !important; }
        .theme-light .border-cyan-800 { border-color: rgba(14, 116, 144, 0.45) !important; }
        .theme-light .border-cyan-500\\/50 { border-color: rgba(6, 182, 212, 0.5) !important; }

        /* Device icon tints */
        .theme-light .bg-cyan-500\\/20 { background-color: rgba(6, 182, 212, 0.18) !important; }
        .theme-light .bg-yellow-500\\/20 { background-color: rgba(234, 179, 8, 0.18) !important; }
        .theme-light .bg-blue-500\\/20 { background-color: rgba(59, 130, 246, 0.18) !important; }
        .theme-light .bg-blue-600\\/30 { background-color: rgba(37, 99, 235, 0.15) !important; }

        /* Amber notice card */
        .theme-light .text-amber-100 { color: #78350f !important; }
        .theme-light .bg-amber-400\\/10 { background-color: rgba(251, 191, 36, 0.15) !important; }
        .theme-light .border-amber-400\\/20 { border-color: rgba(251, 191, 36, 0.4) !important; }

        /* Note/sticky cards */
        .theme-light .bg-yellow-500\\/10 { background-color: rgba(234, 179, 8, 0.1) !important; }
        .theme-light .border-yellow-500\\/20 { border-color: rgba(234, 179, 8, 0.35) !important; }

        /* Red delete/danger tints */
        .theme-light .bg-red-500\\/10 { background-color: rgba(239, 68, 68, 0.12) !important; }
        .theme-light .border-red-500\\/30 { border-color: rgba(239, 68, 68, 0.4) !important; }

        /* Skill icon bgs */
        .theme-light .bg-green-500\\/20 { background-color: rgba(34, 197, 94, 0.18) !important; }
        .theme-light .bg-orange-500\\/20 { background-color: rgba(249, 115, 22, 0.18) !important; }

        /* Radio/checkbox border */
        .theme-light .border-zinc-600 { border-color: #a1a1aa !important; }
        .theme-light .border-zinc-500 { border-color: #71717a !important; }

        /* Chat received message bubble */
        .theme-light .bg-zinc-800.rounded-bl-sm { background-color: #e0e0e8 !important; color: #09090b !important; }
      `}</style>

        <div className="w-full max-w-md bg-zinc-950 min-h-screen text-zinc-100 flex flex-col relative overflow-hidden shadow-2xl sm:border-x sm:border-zinc-800">
          {/* Header */}
          <header className="px-6 pt-12 pb-4 flex justify-between items-center bg-zinc-950/90 backdrop-blur-md z-40 shrink-0 border-b border-zinc-800/50 min-h-[90px]">
            {activeTab === "home" ? (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="flex flex-1 justify-between items-start mr-4"
              >
                <div>
                  <p className="text-zinc-400 text-sm font-medium">
                    {greeting}
                  </p>
                  <h1 className="text-2xl font-bold text-white tracking-tight">
                    Leonardo
                  </h1>
                </div>
                <div
                  className="flex flex-col items-end cursor-pointer active:scale-95 transition-transform"
                  onClick={() => setActiveTab("home_location")}
                >
                  <motion.span
                    key={currentTemp}
                    initial={{ opacity: 0, y: -5 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-2xl font-bold text-white"
                  >
                    {currentTemp}°C
                  </motion.span>
                  <span className="text-zinc-400 text-xs flex items-center gap-1">
                    {currentTemp > 25 ? (
                      <Sun className="w-3 h-3 text-amber-400" />
                    ) : (
                      <CloudRain className="w-3 h-3 text-blue-400" />
                    )}
                    {location}
                  </span>
                </div>
              </motion.div>
            ) : isSubView ? (
              <div className="flex items-center gap-1 -ml-2">
                <button
                  onClick={() => {
                    let backTab = parentTab;
                    if (activeTab === "communicate_calling")
                      backTab = "communicate_ligar";
                    if (activeTab.startsWith("more_config_"))
                      backTab = "more_config";
                    if (activeTab === "more_alarmes_new")
                      backTab = "more_alarmes";
                    setActiveTab(backTab);
                  }}
                  className="p-2 hover:bg-zinc-800 rounded-full transition-colors active:scale-95 cursor-pointer"
                >
                  <ChevronLeft className="w-6 h-6 text-white" />
                </button>
                <motion.div
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                >
                  <h1 className="text-xl font-bold text-white tracking-tight">
                    {getTabTitle()}
                  </h1>
                </motion.div>
              </div>
            ) : (
              <motion.div
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                className="flex-1 flex justify-between items-center pr-4"
              >
                <h1 className="text-2xl font-bold text-white tracking-tight">
                  {getTabTitle()}
                </h1>
                {parentTab === "communicate" && !isSubView && (
                  <button
                    onClick={() =>
                      setActiveTab("communicate_add_contact")
                    }
                    className="p-2 bg-zinc-800 rounded-full text-zinc-300 hover:text-white active:scale-95 transition-transform"
                  >
                    <Plus className="w-5 h-5" />
                  </button>
                )}
              </motion.div>
            )}

            <div className="flex items-center gap-3">
              <div
                onClick={() => setActiveTab("profile")}
                className={`w-10 h-10 rounded-full p-[2px] cursor-pointer transition-transform hover:scale-105 ${activeTab.startsWith("profile") ? "bg-gradient-to-tr from-cyan-400 to-blue-500" : "bg-zinc-800"}`}
              >
                <div className="w-full h-full rounded-full bg-zinc-900 border-2 border-zinc-900 overflow-hidden">
                  <img
                    src="/src/imports/Captura_de_tela_2025-05-08_111333.png"
                    alt="User Profile"
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>
            </div>
          </header>

          {/* Content */}
          <div className="flex-1 overflow-y-auto no-scrollbar pb-24 relative">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.2 }}
                className="min-h-full"
              >
                {renderView()}
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Aura Floating Mic Button */}
          <div className="absolute bottom-24 right-4 z-40">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsListening(!isListening)}
              className={`w-14 h-14 rounded-full flex items-center justify-center shadow-lg transition-colors ${
                isListening
                  ? "bg-cyan-500 text-white shadow-cyan-500/40"
                  : "bg-zinc-800 text-cyan-400 border border-zinc-700 hover:bg-zinc-700 shadow-xl"
              }`}
            >
              <Mic className="w-6 h-6" />
            </motion.button>
          </div>

          {/* Bottom Navigation */}
          <div className="bg-zinc-950/90 backdrop-blur-xl border-t border-zinc-800 absolute bottom-0 w-full z-50 pb-safe">
            <div className="flex justify-around items-center h-20 px-2 pb-2">
              <NavItem
                icon={<Home />}
                label={t("Início")}
                isActive={activeTab === "home"}
                onClick={() => setActiveTab("home")}
              />
              <NavItem
                icon={<MessageSquare />}
                label={t("Mensagens")}
                isActive={activeTab === "communicate"}
                onClick={() => setActiveTab("communicate")}
              />
              <NavItem
                icon={<PlayCircle />}
                label="Mídia"
                isActive={activeTab === "play"}
                onClick={() => setActiveTab("play")}
              />
              <NavItem
                icon={<LayoutGrid />}
                label={t("Dispositivos")}
                isActive={activeTab === "devices"}
                onClick={() => setActiveTab("devices")}
              />
              <NavItem
                icon={<Menu />}
                label={t("Mais")}
                isActive={activeTab.startsWith("more")}
                onClick={() => setActiveTab("more")}
              />
            </div>
          </div>
        </div>
      </div>
    </LangContext.Provider>
  );
}

// ==========================================
// VIEWS COMPONENTS
// ==========================================

function HomeView({
  isListening,
  setIsListening,
  devices,
  toggleDevice,
  currentMedia,
  togglePlay,
  setActiveTab,
  playNewMedia,
  setSelectedDeviceId,
}: any) {
  const handleSuggestion = (type: string) => {
    if (type === "light") {
      const mainLight = devices.find((d: any) => d.id === "1");
      if (mainLight && !mainLight.active) toggleDevice("1");
      else if (mainLight)
        toast.info("A luz da sala já está ligada!");
    } else if (type === "jazz") {
      playNewMedia({
        title: "Jazz Focus",
        subtitle: "Playlist para relaxar",
        img: "https://images.unsplash.com/photo-1493225457124-a1a2a5f5f924?w=150&h=150&fit=crop",
      });
    } else if (type === "weather") {
      toast("Previsão do Tempo", {
        description:
          "Não há previsão de chuva para hoje. Máxima de 26°C.",
        icon: <Sun className="w-4 h-4 text-amber-400" />,
      });
    }
  };

  const homeDevices = devices.slice(0, 4);

  return (
    <div className="flex flex-col">
      <div className="relative py-8 flex flex-col items-center justify-center min-h-[280px]">
        <motion.div
          className="relative w-48 h-48 flex items-center justify-center cursor-pointer"
          onClick={() => setIsListening(!isListening)}
          whileTap={{ scale: 0.95 }}
        >
          <motion.div
            className="absolute inset-0 rounded-full bg-cyan-500/20 blur-2xl"
            animate={{
              scale: isListening ? [1, 1.5, 1] : [1, 1.1, 1],
              opacity: isListening
                ? [0.5, 0.8, 0.5]
                : [0.3, 0.5, 0.3],
            }}
            transition={{
              duration: isListening ? 1.5 : 4,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
          <motion.div
            className="absolute inset-4 rounded-full bg-blue-600/30 blur-xl"
            animate={{
              scale: isListening ? [1, 1.2, 1] : [1, 1.05, 1],
              rotate: [0, 90, 180, 270, 360],
            }}
            transition={{
              scale: {
                duration: isListening ? 1 : 3,
                repeat: Infinity,
                ease: "easeInOut",
              },
              rotate: {
                duration: 10,
                repeat: Infinity,
                ease: "linear",
              },
            }}
          />

          <div className="relative w-32 h-32 rounded-full bg-gradient-to-tr from-cyan-400 via-blue-500 to-indigo-600 p-[2px] shadow-[0_0_40px_rgba(6,182,212,0.3)] z-10">
            <div className="w-full h-full rounded-full bg-zinc-950 flex items-center justify-center overflow-hidden relative">
              {isListening ? (
                <div className="flex gap-1 items-center justify-center h-full">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <motion.div
                      key={i}
                      className="w-1.5 bg-cyan-400 rounded-full"
                      animate={{
                        height: ["10px", "40px", "10px"],
                      }}
                      transition={{
                        duration: 0.8,
                        repeat: Infinity,
                        delay: i * 0.1,
                        ease: "easeInOut",
                      }}
                    />
                  ))}
                </div>
              ) : (
                <div className="absolute inset-0 bg-gradient-to-tr from-cyan-500/20 to-blue-600/20" />
              )}
              {!isListening && (
                <img
                  src="/src/imports/logo-light.png"
                  alt="Aura Mind"
                  className="w-16 h-16 object-contain relative z-10"
                />
              )}
            </div>
          </div>
        </motion.div>

        <AnimatePresence>
          {isListening ? (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="mt-6 text-cyan-300 font-medium text-lg"
            >
              Ouvindo...
            </motion.div>
          ) : (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="mt-6 text-zinc-400 text-sm"
            >
              Toque para falar com Aura Mind
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <div className="px-4 space-y-4 pb-4">
        <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4">
          <button
            onClick={() => handleSuggestion("light")}
            className="whitespace-nowrap bg-zinc-900 border border-zinc-800 hover:border-zinc-700 rounded-full px-4 py-2 text-sm font-medium text-zinc-300 flex items-center gap-2 transition-colors cursor-pointer active:scale-95"
          >
            <Lightbulb className="w-4 h-4 text-yellow-400" />{" "}
            Ligar luzes
          </button>
          <button
            onClick={() => handleSuggestion("jazz")}
            className="whitespace-nowrap bg-zinc-900 border border-zinc-800 hover:border-zinc-700 rounded-full px-4 py-2 text-sm font-medium text-zinc-300 flex items-center gap-2 transition-colors cursor-pointer active:scale-95"
          >
            <Music className="w-4 h-4 text-purple-400" /> Tocar
            jazz
          </button>
          <button
            onClick={() => handleSuggestion("weather")}
            className="whitespace-nowrap bg-zinc-900 border border-zinc-800 hover:border-zinc-700 rounded-full px-4 py-2 text-sm font-medium text-zinc-300 flex items-center gap-2 transition-colors cursor-pointer active:scale-95"
          >
            <CloudRain className="w-4 h-4 text-blue-400" /> Vai
            chover?
          </button>
        </div>

        <div className="bg-zinc-900/60 rounded-3xl p-5 border border-zinc-800/50 backdrop-blur-sm">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-white">
              Casa Inteligente
            </h2>
            <button
              onClick={() => setActiveTab("devices")}
              className="text-cyan-400 text-sm font-medium flex items-center hover:text-cyan-300 cursor-pointer active:scale-95 transition-transform"
            >
              Ver tudo <ChevronRight className="w-4 h-4" />
            </button>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {homeDevices.map((device: any) => {
              const getSettingsRoute = () => {
                if (device.id === "1" || device.id === "2")
                  return "device_config_light_" + device.id;
                if (device.id === "3")
                  return "device_config_tv";
                if (device.id === "4")
                  return "device_config_echo";
                if (device.id === "5")
                  return "device_config_ac";
                return "";
              };
              return (
                <DeviceCard
                  key={device.id}
                  icon={
                    device.type === "light" ? (
                      <Lightbulb />
                    ) : device.type === "tv" ? (
                      <Tv />
                    ) : device.type === "speaker" ? (
                      <Speaker />
                    ) : (
                      <Thermometer />
                    )
                  }
                  name={device.name}
                  room={device.room}
                  status={device.status}
                  active={device.active}
                  onClick={() => {
                    if (device.id === "1") {
                      setSelectedDeviceId("1");
                      setActiveTab("device_light");
                    } else if (device.id === "5") {
                      setSelectedDeviceId("5");
                      setActiveTab("device_ac");
                    } else toggleDevice(device.id);
                  }}
                  onToggle={() => toggleDevice(device.id)}
                  onSettings={() => {
                    const route = getSettingsRoute();
                    if (route) setActiveTab(route);
                  }}
                />
              );
            })}
          </div>
        </div>

        <div
          onClick={() => setActiveTab("play")}
          className={`bg-gradient-to-br from-indigo-900/40 to-purple-900/40 rounded-3xl p-5 border ${currentMedia.isPlaying ? "border-indigo-500/50 shadow-[0_0_20px_rgba(99,102,241,0.15)]" : "border-indigo-500/20"} backdrop-blur-sm cursor-pointer hover:border-indigo-500/40 transition-all active:scale-[0.98]`}
        >
          <div className="flex gap-4 items-center">
            <div className="w-16 h-16 rounded-xl overflow-hidden shadow-lg flex-shrink-0 relative">
              <img
                src={currentMedia.img}
                alt="Album art"
                className={`w-full h-full object-cover transition-transform duration-700 ${currentMedia.isPlaying ? "scale-110" : "scale-100"}`}
              />
              {currentMedia.isPlaying && (
                <div className="absolute inset-0 bg-black/20 flex items-center justify-center gap-0.5">
                  {[1, 2, 3].map((i) => (
                    <motion.div
                      key={i}
                      className="w-1 bg-white/80 rounded-full"
                      animate={{
                        height: ["4px", "12px", "4px"],
                      }}
                      transition={{
                        duration: 0.6,
                        repeat: Infinity,
                        delay: i * 0.15,
                      }}
                    />
                  ))}
                </div>
              )}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-xs text-indigo-300 uppercase tracking-wider font-semibold mb-1">
                Tocando Agora
              </p>
              <h3 className="text-white font-medium truncate">
                {currentMedia.title}
              </h3>
              <p className="text-indigo-200 text-sm truncate">
                {currentMedia.artist}
              </p>
            </div>
            <button
              onClick={togglePlay}
              className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors cursor-pointer active:scale-90 z-10 relative"
            >
              {currentMedia.isPlaying ? (
                <div className="w-3 h-3 flex justify-between">
                  <div className="w-1 bg-white rounded-sm" />
                  <div className="w-1 bg-white rounded-sm" />
                </div>
              ) : (
                <PlayCircle className="w-6 h-6" />
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function HomeLocationView({
  location,
  setLocation,
  setActiveTab,
}: any) {
  const [inputVal, setInputVal] = useState(location);

  const handleSave = () => {
    if (inputVal.trim()) {
      setLocation(inputVal.trim());
      toast.success("Localização atualizada");
      setActiveTab("home");
    }
  };

  return (
    <div className="px-4 py-6 space-y-5">
      <div className="bg-cyan-900/20 p-5 rounded-3xl border border-cyan-800/50 flex gap-4 items-start">
        <Sun className="w-6 h-6 text-cyan-400 shrink-0" />
        <p className="text-cyan-100 text-sm">
          Defina sua região para obter dados precisos de
          temperatura, clima e rotinas automatizadas.
        </p>
      </div>
      <div className="space-y-1">
        <label className="text-sm font-medium text-zinc-400 px-2">
          Cidade ou Região
        </label>
        <input
          type="text"
          value={inputVal}
          onChange={(e) => setInputVal(e.target.value)}
          placeholder="Ex: São Paulo"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500 transition-colors"
        />
      </div>
      <button
        onClick={handleSave}
        className="w-full py-4 rounded-full bg-cyan-500 text-black font-bold hover:bg-cyan-400 transition-colors active:scale-[0.98] mt-4 shadow-lg shadow-cyan-500/20"
      >
        Salvar Região
      </button>
    </div>
  );
}

function CommunicateView({
  setActiveTab,
  setCallingContact,
  contacts,
  setSelectedContactId,
}: any) {
  const handleAction = (type: string) =>
    toast(`Iniciando ${type}...`, { icon: "💬" });

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="grid grid-cols-4 gap-4 mb-6">
        <ActionIcon
          icon={<Phone className="w-6 h-6" />}
          label="Ligar"
          color="text-green-400"
          bg="bg-green-400/10"
          onClick={() => setActiveTab("communicate_ligar")}
        />
        <ActionIcon
          icon={<MessageSquare className="w-6 h-6" />}
          label="Mensagem"
          color="text-blue-400"
          bg="bg-blue-400/10"
          onClick={() => setActiveTab("communicate_mensagem")}
        />
        <ActionIcon
          icon={<Radio className="w-6 h-6" />}
          label="Drop In"
          color="text-purple-400"
          bg="bg-purple-400/10"
          onClick={() => setActiveTab("communicate_dropin")}
        />
        <ActionIcon
          icon={<Bell className="w-6 h-6" />}
          label="Avisos"
          color="text-amber-400"
          bg="bg-amber-400/10"
          onClick={() => setActiveTab("communicate_avisos")}
        />
      </div>

      <div className="mb-8">
        <button
          onClick={() => setActiveTab("communicate_add_group")}
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl py-3 px-4 flex items-center justify-center gap-2 text-cyan-400 font-medium active:scale-95 transition-transform hover:bg-zinc-800"
        >
          <Plus className="w-5 h-5" /> Criar Novo Grupo
        </button>
      </div>

      <div>
        <h2 className="text-lg font-semibold text-white mb-4 px-2">
          Recentes
        </h2>
        <div className="space-y-3">
          <ContactCard
            name="Daiany"
            time="Há 2 horas"
            type="Chamada de voz"
            onClick={() => {
              setCallingContact("Daiany");
              setActiveTab("communicate_calling");
            }}
          />
          <ContactCard
            name="Mãe"
            time="Ontem"
            type="Drop In"
            onClick={() => setActiveTab("communicate_dropin")}
          />
          <ContactCard
            name="Grupo Família"
            time="Segunda-feira"
            type="Aviso"
            onClick={() => setActiveTab("communicate_avisos")}
          />
        </div>
      </div>

      <div className="mt-8">
        <h2 className="text-lg font-semibold text-white mb-4 px-2">
          Contatos Salvos
        </h2>
        <p className="text-zinc-500 text-xs px-2 mb-3">
          Clique em um contato para editar ou excluir.
        </p>
        <div className="space-y-3">
          {contacts?.map((c: any) => (
            <ContactCard
              key={c.id}
              name={c.name}
              time={c.time}
              type={c.type}
              onClick={() => {
                setSelectedContactId(c.id);
                setActiveTab("communicate_edit_contact");
              }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

function CommunicateLigarView({
  contacts,
  setActiveTab,
  setCallingContact,
}: any) {
  const handleCall = (name: string) => {
    setCallingContact(name);
    setActiveTab("communicate_calling");
  };

  return (
    <div className="px-4 py-6 space-y-4">
      <p className="text-zinc-400 px-2">
        Selecione para quem deseja ligar
      </p>
      <div className="space-y-3">
        {contacts.map((c: any) => (
          <ContactCard
            key={c.id}
            name={c.name}
            time={c.time}
            type={c.type}
            onClick={() => handleCall(c.name)}
          />
        ))}
      </div>
    </div>
  );
}

function CommunicateMensagemView({
  contacts,
  setActiveTab,
  setChatContact,
  setSelectedContactId,
}: any) {
  const handleChat = (c: any) => {
    setChatContact(c.name);
    setSelectedContactId(c.id);
    setActiveTab("communicate_chat");
  };

  return (
    <div className="px-4 py-6 space-y-4">
      <p className="text-zinc-400 px-2">
        Selecione para quem deseja enviar mensagem
      </p>
      <div className="space-y-3">
        {contacts.map((c: any) => (
          <ContactCard
            key={c.id}
            name={c.name}
            time={c.time}
            type={c.type}
            onClick={() => handleChat(c)}
          />
        ))}
      </div>
    </div>
  );
}

function CommunicateChatView({
  contact,
  contactId,
  contacts,
  setContacts,
  setActiveTab,
}: any) {
  const [msg, setMsg] = useState("");
  const [messages, setMessages] = useState([
    {
      id: 1,
      text: "Oi, tudo bem?",
      sent: false,
      time: "10:30",
    },
    {
      id: 2,
      text: "Tudo ótimo e você?",
      sent: true,
      time: "10:32",
    },
  ]);

  const handleSend = () => {
    if (!msg) return;
    setMessages([
      ...messages,
      {
        id: Date.now(),
        text: msg,
        sent: true,
        time: new Date().toLocaleTimeString([], {
          hour: "2-digit",
          minute: "2-digit",
        }),
      },
    ]);
    setMsg("");
    setTimeout(() => toast.success("Mensagem enviada"), 500);
  };

  return (
    <div className="flex flex-col h-[75vh]">
      <div
        className="px-4 py-4 border-b border-zinc-800/50 bg-zinc-900/40 flex items-center justify-between cursor-pointer active:bg-zinc-800/50 transition-colors"
        onClick={() => setActiveTab("communicate_edit_contact")}
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center text-white font-bold">
            {contact?.charAt(0) || "U"}
          </div>
          <div>
            <h3 className="text-white font-medium leading-tight">
              {contact}
            </h3>
            <p className="text-cyan-400 text-xs">
              Editar Contato
            </p>
          </div>
        </div>
        <Settings className="w-5 h-5 text-zinc-500" />
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`flex flex-col ${m.sent ? "items-end" : "items-start"}`}
          >
            <div
              className={`max-w-[80%] rounded-2xl p-3 ${m.sent ? "bg-cyan-600 text-white rounded-br-sm" : "bg-zinc-800 text-zinc-100 rounded-bl-sm"}`}
            >
              {m.text}
            </div>
            <span className="text-zinc-500 text-[10px] mt-1 px-1">
              {m.time}
            </span>
          </div>
        ))}
      </div>

      <div className="px-4 py-4 border-t border-zinc-800/50 bg-zinc-950 mt-auto">
        <div className="flex gap-2">
          <input
            type="text"
            value={msg}
            onChange={(e) => setMsg(e.target.value)}
            placeholder="Escreva uma mensagem..."
            className="flex-1 bg-zinc-900 border border-zinc-800 rounded-full px-4 text-white outline-none focus:border-cyan-500"
            onKeyDown={(e) => e.key === "Enter" && handleSend()}
          />
          <button
            onClick={handleSend}
            className="w-12 h-12 rounded-full bg-cyan-500 flex items-center justify-center text-black active:scale-95 shadow-lg shadow-cyan-500/20"
          >
            <MessageSquare className="w-5 h-5 fill-current" />
          </button>
        </div>
      </div>
    </div>
  );
}

function CommunicateDropInView({
  setActiveTab,
  setCallingContact,
}: any) {
  const handleDropIn = (device: string) => {
    setCallingContact(`Drop In: ${device}`);
    setActiveTab("communicate_calling");
  };

  return (
    <div className="px-4 py-6 space-y-4">
      <p className="text-zinc-400 px-2">
        Selecione um dispositivo para se conectar imediatamente
      </p>
      <div className="grid grid-cols-2 gap-4">
        <div
          onClick={() => handleDropIn("Aura Echo Quarto")}
          className="bg-zinc-900/60 p-4 rounded-3xl border border-zinc-800/50 cursor-pointer active:scale-95 flex flex-col items-center justify-center gap-3"
        >
          <Speaker className="w-8 h-8 text-purple-400" />
          <p className="text-white font-medium text-center">
            Aura Echo Quarto
          </p>
        </div>
        <div
          onClick={() => handleDropIn("Aura Show Cozinha")}
          className="bg-zinc-900/60 p-4 rounded-3xl border border-zinc-800/50 cursor-pointer active:scale-95 flex flex-col items-center justify-center gap-3"
        >
          <Tv className="w-8 h-8 text-purple-400" />
          <p className="text-white font-medium text-center">
            Aura Show Cozinha
          </p>
        </div>
      </div>
    </div>
  );
}

function CommunicateAvisosView() {
  const [text, setText] = useState("");
  const [isRecording, setIsRecording] = useState(false);

  const handleAviso = () => {
    if (!text && !isRecording) return;
    toast.success(
      "Aviso transmitido em todos os dispositivos!",
    );
    setText("");
    setIsRecording(false);
  };

  const toggleRecord = () => {
    if (isRecording) {
      handleAviso();
    } else {
      setIsRecording(true);
      toast.info("Gravando aviso...");
    }
  };

  const handlePreset = (msg: string) => {
    setText(msg);
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="bg-amber-400/10 p-5 rounded-3xl border border-amber-400/20 flex gap-4 items-start">
        <Bell className="w-6 h-6 text-amber-400 shrink-0" />
        <p className="text-amber-100 text-sm">
          Os avisos são reproduzidos imediatamente em todos os
          seus dispositivos Aura conectados em casa.
        </p>
      </div>
      <div className="bg-zinc-900 p-4 rounded-3xl border border-zinc-800">
        <textarea
          value={isRecording ? "Gravando áudio..." : text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Ex: A janta está pronta!"
          className="w-full bg-transparent text-white placeholder-zinc-500 resize-none outline-none h-24"
          readOnly={isRecording}
        />
        <div className="flex justify-between items-center mt-2">
          <button
            onClick={toggleRecord}
            className={`p-2 rounded-full ${isRecording ? "bg-red-500 text-white animate-pulse" : "text-amber-400 bg-amber-900/20"}`}
          >
            <Mic className="w-5 h-5" />
          </button>
          <button
            onClick={handleAviso}
            className="px-6 py-2 bg-amber-500 text-black font-semibold rounded-full active:scale-95 transition-transform"
          >
            Anunciar
          </button>
        </div>
      </div>
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => handlePreset('"É hora de acordar"')}
          className="bg-zinc-800 px-4 py-2 rounded-full text-sm text-zinc-300 active:scale-95 hover:bg-zinc-700"
        >
          "É hora de acordar"
        </button>
        <button
          onClick={() => handlePreset('"Venham comer"')}
          className="bg-zinc-800 px-4 py-2 rounded-full text-sm text-zinc-300 active:scale-95 hover:bg-zinc-700"
        >
          "Venham comer"
        </button>
        <button
          onClick={() => handlePreset('"Estou saindo"')}
          className="bg-zinc-800 px-4 py-2 rounded-full text-sm text-zinc-300 active:scale-95 hover:bg-zinc-700"
        >
          "Estou saindo"
        </button>
      </div>
    </div>
  );
}

function CommunicateCallingView({
  callingContact,
  setActiveTab,
}: any) {
  const [muted, setMuted] = useState(false);
  const [video, setVideo] = useState(false);

  useEffect(() => {
    // Play calling sound/haptics logic could go here
  }, []);

  return (
    <div className="px-4 flex flex-col items-center justify-center min-h-[60vh] space-y-12">
      <div className="text-center space-y-2">
        <h2 className="text-2xl font-bold text-white">
          Chamando...
        </h2>
        <p className="text-zinc-400 text-lg">
          {callingContact}
        </p>
      </div>

      <div className="relative flex items-center justify-center w-40 h-40">
        {[1, 2, 3].map((i) => (
          <motion.div
            key={i}
            className="absolute inset-0 rounded-full bg-cyan-500/20"
            animate={{
              scale: [1, 1.8, 1],
              opacity: [0.8, 0, 0.8],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              delay: i * 0.6,
            }}
          />
        ))}
        <div className="w-24 h-24 rounded-full bg-zinc-800 flex items-center justify-center z-10 text-4xl font-bold text-zinc-400 border border-zinc-700">
          {callingContact.charAt(0)}
        </div>
      </div>

      <div className="flex gap-6 mt-12">
        <button
          onClick={() => setMuted(!muted)}
          className={`w-16 h-16 rounded-full flex items-center justify-center active:scale-95 transition-all ${muted ? "bg-white text-black" : "bg-zinc-800 text-white hover:bg-zinc-700"}`}
        >
          {muted ? (
            <MicOff className="w-7 h-7" />
          ) : (
            <Mic className="w-7 h-7" />
          )}
        </button>
        <button
          onClick={() => setActiveTab("communicate")}
          className="w-16 h-16 rounded-full bg-red-500 flex items-center justify-center hover:bg-red-600 active:scale-95 transition-all text-white shadow-[0_0_20px_rgba(239,68,68,0.4)]"
        >
          <Phone className="w-7 h-7 rotate-[135deg]" />
        </button>
        <button
          onClick={() => setVideo(!video)}
          className={`w-16 h-16 rounded-full flex items-center justify-center active:scale-95 transition-all ${video ? "bg-white text-black" : "bg-zinc-800 text-white hover:bg-zinc-700"}`}
        >
          {video ? (
            <VideoOff className="w-7 h-7" />
          ) : (
            <Video className="w-7 h-7" />
          )}
        </button>
      </div>
    </div>
  );
}

function MediaView({
  currentMedia,
  togglePlay,
  playNewMedia,
}: any) {
  return (
    <div className="px-4 py-6 space-y-6">
      <div className="bg-zinc-900/60 rounded-3xl p-6 border border-zinc-800/50 backdrop-blur-sm flex flex-col items-center">
        <div
          className={`w-48 h-48 rounded-2xl overflow-hidden shadow-2xl mb-6 transition-transform duration-700 ${currentMedia.isPlaying ? "scale-105" : ""}`}
        >
          <img
            src={currentMedia.img}
            alt="Current"
            className="w-full h-full object-cover"
          />
        </div>
        <h2 className="text-xl font-bold text-white text-center w-full truncate">
          {currentMedia.title}
        </h2>
        <p className="text-zinc-400 text-sm mb-6">
          {currentMedia.artist}
        </p>

        <div className="w-full h-1 bg-zinc-800 rounded-full mb-6 relative">
          <div className="absolute left-0 top-0 h-full bg-cyan-500 rounded-full w-1/3"></div>
        </div>

        <div className="flex items-center gap-8">
          <button className="text-zinc-400 hover:text-white transition-colors">
            <Radio className="w-6 h-6" />
          </button>
          <button
            onClick={togglePlay}
            className="w-16 h-16 rounded-full bg-white text-black flex items-center justify-center hover:scale-105 transition-transform active:scale-95"
          >
            {currentMedia.isPlaying ? (
              <div className="w-5 h-5 flex justify-between">
                <div className="w-1.5 bg-black rounded-sm" />
                <div className="w-1.5 bg-black rounded-sm" />
              </div>
            ) : (
              <PlayCircle className="w-10 h-10" />
            )}
          </button>
          <button className="text-zinc-400 hover:text-white transition-colors">
            <List className="w-6 h-6" />
          </button>
        </div>
      </div>

      <div>
        <h2 className="text-lg font-semibold text-white mb-4 px-2">
          Tocados Recentemente
        </h2>
        <div className="flex gap-4 overflow-x-auto no-scrollbar pb-4 -mx-4 px-6">
          <MediaCard
            img="https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=150&h=150&fit=crop"
            title="Eletrônica Mix"
            subtitle="Playlist"
            onClick={() =>
              playNewMedia({
                title: "Eletrônica Mix",
                subtitle: "Playlist",
                img: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=150&h=150&fit=crop",
              })
            }
          />
          <MediaCard
            img="https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=150&h=150&fit=crop"
            title="Daily Podcast"
            subtitle="Ep. 42"
            onClick={() =>
              playNewMedia({
                title: "Daily Podcast",
                subtitle: "Ep. 42",
                img: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=150&h=150&fit=crop",
              })
            }
          />
          <MediaCard
            img="https://images.unsplash.com/photo-1493225457124-a1a2a5f5f924?w=150&h=150&fit=crop"
            title="Jazz Focus"
            subtitle="Álbum"
            onClick={() =>
              playNewMedia({
                title: "Jazz Focus",
                subtitle: "Álbum",
                img: "https://images.unsplash.com/photo-1493225457124-a1a2a5f5f924?w=150&h=150&fit=crop",
              })
            }
          />
        </div>
      </div>
    </div>
  );
}

function DevicesView({
  devices,
  toggleDevice,
  setActiveTab,
  setSelectedDeviceId,
}: any) {
  const [filter, setFilter] = useState("Todos");

  const filteredDevices =
    filter === "Todos"
      ? devices
      : devices.filter((d: any) => d.room === filter);

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2 -mx-4 px-4">
        <button
          onClick={() => setFilter("Todos")}
          className={`whitespace-nowrap rounded-full px-5 py-2.5 text-sm font-medium transition-transform active:scale-95 cursor-pointer ${filter === "Todos" ? "bg-cyan-900/30 border-cyan-800 border text-cyan-400" : "bg-zinc-900 border-zinc-800 border text-zinc-300"}`}
        >
          Todos os Dispositivos
        </button>
        <button
          onClick={() => setFilter("Sala de Estar")}
          className={`whitespace-nowrap rounded-full px-5 py-2.5 text-sm font-medium transition-transform active:scale-95 cursor-pointer ${filter === "Sala de Estar" ? "bg-cyan-900/30 border-cyan-800 border text-cyan-400" : "bg-zinc-900 border-zinc-800 border text-cyan-400"}`}
        >
          Sala
        </button>
        <button
          onClick={() => setFilter("Quarto")}
          className={`whitespace-nowrap rounded-full px-5 py-2.5 text-sm font-medium transition-transform active:scale-95 cursor-pointer ${filter === "Quarto" ? "bg-cyan-900/30 border-cyan-800 border text-cyan-400" : "bg-zinc-900 border-zinc-800 border text-zinc-300"}`}
        >
          Quarto
        </button>
      </div>

      <div className="grid grid-cols-2 gap-4">
        {filteredDevices.map((d: any) => {
          const getSettingsRoute = () => {
            if (d.id === "1" || d.id === "2")
              return "device_config_light_" + d.id;
            if (d.id === "3") return "device_config_tv";
            if (d.id === "4") return "device_config_echo";
            if (d.id === "5") return "device_config_ac";
            return "";
          };

          return (
            <DeviceCard
              key={d.id}
              icon={
                d.type === "light" ? (
                  <Lightbulb />
                ) : d.type === "tv" ? (
                  <Tv />
                ) : d.type === "speaker" ? (
                  <Speaker />
                ) : (
                  <Thermometer />
                )
              }
              name={d.name}
              room={d.room}
              status={d.status}
              active={d.active}
              onClick={() => {
                if (d.id === "1") {
                  setSelectedDeviceId("1");
                  setActiveTab("device_light");
                } else if (d.id === "5") {
                  setSelectedDeviceId("5");
                  setActiveTab("device_ac");
                } else toggleDevice(d.id);
              }}
              onToggle={() => toggleDevice(d.id)}
              onSettings={() =>
                setActiveTab(getSettingsRoute())
              }
            />
          );
        })}
      </div>
    </div>
  );
}

function MoreView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  return (
    <div className="px-4 py-6">
      <div className="space-y-2">
        <ListItem
          icon={<List />}
          title="Listas e Notas"
          onClick={() => setActiveTab("more_listas")}
        />
        <ListItem
          icon={<Clock />}
          title="Alarmes e Timers"
          onClick={() => setActiveTab("more_alarmes")}
        />
        <ListItem
          icon={<CalendarIcon />}
          title="Calendário"
          onClick={() => setActiveTab("more_calendario")}
        />
        <ListItem
          icon={<Puzzle />}
          title="Skills e Jogos"
          onClick={() => setActiveTab("more_skills")}
        />
        <ListItem
          icon={<Settings />}
          title="Configurações"
          onClick={() => setActiveTab("more_config")}
        />
        <ListItem
          icon={<Bell />}
          title="Atividades"
          onClick={() => setActiveTab("more_atividades")}
        />
      </div>
    </div>
  );
}

function ProfileView({
  setActiveTab,
  onLogout,
}: {
  setActiveTab: (tab: string) => void;
  onLogout: () => void;
}) {
  const handleItem = (title: string) => {
    if (title === "Sair") {
      toast.info("Sessão encerrada.");
      onLogout();
    }
  };

  return (
    <div className="px-4 py-8">
      <div className="flex flex-col items-center justify-center mb-8">
        <div
          className="w-28 h-28 rounded-full bg-gradient-to-tr from-cyan-500 to-blue-600 p-1 shadow-xl shadow-cyan-900/20 mb-4 cursor-pointer hover:scale-105 transition-transform"
          onClick={() =>
            toast.success("Foto de perfil atualizada!")
          }
        >
          <div className="w-full h-full rounded-full bg-zinc-900 border-4 border-zinc-950 overflow-hidden">
            <img
              src="/src/imports/Captura_de_tela_2025-05-08_111333.png"
              alt="Leonardo"
              className="w-full h-full object-cover"
            />
          </div>
        </div>
        <h2 className="text-2xl font-bold text-white">
          Leonardo Carvalho
        </h2>
        <p className="text-zinc-400 mt-1">
          Membro Aura desde 2024
        </p>
      </div>

      <div className="bg-zinc-900/60 rounded-3xl border border-zinc-800/50 overflow-hidden">
        <ProfileItem
          icon={<User />}
          title="Meus Dados"
          onClick={() => setActiveTab("profile_dados")}
        />
        <ProfileItem
          icon={<Mic2 />}
          title="Voz e Respostas da Aura"
          onClick={() => setActiveTab("profile_voz")}
        />
        <ProfileItem
          icon={<Shield />}
          title="Privacidade da Conta"
          onClick={() => setActiveTab("profile_privacidade")}
        />
        <ProfileItem
          icon={<LogOut />}
          title="Sair"
          color="text-red-400"
          noBorder
          onClick={() => handleItem("Sair")}
        />
      </div>
    </div>
  );
}

// ==========================================
// SUB VIEWS COMPONENTS (DEVICES)
// ==========================================

function DeviceLightView({
  device,
  toggleDevice,
  setDevices,
  setActiveTab,
}: any) {
  const [intensity, setIntensity] = useState(
    device?.value || 80,
  );

  const handleIntensityChange = (val: number) => {
    setIntensity(val);
    setDevices((prev: any) =>
      prev.map((d: any) =>
        d.id === device.id
          ? { ...d, value: val, status: `Ligado • ${val}%` }
          : d,
      ),
    );
  };

  if (!device) return null;

  return (
    <div className="px-4 py-8 space-y-10 flex flex-col h-[75vh] relative">
      <button
        onClick={() =>
          setActiveTab("device_config_light_" + device.id)
        }
        className="absolute top-0 right-4 w-10 h-10 rounded-full bg-zinc-800/80 border border-zinc-700/50 flex items-center justify-center text-zinc-400 hover:text-cyan-400 hover:bg-zinc-700/80 transition-all active:scale-95"
      >
        <Settings className="w-5 h-5" />
      </button>

      <div className="flex flex-col items-center justify-center text-center space-y-2">
        <div
          className={`w-32 h-32 rounded-full flex items-center justify-center mb-4 transition-all duration-500 shadow-2xl ${device.active ? "bg-yellow-500/20 text-yellow-400 shadow-yellow-500/20" : "bg-zinc-800/50 text-zinc-500 shadow-transparent"}`}
        >
          <Lightbulb className="w-16 h-16" />
        </div>
        <h2 className="text-3xl font-bold text-white">
          {device.name}
        </h2>
        <p className="text-zinc-400 text-lg">{device.room}</p>
      </div>

      <div className="bg-zinc-900/80 p-6 rounded-[2rem] border border-zinc-800/80 shadow-xl space-y-8 mt-auto">
        <div className="flex justify-between items-center">
          <span className="text-white text-lg font-medium">
            Energia
          </span>
          <div
            onClick={() => toggleDevice(device.id)}
            className={`w-16 h-9 rounded-full cursor-pointer relative transition-colors ${device.active ? "bg-cyan-500 shadow-lg shadow-cyan-500/30" : "bg-zinc-700"}`}
          >
            <div
              className={`absolute top-1 w-7 h-7 bg-white rounded-full transition-all ${device.active ? "right-1" : "left-1 bg-zinc-400"}`}
            ></div>
          </div>
        </div>

        <div
          className={`space-y-6 transition-all duration-300 ${!device.active ? "opacity-30 pointer-events-none" : "opacity-100"}`}
        >
          <div className="flex justify-between items-center">
            <span className="text-zinc-400 font-medium">
              Intensidade
            </span>
            <span className="text-cyan-400 text-lg font-bold">
              {intensity}%
            </span>
          </div>

          <div className="flex items-center gap-4">
            <Lightbulb className="w-6 h-6 text-zinc-500" />
            <input
              type="range"
              min="10"
              max="100"
              value={intensity}
              onChange={(e) =>
                handleIntensityChange(parseInt(e.target.value))
              }
              className="w-full h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-yellow-500"
            />
            <Lightbulb className="w-8 h-8 text-yellow-500" />
          </div>
        </div>
      </div>
    </div>
  );
}

function DeviceAcView({
  device,
  toggleDevice,
  setDevices,
  setActiveTab,
}: any) {
  const [temp, setTemp] = useState(device?.value || 23);

  const adjustTemp = (amount: number) => {
    const newTemp = Math.min(30, Math.max(16, temp + amount));
    setTemp(newTemp);
    setDevices((prev: any) =>
      prev.map((d: any) =>
        d.id === device.id
          ? { ...d, value: newTemp, status: `${newTemp}°C` }
          : d,
      ),
    );
  };

  if (!device) return null;

  return (
    <div className="px-4 py-8 space-y-10 flex flex-col h-[75vh] relative">
      <button
        onClick={() => setActiveTab("device_config_ac")}
        className="absolute top-0 right-4 w-10 h-10 rounded-full bg-zinc-800/80 border border-zinc-700/50 flex items-center justify-center text-zinc-400 hover:text-cyan-400 hover:bg-zinc-700/80 transition-all active:scale-95"
      >
        <Settings className="w-5 h-5" />
      </button>

      <div className="flex flex-col items-center justify-center text-center space-y-2">
        <div
          className={`w-32 h-32 rounded-full flex items-center justify-center mb-4 transition-all duration-500 shadow-2xl ${device.active ? "bg-blue-500/20 text-blue-400 shadow-blue-500/20" : "bg-zinc-800/50 text-zinc-500 shadow-transparent"}`}
        >
          <Thermometer className="w-16 h-16" />
        </div>
        <h2 className="text-3xl font-bold text-white">
          {device.name}
        </h2>
        <p className="text-zinc-400 text-lg">{device.room}</p>
      </div>

      <div className="bg-zinc-900/80 p-6 rounded-[2rem] border border-zinc-800/80 shadow-xl space-y-8 mt-auto flex flex-col justify-center">
        <div className="flex justify-between items-center mb-4">
          <span className="text-white text-lg font-medium">
            Energia
          </span>
          <div
            onClick={() => toggleDevice(device.id)}
            className={`w-16 h-9 rounded-full cursor-pointer relative transition-colors ${device.active ? "bg-cyan-500 shadow-lg shadow-cyan-500/30" : "bg-zinc-700"}`}
          >
            <div
              className={`absolute top-1 w-7 h-7 bg-white rounded-full transition-all ${device.active ? "right-1" : "left-1 bg-zinc-400"}`}
            ></div>
          </div>
        </div>

        <div
          className={`flex flex-col items-center justify-center space-y-8 transition-all duration-300 ${!device.active ? "opacity-30 pointer-events-none" : "opacity-100"}`}
        >
          <span className="text-zinc-400 font-medium">
            Temperatura
          </span>

          <div className="flex items-center gap-8">
            <button
              onClick={() => adjustTemp(-1)}
              className="w-16 h-16 rounded-full bg-zinc-800 text-blue-400 flex items-center justify-center active:scale-90 transition-transform shadow-lg border border-zinc-700 hover:bg-zinc-700"
            >
              <Minus className="w-8 h-8" />
            </button>

            <div className="text-6xl font-bold text-white tabular-nums tracking-tighter">
              {temp}°
            </div>

            <button
              onClick={() => adjustTemp(1)}
              className="w-16 h-16 rounded-full bg-zinc-800 text-red-400 flex items-center justify-center active:scale-90 transition-transform shadow-lg border border-zinc-700 hover:bg-zinc-700"
            >
              <Plus className="w-8 h-8" />
            </button>
          </div>
          <div className="flex gap-4 w-full pt-4">
            <button className="flex-1 py-3 bg-blue-500/20 text-blue-400 border border-blue-500/30 rounded-2xl font-medium">
              Resfriar
            </button>
            <button className="flex-1 py-3 bg-zinc-800 text-zinc-400 rounded-2xl font-medium">
              Ventilar
            </button>
            <button className="flex-1 py-3 bg-zinc-800 text-zinc-400 rounded-2xl font-medium">
              Auto
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ==========================================
// SUB VIEWS COMPONENTS (PERFIL)
// ==========================================

function ProfileDadosView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  return (
    <div className="px-4 py-6 space-y-4">
      <div className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50">
        <p className="text-zinc-500 text-sm mb-1">
          Nome Completo
        </p>
        <p className="text-white font-medium text-lg">
          Leonardo Carvalho
        </p>
      </div>
      <div className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50">
        <p className="text-zinc-500 text-sm mb-1">
          E-mail associado
        </p>
        <p className="text-white font-medium text-lg">
          leonardo.carvalho@exemplo.com
        </p>
      </div>
      <div className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50">
        <p className="text-zinc-500 text-sm mb-1">Telefone</p>
        <p className="text-white font-medium text-lg">
          +55 11 99999-9999
        </p>
      </div>
      <button
        onClick={() => setActiveTab("profile_dados_editar")}
        className="w-full py-4 rounded-full bg-zinc-800 text-white font-medium hover:bg-zinc-700 transition-colors active:scale-[0.98]"
      >
        Editar Dados
      </button>
    </div>
  );
}

function ProfileDadosEditarView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const handleSave = () => {
    toast.success("Dados atualizados com sucesso!");
    setActiveTab("profile_dados");
  };

  return (
    <div className="px-4 py-6 space-y-5">
      <div className="space-y-1">
        <label className="text-sm font-medium text-zinc-400 px-2">
          Nome Completo
        </label>
        <input
          type="text"
          defaultValue="Leonardo Carvalho"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500"
        />
      </div>
      <div className="space-y-1">
        <label className="text-sm font-medium text-zinc-400 px-2">
          E-mail
        </label>
        <input
          type="email"
          defaultValue="leonardo.carvalho@exemplo.com"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500"
        />
      </div>
      <div className="space-y-1">
        <label className="text-sm font-medium text-zinc-400 px-2">
          Telefone
        </label>
        <input
          type="tel"
          defaultValue="+55 11 99999-9999"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500"
        />
      </div>
      <button
        onClick={handleSave}
        className="w-full py-4 rounded-full bg-cyan-500 text-black font-bold hover:bg-cyan-400 transition-colors active:scale-[0.98] mt-4 shadow-lg shadow-cyan-500/20"
      >
        Salvar Alterações
      </button>
    </div>
  );
}

function ProfileVozView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  return (
    <div className="px-4 py-6 space-y-3">
      <div
        onClick={() => setActiveTab("profile_voz_idioma")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            Idioma da Aura
          </p>
          <p className="text-cyan-400 text-sm mt-0.5">
            Português (Brasil)
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("profile_voz_velocidade")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            Velocidade da Voz
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">Normal</p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("profile_voz_palavra")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            Palavra de Ativação
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">"Aura"</p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
    </div>
  );
}

function ProfileVozIdiomaView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const [selected, setSelected] = useState(
    "Português (Brasil)",
  );

  const languages = [
    "Português (Brasil)",
    "Português (Portugal)",
    "English (US)",
    "English (UK)",
    "English (Australia)",
    "Español (España)",
    "Español (México)",
    "Español (Latinoamérica)",
    "Français (France)",
    "Français (Canada)",
    "Deutsch (France)",
    "Italiano",
    "日本語 (Japan)",
    "한국어 (Japan)",
    "中文 (Korean)",
  ];

  return (
    <div className="px-4 py-6 space-y-2 pb-10">
      <p className="text-zinc-400 px-2 mb-4">
        Selecione o idioma de resposta da Aura
      </p>
      {languages.map((lang) => (
        <div
          key={lang}
          onClick={() => {
            setSelected(lang);
            toast.success(`Idioma alterado para ${lang}`);
            setActiveTab("profile_voz");
          }}
          className={`p-4 rounded-2xl border flex justify-between items-center cursor-pointer active:scale-[0.98] transition-all ${selected === lang ? "bg-cyan-900/20 border-cyan-500/50" : "bg-zinc-900/60 border-zinc-800/50 hover:bg-zinc-800/50"}`}
        >
          <span
            className={
              selected === lang
                ? "text-cyan-400 font-medium"
                : "text-zinc-200"
            }
          >
            {lang}
          </span>
          <div
            className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${selected === lang ? "border-cyan-500" : "border-zinc-600"}`}
          >
            {selected === lang && (
              <div className="w-2.5 h-2.5 bg-cyan-500 rounded-full"></div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

function ProfileVozVelocidadeView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const [speed, setSpeed] = useState(2); // 0, 1, 2(normal), 3, 4
  const speeds = [
    "Muito Lenta",
    "Lenta",
    "Normal",
    "Rápida",
    "Muito Rápida",
  ];

  return (
    <div className="px-4 py-12 flex flex-col h-full space-y-12">
      <p className="text-zinc-400 text-center">
        Ajuste a velocidade da voz da Aura
      </p>

      <div className="flex justify-center items-center gap-6">
        <button
          onClick={() => setSpeed(Math.max(0, speed - 1))}
          className="w-12 h-12 rounded-full bg-zinc-800 flex items-center justify-center text-white active:scale-95 border border-zinc-700"
        >
          -
        </button>
        <div className="text-center w-32">
          <p className="text-3xl font-bold text-white mb-1">
            {speeds[speed]}
          </p>
        </div>
        <button
          onClick={() => setSpeed(Math.min(4, speed + 1))}
          className="w-12 h-12 rounded-full bg-zinc-800 flex items-center justify-center text-white active:scale-95 border border-zinc-700"
        >
          +
        </button>
      </div>

      <div className="flex gap-2 justify-center">
        {[0, 1, 2, 3, 4].map((s) => (
          <div
            key={s}
            className={`h-2 rounded-full transition-all ${s === speed ? "w-8 bg-cyan-500" : "w-2 bg-zinc-700"}`}
          ></div>
        ))}
      </div>

      <button
        onClick={() => {
          toast.success("Velocidade atualizada!");
          setActiveTab("profile_voz");
        }}
        className="w-full py-4 mt-auto rounded-full bg-cyan-500 text-black font-bold active:scale-[0.98] shadow-lg shadow-cyan-500/20"
      >
        Aplicar
      </button>
    </div>
  );
}

function ProfileVozPalavraView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const [word, setWord] = useState("");

  return (
    <div className="px-4 py-8 space-y-6">
      <p className="text-zinc-400">
        Escolha como a assistente deve ser ativada.
      </p>

      <div className="space-y-2">
        <label className="text-sm font-medium text-white px-2">
          Palavra de Ativação Atual
        </label>
        <input
          type="text"
          value={word}
          onChange={(e) => setWord(e.target.value)}
          placeholder="Ex: Aura"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500 text-xl font-medium placeholder-zinc-700"
        />
        <p className="text-zinc-500 text-xs px-2 pt-1">
          Ao definir uma palavra, os dispositivos ficarão
          ouvindo até detectá-la para iniciar o processamento.
        </p>
      </div>

      <div className="pt-6">
        <button
          onClick={() => {
            toast.success("Palavra de ativação salva!");
            setActiveTab("profile_voz");
          }}
          className="w-full py-4 rounded-full bg-cyan-500 text-black font-bold active:scale-[0.98] shadow-lg shadow-cyan-500/20"
        >
          Salvar
        </button>
      </div>
    </div>
  );
}

function ProfilePrivacidadeView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  return (
    <div className="px-4 py-6 space-y-3">
      <div
        onClick={() =>
          setActiveTab("profile_privacidade_historico")
        }
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            Histórico de Voz
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">
            Gerenciar e excluir gravações
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() =>
          setActiveTab("profile_privacidade_skills")
        }
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            Permissões de Skills
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">
            Revise quais dados são acessados
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
    </div>
  );
}

function ProfilePrivacidadeHistoricoView() {
  const [history, setHistory] = useState([
    {
      id: 1,
      time: "Hoje, 09:41",
      text: '"Aura, ligar luz principal"',
    },
    {
      id: 2,
      time: "Ontem, 20:15",
      text: '"Aura, tocar Jazz Focus"',
    },
  ]);

  const handleDelete = (id: number) => {
    setHistory(history.filter((h) => h.id !== id));
    toast.success("Comando removido");
  };

  const handleClearAll = () => {
    setHistory([]);
    toast.success("Todo o histórico foi limpo.");
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <p className="text-zinc-400">
        Verifique as gravações mais recentes do que foi dito à
        Aura.
      </p>

      <div className="space-y-3">
        {history.length > 0 ? (
          history.map((item) => (
            <div
              key={item.id}
              className="bg-zinc-900/60 p-4 rounded-2xl border border-zinc-800/50"
            >
              <div className="flex justify-between mb-2">
                <span className="text-zinc-500 text-xs">
                  {item.time}
                </span>
                <Trash
                  className="w-4 h-4 text-zinc-500 hover:text-red-400 cursor-pointer transition-colors"
                  onClick={() => handleDelete(item.id)}
                />
              </div>
              <p className="text-white">{item.text}</p>
            </div>
          ))
        ) : (
          <p className="text-zinc-500 text-center py-4">
            Nenhum histórico encontrado.
          </p>
        )}
      </div>

      <button
        onClick={handleClearAll}
        disabled={history.length === 0}
        className={`w-full py-4 border font-medium rounded-full active:scale-95 transition-colors ${history.length === 0 ? "border-zinc-800 text-zinc-600 cursor-not-allowed" : "border-red-500/30 text-red-400 hover:bg-red-500/10"}`}
      >
        Excluir todo o histórico (3 meses)
      </button>
    </div>
  );
}

function ProfilePrivacidadeSkillsView({
  setActiveTab,
  setActiveSkill,
}: any) {
  const [skills, setSkills] = useState([
    {
      id: "spotify",
      name: "Spotify",
      connected: true,
      permission: true,
      icon: <Music className="w-6 h-6" />,
      color: "text-green-400",
      bg: "bg-green-500/20",
    },
    {
      id: "tunein",
      name: "TuneIn Radio",
      connected: true,
      permission: false,
      icon: <Radio className="w-6 h-6" />,
      color: "text-orange-400",
      bg: "bg-orange-500/20",
    },
  ]);

  const handleLoginClick = (skillId: string) => {
    setActiveSkill(skillId);
    setActiveTab("skill_login");
  };

  const togglePermission = (
    id: string,
    e: React.MouseEvent,
  ) => {
    e.stopPropagation();
    setSkills(
      skills.map((s) =>
        s.id === id ? { ...s, permission: !s.permission } : s,
      ),
    );
  };

  return (
    <div className="px-4 py-6 space-y-4">
      <p className="text-zinc-400">
        Gerencie as permissões concedidas às skills instaladas.
        Toque para conectar ou desconectar.
      </p>

      {skills.map((skill) => (
        <div
          key={skill.id}
          onClick={() => handleLoginClick(skill.id)}
          className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex flex-col gap-4 cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
        >
          <div className="flex items-center gap-4">
            <div
              className={`w-12 h-12 rounded-xl flex items-center justify-center ${skill.bg} ${skill.color}`}
            >
              {skill.icon}
            </div>
            <div className="flex-1">
              <p className="text-white font-medium">
                {skill.name}
              </p>
              <p className="text-zinc-500 text-xs">
                {skill.connected ? "Conectado" : "Desconectado"}
              </p>
            </div>
          </div>
          <div
            className="border-t border-zinc-800/50 pt-4 flex justify-between items-center"
            onClick={(e) => togglePermission(skill.id, e)}
          >
            <span className="text-sm text-zinc-400">
              Acesso aos dados
            </span>
            <div
              className={`w-12 h-6 rounded-full relative transition-colors ${skill.permission ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${skill.permission ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function SkillLoginView({ skill, setActiveTab }: any) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleLogin = () => {
    if (!email || !password)
      return toast.error("Preencha os campos");
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      toast.success(`Conta ${skill} conectada com sucesso!`);
      setActiveTab("profile_privacidade_skills");
    }, 1500);
  };

  const skillName = skill === "spotify" ? "Spotify" : "TuneIn";
  const skillColor =
    skill === "spotify" ? "text-green-400" : "text-orange-400";

  return (
    <div className="px-4 py-8 flex flex-col justify-center min-h-[60vh] space-y-8">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-white mb-2">
          Conectar{" "}
          <span className={skillColor}>{skillName}</span>
        </h2>
        <p className="text-zinc-400">
          Insira suas credenciais para vincular à Aura
        </p>
      </div>

      <div className="space-y-4">
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="E-mail ou Usuário"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500"
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Senha"
          className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500"
        />
      </div>

      <button
        onClick={handleLogin}
        disabled={loading}
        className="w-full bg-white text-black font-bold text-lg py-4 rounded-full mt-4 active:scale-95 transition-all"
      >
        {loading ? "Conectando..." : "Autorizar Acesso"}
      </button>
    </div>
  );
}

// ==========================================
// SUB VIEWS COMPONENTS (MAIS)
// ==========================================

function MoreListasView({
  lists,
  setLists,
  notes,
  setNotes,
  setActiveTab,
  setSelectedNoteId,
  activeListTab,
  setActiveListTab,
  setSelectedListId,
}: any) {
  const tab = activeListTab || "listas";
  const setTab = setActiveListTab || (() => {});
  const [newItem, setNewItem] = useState("");

  const handleAddItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newItem.trim()) return;
    if (tab === "listas") {
      setLists([
        ...lists,
        {
          id: Date.now().toString(),
          title: newItem,
          items: [],
        },
      ]);
    } else {
      setNotes([
        ...notes,
        {
          id: Date.now().toString(),
          title: newItem,
          preview: "",
        },
      ]);
    }
    setNewItem("");
  };

  const deleteList = (id: string) => {
    setLists(lists.filter((l: any) => l.id !== id));
  };

  return (
    <div className="px-4 py-6 flex flex-col h-full space-y-4">
      <div className="flex bg-zinc-900 rounded-full p-1 border border-zinc-800">
        <button
          onClick={() => setTab("listas")}
          className={`flex-1 py-2 text-sm font-medium rounded-full transition-colors ${tab === "listas" ? "bg-cyan-500 text-black" : "text-zinc-400"}`}
        >
          Listas
        </button>
        <button
          onClick={() => setTab("notas")}
          className={`flex-1 py-2 text-sm font-medium rounded-full transition-colors ${tab === "notas" ? "bg-cyan-500 text-black" : "text-zinc-400"}`}
        >
          Notas
        </button>
      </div>

      <form
        onSubmit={handleAddItem}
        className="relative flex items-center"
      >
        <input
          type="text"
          value={newItem}
          onChange={(e) => setNewItem(e.target.value)}
          placeholder={
            tab === "listas" ? "Nova lista..." : "Nova nota..."
          }
          className="w-full bg-zinc-900 border border-zinc-800 rounded-full py-3 px-5 text-white pr-12 focus:outline-none focus:border-cyan-500/50"
        />
        <button
          type="submit"
          className="absolute right-3 text-cyan-400 p-1"
        >
          <Plus className="w-6 h-6" />
        </button>
      </form>

      <div className="flex-1 overflow-y-auto no-scrollbar space-y-2 pb-6">
        {tab === "listas" ? (
          <AnimatePresence>
            {lists.map((list: any) => (
              <div
                key={list.id}
                className="relative rounded-2xl overflow-hidden bg-red-500 flex items-center mb-2"
              >
                <div className="absolute right-4">
                  <Trash className="w-5 h-5 text-white" />
                </div>
                <motion.div
                  drag="x"
                  dragConstraints={{ left: 0, right: 0 }}
                  dragElastic={{ left: 0.5, right: 0 }}
                  onDragEnd={(e, info) => {
                    if (info.offset.x < -80)
                      deleteList(list.id);
                  }}
                  className="w-full bg-zinc-900 p-4 border border-zinc-800 flex items-center justify-between relative z-10 cursor-grab active:cursor-grabbing rounded-2xl"
                >
                  <div
                    className="flex items-center gap-4"
                    onClick={() => {
                      setSelectedListId(list.id);
                      setActiveTab("more_lista_items");
                    }}
                  >
                    <div className="w-10 h-10 rounded-full bg-cyan-900/30 flex items-center justify-center text-cyan-400">
                      <List className="w-5 h-5" />
                    </div>
                    <div>
                      <p className="text-white font-medium">
                        {list.title}
                      </p>
                      <p className="text-zinc-400 text-xs">
                        {list.items.length}{" "}
                        {list.items.length === 1
                          ? "item"
                          : "itens"}
                      </p>
                    </div>
                  </div>
                  <ChevronRight
                    className="w-5 h-5 text-zinc-500"
                    onClick={() => {
                      setSelectedListId(list.id);
                      setActiveTab("more_lista_items");
                    }}
                  />
                </motion.div>
              </div>
            ))}
          </AnimatePresence>
        ) : (
          <div className="grid grid-cols-2 gap-3">
            {notes.map((note: any) => (
              <div
                key={note.id}
                onClick={() => {
                  setSelectedNoteId(note.id);
                  setActiveTab("more_notas_edit");
                }}
                className="bg-yellow-500/10 border border-yellow-500/20 p-4 rounded-2xl cursor-pointer active:scale-95 transition-transform aspect-square flex flex-col"
              >
                <h4 className="font-semibold text-yellow-500 mb-2 truncate">
                  {note.title}
                </h4>
                <p className="text-yellow-200/60 text-sm line-clamp-3 leading-relaxed">
                  {note.preview}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function MoreListaItemsView({
  listId,
  lists,
  setLists,
  setActiveTab,
}: any) {
  const list = lists.find((l: any) => l.id === listId);
  const [newItem, setNewItem] = useState("");
  const [isEditingTitle, setIsEditingTitle] = useState(false);
  const [editTitle, setEditTitle] = useState(list?.title || "");

  const handleAddItem = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newItem.trim()) return;
    setLists(
      lists.map((l: any) =>
        l.id === listId
          ? {
              ...l,
              items: [
                ...l.items,
                {
                  id: Date.now().toString(),
                  text: newItem,
                  checked: false,
                },
              ],
            }
          : l,
      ),
    );
    setNewItem("");
  };

  const saveTitle = () => {
    if (editTitle.trim()) {
      setLists(
        lists.map((l: any) =>
          l.id === listId ? { ...l, title: editTitle } : l,
        ),
      );
    }
    setIsEditingTitle(false);
  };

  const toggleItem = (itemId: string) => {
    setLists(
      lists.map((l: any) =>
        l.id === listId
          ? {
              ...l,
              items: l.items.map((i: any) =>
                i.id === itemId
                  ? { ...i, checked: !i.checked }
                  : i,
              ),
            }
          : l,
      ),
    );
  };

  const deleteItem = (itemId: string) => {
    setLists(
      lists.map((l: any) =>
        l.id === listId
          ? {
              ...l,
              items: l.items.filter(
                (i: any) => i.id !== itemId,
              ),
            }
          : l,
      ),
    );
  };

  if (!list) return null;

  return (
    <div className="px-4 py-6 flex flex-col h-full space-y-4">
      <div className="flex items-center gap-3 mb-2">
        <button
          onClick={() => setActiveTab("more_listas")}
          className="w-10 h-10 rounded-full bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-400 active:scale-95 transition-transform shrink-0"
        >
          <ChevronLeft className="w-6 h-6" />
        </button>
        {isEditingTitle ? (
          <input
            autoFocus
            type="text"
            value={editTitle}
            onChange={(e) => setEditTitle(e.target.value)}
            onBlur={saveTitle}
            onKeyDown={(e) => {
              if (e.key === "Enter") saveTitle();
            }}
            className="flex-1 bg-transparent text-xl font-bold text-white outline-none border-b border-cyan-500 pb-1"
          />
        ) : (
          <h2
            onClick={() => setIsEditingTitle(true)}
            className="text-xl font-bold text-white flex-1 cursor-pointer hover:text-cyan-400 transition-colors"
          >
            {list.title}
          </h2>
        )}
      </div>

      <form
        onSubmit={handleAddItem}
        className="relative flex items-center"
      >
        <input
          type="text"
          value={newItem}
          onChange={(e) => setNewItem(e.target.value)}
          placeholder="Adicionar à lista..."
          className="w-full bg-zinc-900 border border-zinc-800 rounded-full py-3 px-5 text-white pr-12 focus:outline-none focus:border-cyan-500/50"
        />
        <button
          type="submit"
          className="absolute right-3 text-cyan-400 p-1"
        >
          <Plus className="w-6 h-6" />
        </button>
      </form>

      <div className="flex-1 overflow-y-auto no-scrollbar space-y-2 pb-6">
        <AnimatePresence>
          {list.items.map((item: any) => (
            <div
              key={item.id}
              className="relative rounded-2xl overflow-hidden bg-red-500 flex items-center mb-2"
            >
              <div className="absolute right-4">
                <Trash className="w-5 h-5 text-white" />
              </div>
              <motion.div
                drag="x"
                dragConstraints={{ left: 0, right: 0 }}
                dragElastic={{ left: 0.5, right: 0 }}
                onDragEnd={(e, info) => {
                  if (info.offset.x < -80) deleteItem(item.id);
                }}
                className="w-full bg-zinc-900 p-4 border border-zinc-800 flex items-center gap-4 relative z-10 cursor-grab active:cursor-grabbing rounded-2xl"
              >
                <div
                  onClick={() => toggleItem(item.id)}
                  className={`w-5 h-5 rounded-full border-2 flex items-center justify-center cursor-pointer flex-shrink-0 transition-colors ${item.checked ? "border-cyan-500 bg-cyan-500" : "border-zinc-500"}`}
                >
                  {item.checked && (
                    <div className="w-2 h-2 bg-white rounded-full"></div>
                  )}
                </div>
                <p
                  className={`text-white transition-opacity ${item.checked ? "line-through opacity-50" : ""}`}
                >
                  {item.text}
                </p>
              </motion.div>
            </div>
          ))}
        </AnimatePresence>
      </div>
    </div>
  );
}

function MoreNotasEditView({
  noteId,
  notes,
  setNotes,
  setActiveTab,
}: any) {
  const note = notes.find((n: any) => n.id === noteId);
  const [title, setTitle] = useState(note?.title || "");
  const [content, setContent] = useState(note?.preview || "");

  const handleSave = () => {
    setNotes(
      notes.map((n: any) =>
        n.id === noteId ? { ...n, title, preview: content } : n,
      ),
    );
    toast.success("Nota salva!");
    setActiveTab("more_listas");
  };

  const handleDelete = () => {
    setNotes(notes.filter((n: any) => n.id !== noteId));
    toast.success("Nota excluída!");
    setActiveTab("more_listas");
  };

  return (
    <div className="px-4 py-6 flex flex-col h-full space-y-4">
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Título da nota"
        className="w-full bg-transparent text-white text-2xl font-bold outline-none placeholder-zinc-600"
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="Adicionar nova nota"
        className="w-full flex-1 bg-transparent text-yellow-100/80 resize-none outline-none placeholder-zinc-700 min-h-[300px]"
      />
      <div className="flex gap-4 mt-auto">
        <button
          onClick={handleDelete}
          className="w-14 h-14 rounded-full bg-red-500/10 border border-red-500/30 flex items-center justify-center text-red-400 active:scale-95"
        >
          <Trash className="w-6 h-6" />
        </button>
        <button
          onClick={handleSave}
          className="flex-1 py-4 rounded-full bg-yellow-500 text-yellow-950 font-bold active:scale-[0.98] shadow-lg shadow-yellow-500/20"
        >
          Salvar
        </button>
      </div>
    </div>
  );
}

function MoreAlarmesView({
  alarms,
  setAlarms,
  timers,
  setTimers,
  setActiveTab,
  setSelectedAlarmId,
  activeAlarmTab,
  setActiveAlarmTab,
}: any) {
  const handleDeleteAlarm = (id: string) => {
    setAlarms(alarms.filter((a: any) => a.id !== id));
    toast.success("Alarme excluído");
  };

  const handleToggleAlarm = (id: string) => {
    setAlarms(
      alarms.map((a: any) =>
        a.id === id ? { ...a, active: !a.active } : a,
      ),
    );
  };

  const handleDeleteTimer = (id: string) => {
    setTimers(timers.filter((t: any) => t.id !== id));
    toast.success("Timer excluído");
  };

  const handleToggleTimer = (id: string) => {
    setTimers(
      timers.map((t: any) =>
        t.id === id ? { ...t, active: !t.active } : t,
      ),
    );
  };

  return (
    <div className="px-4 py-6 flex flex-col h-full space-y-4">
      <div className="flex justify-center mb-4">
        <div className="bg-zinc-900 p-1 rounded-full flex gap-1">
          <button
            onClick={() => setActiveAlarmTab("alarmes")}
            className={`px-6 py-2 rounded-full text-sm font-medium transition-colors ${activeAlarmTab === "alarmes" ? "bg-cyan-500 text-black" : "text-zinc-400"}`}
          >
            Alarmes
          </button>
          <button
            onClick={() => setActiveAlarmTab("timers")}
            className={`px-6 py-2 rounded-full text-sm font-medium transition-colors ${activeAlarmTab === "timers" ? "bg-cyan-500 text-black" : "text-zinc-400"}`}
          >
            Timers
          </button>
        </div>
      </div>

      <div className="flex justify-between items-center mb-2 px-2">
        <h3 className="text-zinc-400 font-medium">
          Seus{" "}
          {activeAlarmTab === "alarmes" ? "Alarmes" : "Timers"}
        </h3>
        <button
          onClick={() => setActiveTab("more_alarmes_new")}
          className="w-10 h-10 rounded-full bg-zinc-800 flex items-center justify-center text-white active:scale-95"
        >
          <Plus className="w-5 h-5" />
        </button>
      </div>

      <div className="space-y-4 overflow-hidden px-2 pb-4">
        <AnimatePresence mode="popLayout">
          {activeAlarmTab === "alarmes" &&
            alarms.map((alarm: any) => (
              <motion.div
                key={`alarm-${alarm.id}`}
                layout
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0, scale: 0.8 }}
                className="relative mb-4 rounded-3xl overflow-hidden bg-red-500 flex items-center group"
              >
                <div className="absolute right-6">
                  <Trash className="w-6 h-6 text-white" />
                </div>

                <motion.div
                  drag="x"
                  dragConstraints={{ left: 0, right: 0 }}
                  dragElastic={{ left: 0.5, right: 0 }}
                  onDragEnd={(e, { offset }) => {
                    if (offset.x < -80)
                      handleDeleteAlarm(alarm.id);
                  }}
                  className="w-full p-6 rounded-3xl border border-zinc-800/50 flex justify-between items-center bg-zinc-900 relative z-10 transition-colors cursor-grab active:cursor-grabbing"
                >
                  <div
                    className="flex-1"
                    onClick={() => {
                      setSelectedAlarmId(alarm.id);
                      setActiveTab("more_alarmes_edit");
                    }}
                  >
                    <p className="text-4xl font-bold text-white flex items-baseline gap-2">
                      <Clock className="w-6 h-6 text-cyan-500" />
                      {alarm.time}
                    </p>
                    <p className="text-zinc-400 mt-1 text-sm">
                      {alarm.label}
                    </p>
                  </div>
                  <div
                    onClick={(e) => {
                      e.stopPropagation();
                      handleToggleAlarm(alarm.id);
                    }}
                    className={`w-12 h-7 rounded-full cursor-pointer relative transition-colors z-20 flex-shrink-0 ${alarm.active ? "bg-cyan-500" : "bg-zinc-700"}`}
                  >
                    <div
                      className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-all ${alarm.active ? "right-1" : "left-1 bg-zinc-400"}`}
                    ></div>
                  </div>
                </motion.div>
              </motion.div>
            ))}

          {activeAlarmTab === "timers" &&
            timers.map((timer: any) => (
              <motion.div
                key={`timer-${timer.id}`}
                layout
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: "auto" }}
                exit={{ opacity: 0, height: 0, scale: 0.8 }}
                className="relative mb-4 rounded-3xl overflow-hidden bg-red-500 flex items-center group"
              >
                <div className="absolute right-6">
                  <Trash className="w-6 h-6 text-white" />
                </div>

                <motion.div
                  drag="x"
                  dragConstraints={{ left: 0, right: 0 }}
                  dragElastic={{ left: 0.5, right: 0 }}
                  onDragEnd={(e, { offset }) => {
                    if (offset.x < -80)
                      handleDeleteTimer(timer.id);
                  }}
                  className="w-full p-6 rounded-3xl border border-zinc-800/50 flex justify-between items-center bg-zinc-900 relative z-10 transition-colors cursor-grab active:cursor-grabbing"
                >
                  <div className="flex-1">
                    <p className="text-4xl font-bold text-white flex items-baseline gap-2">
                      <Clock className="w-6 h-6 text-cyan-500" />
                      {timer.duration}
                    </p>
                    <p className="text-zinc-400 mt-1 text-sm">
                      {timer.label}
                    </p>
                  </div>
                  <div className="flex items-center gap-3 z-20">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleToggleTimer(timer.id);
                      }}
                      className={`w-10 h-10 rounded-full flex items-center justify-center cursor-pointer ${timer.active ? "bg-red-500/20 text-red-500" : "bg-cyan-500/20 text-cyan-400"}`}
                    >
                      {timer.active ? (
                        <X className="w-5 h-5" />
                      ) : (
                        <PlayCircle className="w-5 h-5" />
                      )}
                    </button>
                  </div>
                </motion.div>
              </motion.div>
            ))}
        </AnimatePresence>
      </div>
    </div>
  );
}

function MoreCalendarioView({
  reminders,
  setReminders,
  setActiveTab,
  setSelectedReminder,
}: any) {
  const today = new Date();
  const [currentDate, setCurrentDate] = useState(
    new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate(),
    ),
  );
  const [selectedDate, setSelectedDate] = useState<
    number | null
  >(today.getDate());
  const [newReminder, setNewReminder] = useState("");

  const holidays: Record<string, string> = {
    "0-1": "Confraternização Universal",
    "1-14": "Valentine's Day",
    "2-8": "Dia Internacional da Mulher",
    "3-19": "Dia do Índio",
    "3-21": "Tiradentes",
    "4-1": "Dia do Trabalhador",
    "4-12": "Dia das Mães",
    "5-12": "Dia dos Namorados",
    "6-26": "Dia dos Avós",
    "7-11": "Dia dos Pais",
    "7-22": "Dia do Folclore",
    "8-7": "Independência do Brasil",
    "9-12": "Nossa Sra. Aparecida / Dia das Crianças",
    "9-15": "Dia do Professor",
    "9-31": "Halloween / Dia das Bruxas",
    "10-2": "Finados",
    "10-15": "Proclamação da República",
    "10-20": "Consciência Negra",
    "11-25": "Natal",
    "11-31": "Véspera de Ano Novo",
  };

  const nextMonth = () =>
    setCurrentDate(
      new Date(
        currentDate.getFullYear(),
        currentDate.getMonth() + 1,
        1,
      ),
    );
  const prevMonth = () =>
    setCurrentDate(
      new Date(
        currentDate.getFullYear(),
        currentDate.getMonth() - 1,
        1,
      ),
    );

  const monthNames = [
    "Janeiro",
    "Fevereiro",
    "Março",
    "Abril",
    "Maio",
    "Junho",
    "Julho",
    "Agosto",
    "Setembro",
    "Outubro",
    "Novembro",
    "Dezembro",
  ];
  const weekDays = ["D", "S", "T", "Q", "Q", "S", "S"];

  const daysInMonth = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth() + 1,
    0,
  ).getDate();
  const firstDayIndex = new Date(
    currentDate.getFullYear(),
    currentDate.getMonth(),
    1,
  ).getDay();

  const handleAddReminder = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newReminder.trim() || !selectedDate) return;

    const dateKey = `${currentDate.getFullYear()}-${currentDate.getMonth()}-${selectedDate}`;
    const dayReminders = reminders[dateKey] || [];

    setReminders({
      ...reminders,
      [dateKey]: [
        ...dayReminders,
        { id: Date.now().toString(), text: newReminder },
      ],
    });
    setNewReminder("");
    toast.success("Lembrete adicionado!");
  };

  const selectedDateKey = selectedDate
    ? `${currentDate.getFullYear()}-${currentDate.getMonth()}-${selectedDate}`
    : "";
  const currentReminders = reminders[selectedDateKey] || [];
  const selectedHoliday = selectedDate
    ? holidays[`${currentDate.getMonth()}-${selectedDate}`]
    : null;

  return (
    <div className="px-4 py-6 flex flex-col h-full space-y-6">
      <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5">
        <div className="flex justify-between items-center mb-6">
          <button
            onClick={prevMonth}
            className="p-2 hover:bg-zinc-800 rounded-full text-zinc-400 active:scale-95"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <h3 className="text-white font-bold text-lg">
            {monthNames[currentDate.getMonth()]}{" "}
            {currentDate.getFullYear()}
          </h3>
          <button
            onClick={nextMonth}
            className="p-2 hover:bg-zinc-800 rounded-full text-zinc-400 active:scale-95"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>

        <div className="grid grid-cols-7 gap-1 text-center mb-2">
          {weekDays.map((d, i) => (
            <div
              key={i}
              className="text-zinc-500 text-xs font-medium"
            >
              {d}
            </div>
          ))}
        </div>

        <div className="grid grid-cols-7 gap-1 text-center">
          {Array.from({ length: firstDayIndex }).map((_, i) => (
            <div key={`empty-${i}`} className="h-10"></div>
          ))}
          {Array.from({ length: daysInMonth }).map((_, i) => {
            const day = i + 1;
            const dateKey = `${currentDate.getFullYear()}-${currentDate.getMonth()}-${day}`;
            const isHoliday =
              holidays[`${currentDate.getMonth()}-${day}`];
            const hasReminders =
              reminders[dateKey] &&
              reminders[dateKey].length > 0;
            const isSelected = selectedDate === day;
            const isToday =
              today.getDate() === day &&
              today.getMonth() === currentDate.getMonth() &&
              today.getFullYear() === currentDate.getFullYear();

            return (
              <div
                key={day}
                onClick={() => setSelectedDate(day)}
                className={`h-10 w-10 mx-auto rounded-full flex flex-col items-center justify-center cursor-pointer transition-all ${isSelected ? "bg-cyan-500 text-black font-bold" : isToday ? "border border-cyan-500 text-cyan-400 font-bold" : isHoliday ? "text-red-400 font-medium hover:bg-zinc-800" : "text-zinc-300 hover:bg-zinc-800"}`}
              >
                <span>{day}</span>
                {hasReminders && !isSelected && (
                  <div
                    className={`w-1 h-1 rounded-full mt-0.5 ${isHoliday ? "bg-red-400" : "bg-cyan-400"}`}
                  ></div>
                )}
              </div>
            );
          })}
        </div>

        {selectedHoliday && (
          <div className="mt-4 pt-3 border-t border-zinc-800 text-center">
            <span className="text-red-400 text-sm font-medium">
              ✨ {selectedHoliday}
            </span>
          </div>
        )}
      </div>

      {selectedDate && (
        <div className="flex-1 flex flex-col min-h-0 bg-zinc-900/60 rounded-3xl border border-zinc-800 p-5">
          <h4 className="text-white font-medium mb-4 flex items-center gap-2">
            <CalendarIcon className="w-4 h-4 text-cyan-400" />
            Lembretes ({selectedDate}/
            {currentDate.getMonth() + 1})
          </h4>

          <div className="flex-1 overflow-y-auto space-y-3 mb-4 no-scrollbar">
            {currentReminders.length === 0 ? (
              <p className="text-zinc-500 text-sm text-center py-4">
                Nenhum lembrete marcado.
              </p>
            ) : (
              currentReminders.map((rem: any) => (
                <div
                  key={rem.id}
                  onClick={() => {
                    setSelectedReminder({
                      ...rem,
                      dateKey: selectedDateKey,
                    });
                    setActiveTab("more_calendario_edit");
                  }}
                  className="bg-zinc-800/80 p-3 rounded-xl flex items-start gap-3 cursor-pointer active:scale-95 transition-transform"
                >
                  <div className="mt-1 text-cyan-400">
                    <Check className="w-4 h-4" />
                  </div>
                  <div className="flex-1">
                    <p className="text-zinc-200 text-sm">
                      {rem.text}
                    </p>
                    {rem.time && (
                      <p className="text-cyan-400 text-xs mt-1 font-medium">
                        {rem.time}
                      </p>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>

          <form
            onSubmit={handleAddReminder}
            className="relative mt-auto"
          >
            <input
              type="text"
              value={newReminder}
              onChange={(e) => setNewReminder(e.target.value)}
              placeholder="Adicionar lembrete..."
              className="w-full bg-zinc-800 border border-zinc-700 rounded-full py-3 px-5 text-white pr-12 focus:outline-none focus:border-cyan-500 transition-colors"
            />
            <button
              type="submit"
              className="absolute right-2 top-1/2 -translate-y-1/2 text-cyan-400 p-2"
            >
              <Plus className="w-5 h-5" />
            </button>
          </form>
        </div>
      )}
    </div>
  );
}

function MoreCalendarioEditView({
  reminder,
  reminders,
  setReminders,
  setActiveTab,
}: any) {
  const [text, setText] = useState(reminder?.text || "");
  const [dateStr, setDateStr] = useState("");
  const [timeStr, setTimeStr] = useState(
    reminder?.time || "12:00",
  );

  useEffect(() => {
    if (reminder?.dateKey) {
      const [y, m, d] = reminder.dateKey.split("-");
      setDateStr(
        `${y}-${String(Number(m) + 1).padStart(2, "0")}-${String(d).padStart(2, "0")}`,
      );
    }
  }, [reminder]);

  const handleSave = () => {
    if (!text.trim() || !dateStr) return;

    // Remove from old date
    const oldDateKey = reminder.dateKey;
    const filteredOld = (reminders[oldDateKey] || []).filter(
      (r: any) => r.id !== reminder.id,
    );

    // Add to new date
    const [y, mStr, dStr] = dateStr.split("-");
    const newDateKey = `${y}-${Number(mStr) - 1}-${Number(dStr)}`;

    const dayReminders =
      newDateKey === oldDateKey
        ? filteredOld
        : reminders[newDateKey] || [];

    setReminders({
      ...reminders,
      [oldDateKey]: filteredOld,
      [newDateKey]: [
        ...dayReminders,
        { id: reminder.id, text, time: timeStr },
      ],
    });

    toast.success("Lembrete atualizado!");
    setActiveTab("more_calendario");
  };

  const handleDelete = () => {
    const oldDateKey = reminder.dateKey;
    setReminders({
      ...reminders,
      [oldDateKey]: (reminders[oldDateKey] || []).filter(
        (r: any) => r.id !== reminder.id,
      ),
    });
    toast.success("Lembrete excluído!");
    setActiveTab("more_calendario");
  };

  if (!reminder) return null;

  return (
    <div className="px-4 py-8 space-y-6 flex flex-col h-[75vh]">
      <div className="space-y-4 flex-1">
        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 space-y-4">
          <p className="text-zinc-400 font-medium text-sm">
            Texto do Lembrete
          </p>
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            className="w-full bg-transparent text-white text-lg outline-none resize-none min-h-[100px]"
            placeholder="Digite o lembrete..."
          />
        </div>

        <div className="flex gap-4">
          <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 space-y-4 flex-1">
            <p className="text-zinc-400 font-medium text-sm">
              Data
            </p>
            <input
              type="date"
              value={dateStr}
              onChange={(e) => setDateStr(e.target.value)}
              className="w-full bg-transparent text-white text-lg outline-none"
              style={{ colorScheme: "dark" }}
            />
          </div>

          <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 space-y-4 flex-1">
            <p className="text-zinc-400 font-medium text-sm">
              Hora
            </p>
            <input
              type="time"
              value={timeStr}
              onChange={(e) => setTimeStr(e.target.value)}
              className="w-full bg-transparent text-white text-lg outline-none"
              style={{ colorScheme: "dark" }}
            />
          </div>
        </div>
      </div>

      <div className="flex gap-3 mt-auto pt-4">
        <button
          onClick={handleDelete}
          className="flex items-center justify-center gap-2 px-6 h-14 rounded-full bg-red-500/10 border-2 border-red-500/30 text-red-400 font-semibold active:scale-95 transition-transform hover:bg-red-500/20"
        >
          <Trash className="w-5 h-5" />
        </button>
        <button
          onClick={handleSave}
          className="flex-1 h-14 rounded-full bg-cyan-500 text-black font-bold active:scale-[0.98] shadow-lg shadow-cyan-500/20 transition-transform"
        >
          Salvar Alterações
        </button>
      </div>
    </div>
  );
}

function MoreAlarmesEditView({
  alarmId,
  alarms,
  setAlarms,
  setActiveTab,
}: any) {
  const alarm = alarms.find((a: any) => a.id === alarmId);
  const [time, setTime] = useState(alarm?.time || "07:00");
  const [active, setActive] = useState(alarm?.active || true);
  const [snooze, setSnooze] = useState(true);

  const days = ["D", "S", "T", "Q", "Q", "S", "S"];
  const [selectedDays, setSelectedDays] = useState([
    1, 2, 3, 4, 5,
  ]); // Mon-Fri

  const toggleDay = (i: number) => {
    if (selectedDays.includes(i))
      setSelectedDays(selectedDays.filter((d) => d !== i));
    else setSelectedDays([...selectedDays, i].sort());
  };

  const handleSave = () => {
    setAlarms(
      alarms.map((a: any) =>
        a.id === alarmId
          ? {
              ...a,
              time,
              active,
              label:
                selectedDays.length === 7
                  ? "Todos os dias"
                  : selectedDays.length === 5 &&
                      !selectedDays.includes(0) &&
                      !selectedDays.includes(6)
                    ? "Dias de Semana"
                    : "Personalizado",
            }
          : a,
      ),
    );
    toast.success("Alarme atualizado!");
    setActiveTab("more_alarmes");
  };

  const handleDelete = () => {
    setAlarms(alarms.filter((a: any) => a.id !== alarmId));
    toast.success("Alarme excluído!");
    setActiveTab("more_alarmes");
  };

  if (!alarm) return null;

  return (
    <div className="px-4 py-8 space-y-6 flex flex-col h-[75vh]">
      <div className="flex flex-col items-center justify-center mb-4">
        <input
          type="time"
          value={time}
          onChange={(e) => setTime(e.target.value)}
          className="bg-transparent text-7xl font-bold text-white outline-none text-center"
        />
      </div>

      <div className="space-y-4">
        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 space-y-4">
          <p className="text-white font-medium">Dias</p>
          <div className="flex justify-between">
            {days.map((d, i) => (
              <div
                key={i}
                onClick={() => toggleDay(i)}
                className={`w-10 h-10 rounded-full flex items-center justify-center font-medium text-sm cursor-pointer transition-colors ${selectedDays.includes(i) ? "bg-cyan-500 text-black" : "bg-zinc-800 text-zinc-400"}`}
              >
                {d}
              </div>
            ))}
          </div>
        </div>

        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 flex justify-between items-center cursor-pointer active:scale-[0.98]">
          <span className="text-white font-medium">
            Som do Alarme
          </span>
          <div className="flex items-center gap-2">
            <span className="text-zinc-400">Radar</span>
            <ChevronRight className="w-5 h-5 text-zinc-600" />
          </div>
        </div>

        <div className="bg-zinc-900 border border-zinc-800 rounded-3xl p-5 flex justify-between items-center">
          <span className="text-white font-medium">Adiar</span>
          <div
            onClick={() => setSnooze(!snooze)}
            className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${snooze ? "bg-cyan-500" : "bg-zinc-700"}`}
          >
            <div
              className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${snooze ? "right-1" : "left-1 bg-zinc-400"}`}
            ></div>
          </div>
        </div>
      </div>

      <div className="flex gap-3 mt-auto pt-4">
        <button
          onClick={handleDelete}
          className="flex items-center justify-center gap-2 px-6 h-14 rounded-full bg-red-500/10 border-2 border-red-500/30 text-red-400 font-semibold active:scale-95 transition-transform hover:bg-red-500/20"
        >
          <Trash className="w-5 h-5" />
          Excluir
        </button>
        <button
          onClick={handleSave}
          className="flex-1 h-14 rounded-full bg-cyan-500 text-black font-bold active:scale-[0.98] shadow-lg shadow-cyan-500/20 transition-transform"
        >
          Salvar
        </button>
      </div>
    </div>
  );
}

function MoreAlarmesNewView({
  setAlarms,
  setTimers,
  setActiveTab,
  activeAlarmTab,
}: any) {
  const [time, setTime] = useState(
    activeAlarmTab === "timers" ? "15" : "08:00",
  );
  const handleSave = () => {
    if (activeAlarmTab === "timers") {
      const formattedTime = time.includes(":")
        ? time
        : `${time}:00`;
      setTimers((prev: any) => [
        ...prev,
        {
          id: Date.now().toString(),
          duration: formattedTime,
          label: "Novo Timer",
          active: true,
        },
      ]);
      toast.success("Timer criado!");
    } else {
      setAlarms((prev: any) => [
        ...prev,
        {
          id: Date.now().toString(),
          time,
          label: "Alarme Personalizado",
          active: true,
        },
      ]);
      toast.success("Alarme criado!");
    }
    setActiveTab("more_alarmes");
  };

  return (
    <div className="px-4 py-6 flex flex-col items-center justify-center space-y-8 min-h-[60vh]">
      <p className="text-zinc-400">
        Definir{" "}
        {activeAlarmTab === "timers" ? "Duração" : "Horário"}
      </p>
      <input
        type={activeAlarmTab === "timers" ? "text" : "time"}
        value={time}
        onChange={(e) => setTime(e.target.value)}
        placeholder={
          activeAlarmTab === "timers" ? "Ex: 15:00" : ""
        }
        className="bg-transparent text-6xl font-bold text-white outline-none border-b-2 border-zinc-800 focus:border-cyan-500 pb-2 text-center"
      />
      <div className="w-full flex justify-between pt-8">
        <button
          onClick={() => setActiveTab("more_alarmes")}
          className="py-3 px-8 rounded-full text-zinc-400 font-medium active:scale-95"
        >
          Cancelar
        </button>
        <button
          onClick={handleSave}
          className="py-3 px-8 bg-cyan-500 text-black font-semibold rounded-full shadow-lg shadow-cyan-500/20 active:scale-95"
        >
          Salvar
        </button>
      </div>
    </div>
  );
}

function MoreSkillsView({ setActiveTab, setActiveSkill }: any) {
  const [skills, setSkills] = useState([
    {
      id: "spotify",
      name: "Spotify",
      connected: true,
      icon: <Music className="w-7 h-7" />,
      color: "text-green-400",
      bg: "bg-green-500/20",
    },
    {
      id: "tunein",
      name: "TuneIn Radio",
      connected: false,
      icon: <Radio className="w-7 h-7" />,
      color: "text-orange-400",
      bg: "bg-orange-500/20",
    },
  ]);

  const handleSkillAction = (skill: any) => {
    setActiveSkill(skill.id);
    setActiveTab("skill_login");
  };

  return (
    <div className="px-4 py-6 space-y-4">
      {skills.map((skill) => (
        <div
          key={skill.id}
          onClick={() => handleSkillAction(skill)}
          className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex items-center gap-5 cursor-pointer active:scale-[0.98] hover:bg-zinc-800/50 transition-colors"
        >
          <div
            className={`w-14 h-14 rounded-2xl flex items-center justify-center ${skill.bg} ${skill.color}`}
          >
            {skill.icon}
          </div>
          <div className="flex-1">
            <p className="text-white font-semibold text-lg">
              {skill.name}
            </p>
            <p className="text-zinc-400 text-sm mt-0.5">
              {skill.connected
                ? "Conta Vinculada"
                : "Não Vinculado"}
            </p>
          </div>
          <ChevronRight className="w-5 h-5 text-zinc-600" />
        </div>
      ))}
    </div>
  );
}

function MoreConfigView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const { t } = useLang();
  return (
    <div className="px-4 py-6 space-y-3">
      <div className="bg-zinc-900/60 rounded-3xl border border-zinc-800/50 overflow-hidden">
        <ProfileItem
          icon={<Settings />}
          title={t("Configurações do Dispositivo")}
          onClick={() => setActiveTab("more_config_device")}
        />
        <ProfileItem
          icon={<Languages />}
          title={t("Idioma da Aura")}
          onClick={() => setActiveTab("more_config_language")}
        />
        <ProfileItem
          icon={<Bell />}
          title={t("Notificações")}
          onClick={() =>
            setActiveTab("more_config_notifications")
          }
        />
        <ProfileItem
          icon={<User />}
          title={t("Contas e Perfis")}
          noBorder
          onClick={() => setActiveTab("more_config_accounts")}
        />
      </div>
    </div>
  );
}

function MoreConfigDeviceView({
  setActiveTab,
}: {
  setActiveTab: (tab: string) => void;
}) {
  const { t, lang } = useLang();

  const getLanguageName = () => {
    switch (lang) {
      case "pt":
        return "Português";
      case "en":
        return "English";
      case "es":
        return "Español";
      default:
        return "Português";
    }
  };

  return (
    <div className="px-4 py-6 space-y-3">
      <div
        onClick={() =>
          setActiveTab("more_config_devices_settings")
        }
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            {t("Configurações dos Dispositivos")}
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">
            5 dispositivos configuráveis
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("more_config_wifi")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            {t("Rede Wi-Fi")}
          </p>
          <p className="text-cyan-400 text-sm mt-0.5">
            Conectado a "Casa_5G"
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("more_config_bluetooth")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">Bluetooth</p>
          <p className="text-zinc-400 text-sm mt-0.5">
            Visível como "Aura Leonardo"
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("more_config_display")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            {t("Tela e Brilho")}
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">
            Brilho adaptável ativado
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
      <div
        onClick={() => setActiveTab("more_config_language")}
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
      >
        <div>
          <p className="text-white font-medium">
            {t("Idioma da Aura")}
          </p>
          <p className="text-cyan-400 text-sm mt-0.5">
            {getLanguageName()}
          </p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
    </div>
  );
}

function MoreConfigDevicesSettingsView({
  setActiveTab,
  devices,
}: {
  setActiveTab: (tab: string) => void;
  devices: any[];
}) {
  const { t } = useLang();

  const getDeviceIcon = (device: any) => {
    switch (device.type) {
      case "light":
        return <Lightbulb className="w-6 h-6" />;
      case "tv":
        return <Tv className="w-6 h-6" />;
      case "speaker":
        return <Speaker className="w-6 h-6" />;
      case "ac":
        return <Thermometer className="w-6 h-6" />;
      default:
        return <Settings className="w-6 h-6" />;
    }
  };

  const getConfigRoute = (device: any) => {
    if (device.id === "1" || device.id === "2")
      return "device_config_light_" + device.id;
    if (device.id === "3") return "device_config_tv";
    if (device.id === "4") return "device_config_echo";
    if (device.id === "5") return "device_config_ac";
    return "";
  };

  return (
    <div className="px-4 py-6 space-y-3">
      <p className="text-zinc-400 text-sm px-2 mb-4">
        Gerencie as configurações específicas de cada
        dispositivo
      </p>
      {devices.map((device) => (
        <div
          key={device.id}
          onClick={() => setActiveTab(getConfigRoute(device))}
          className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
        >
          <div className="flex items-center gap-4">
            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center ${device.active ? "bg-cyan-500/20 text-cyan-400" : "bg-zinc-800 text-zinc-500"}`}
            >
              {getDeviceIcon(device)}
            </div>
            <div>
              <p className="text-white font-medium">
                {device.name}
              </p>
              <p className="text-zinc-400 text-sm mt-0.5">
                {device.room}
              </p>
            </div>
          </div>
          <ChevronRight className="w-5 h-5 text-zinc-600" />
        </div>
      ))}
    </div>
  );
}

function DeviceConfigLightView({
  deviceId,
  devices,
  setDevices,
  setActiveTab,
}: {
  deviceId: string;
  devices: any[];
  setDevices: any;
  setActiveTab: (tab: string) => void;
}) {
  const device = devices.find((d) => d.id === deviceId);
  const [defaultIntensity, setDefaultIntensity] = useState(
    device?.value || 80,
  );
  const [routineActive, setRoutineActive] = useState(false);
  const [routineTime, setRoutineTime] = useState("22:00");

  if (!device) return null;

  const handleSave = () => {
    setDevices((prev: any) =>
      prev.map((d: any) =>
        d.id === deviceId
          ? { ...d, value: defaultIntensity }
          : d,
      ),
    );
    toast.success("Configurações salvas!");
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex flex-col items-center mb-6">
        <div className="w-24 h-24 rounded-full bg-yellow-500/20 flex items-center justify-center mb-3">
          <Lightbulb className="w-12 h-12 text-yellow-400" />
        </div>
        <h3 className="text-xl font-bold text-white">
          {device.name}
        </h3>
        <p className="text-zinc-400">{device.room}</p>
      </div>

      <div className="space-y-6">
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <div className="flex justify-between items-center">
            <span className="text-white font-medium">
              Intensidade Padrão
            </span>
            <span className="text-cyan-400 font-bold">
              {defaultIntensity}%
            </span>
          </div>
          <div className="flex items-center gap-4">
            <Lightbulb className="w-5 h-5 text-zinc-500" />
            <input
              type="range"
              min="10"
              max="100"
              value={defaultIntensity}
              onChange={(e) =>
                setDefaultIntensity(parseInt(e.target.value))
              }
              className="w-full h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-yellow-500"
            />
            <Lightbulb className="w-7 h-7 text-yellow-500" />
          </div>
          <p className="text-zinc-500 text-xs">
            Intensidade inicial ao ligar a luz
          </p>
        </div>

        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50">
          <div
            className="flex justify-between items-center cursor-pointer"
            onClick={() => setRoutineActive(!routineActive)}
          >
            <div>
              <p className="text-white font-medium">
                Rotina de Desligamento
              </p>
              <p className="text-zinc-500 text-sm mt-1">
                Desligar em um horário específico
              </p>
            </div>
            <div
              className={`w-14 h-8 rounded-full relative transition-colors flex-shrink-0 ${routineActive ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${routineActive ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          {routineActive && (
            <div className="mt-6 pt-6 border-t border-zinc-800 flex flex-col items-center">
              <p className="text-zinc-400 mb-4">
                Definir Horário
              </p>
              <input
                type="time"
                value={routineTime}
                onChange={(e) => setRoutineTime(e.target.value)}
                className="bg-transparent w-full text-5xl font-bold text-white outline-none border-b-2 border-zinc-800 focus:border-cyan-500 pb-2 text-center"
              />
            </div>
          )}
        </div>

        <button
          onClick={handleSave}
          className="w-full py-4 rounded-full bg-cyan-500 text-white font-medium hover:bg-cyan-600 transition-colors active:scale-[0.98] shadow-lg shadow-cyan-500/20"
        >
          Salvar Configurações
        </button>
      </div>
    </div>
  );
}

function DeviceConfigTvView({
  devices,
  setActiveTab,
}: {
  devices: any[];
  setActiveTab: (tab: string) => void;
}) {
  const device = devices.find((d) => d.id === "3");
  const [volume, setVolume] = useState(50);
  const [defaultChannel, setDefaultChannel] = useState(5);
  const [brightness, setBrightness] = useState(80);
  const [contrast, setContrast] = useState(70);
  const [colorTemp, setColorTemp] = useState("normal");
  const [routineActive, setRoutineActive] = useState(false);
  const [routineTime, setRoutineTime] = useState("23:30");
  const [hdmiCec, setHdmiCec] = useState(true);

  const handleSave = () => {
    toast.success("Configurações da TV salvas!");
  };

  if (!device) return null;

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex flex-col items-center mb-6">
        <div className="w-24 h-24 rounded-full bg-purple-500/20 flex items-center justify-center mb-3">
          <Tv className="w-12 h-12 text-purple-400" />
        </div>
        <h3 className="text-xl font-bold text-white">
          {device.name}
        </h3>
        <p className="text-zinc-400">{device.room}</p>
      </div>

      <div className="space-y-4">
        {/* Volume */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <div className="flex justify-between items-center">
            <span className="text-white font-medium">
              Volume Padrão
            </span>
            <span className="text-cyan-400 font-bold">
              {volume}%
            </span>
          </div>
          <input
            type="range"
            min="0"
            max="100"
            value={volume}
            onChange={(e) =>
              setVolume(parseInt(e.target.value))
            }
            className="w-full h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-purple-500"
          />
        </div>

        {/* Canal Padrão */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <div className="flex justify-between items-center">
            <span className="text-white font-medium">
              Canal Inicial
            </span>
            <span className="text-cyan-400 font-bold">
              {defaultChannel}
            </span>
          </div>
          <input
            type="range"
            min="1"
            max="99"
            value={defaultChannel}
            onChange={(e) =>
              setDefaultChannel(parseInt(e.target.value))
            }
            className="w-full h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-purple-500"
          />
        </div>

        {/* Configurações de Imagem */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-5">
          <p className="text-white font-medium mb-2">
            Configurações de Imagem
          </p>

          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-zinc-400 text-sm">
                Brilho
              </span>
              <span className="text-cyan-400 font-medium">
                {brightness}%
              </span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value={brightness}
              onChange={(e) =>
                setBrightness(parseInt(e.target.value))
              }
              className="w-full h-2 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-purple-500"
            />
          </div>

          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-zinc-400 text-sm">
                Contraste
              </span>
              <span className="text-cyan-400 font-medium">
                {contrast}%
              </span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value={contrast}
              onChange={(e) =>
                setContrast(parseInt(e.target.value))
              }
              className="w-full h-2 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-purple-500"
            />
          </div>

          <div className="space-y-3">
            <span className="text-zinc-400 text-sm">
              Temperatura de Cor
            </span>
            <div className="grid grid-cols-3 gap-2">
              {["frio", "normal", "quente"].map((temp) => (
                <button
                  key={temp}
                  onClick={() => setColorTemp(temp)}
                  className={`py-2 rounded-xl text-sm font-medium transition-all ${
                    colorTemp === temp
                      ? "bg-purple-500 text-white"
                      : "bg-zinc-800 text-zinc-400 hover:bg-zinc-700"
                  }`}
                >
                  {temp.charAt(0).toUpperCase() + temp.slice(1)}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Tempo de Descanso / Rotina */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50">
          <div
            className="flex justify-between items-center cursor-pointer"
            onClick={() => setRoutineActive(!routineActive)}
          >
            <div>
              <p className="text-white font-medium">
                Rotina de Desligamento
              </p>
              <p className="text-zinc-500 text-sm mt-1">
                Desligar em um horário específico
              </p>
            </div>
            <div
              className={`w-14 h-8 rounded-full relative transition-colors flex-shrink-0 ${routineActive ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${routineActive ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          {routineActive && (
            <div className="mt-6 pt-6 border-t border-zinc-800 flex flex-col items-center">
              <p className="text-zinc-400 mb-4">
                Definir Horário
              </p>
              <input
                type="time"
                value={routineTime}
                onChange={(e) => setRoutineTime(e.target.value)}
                className="bg-transparent w-full text-5xl font-bold text-white outline-none border-b-2 border-zinc-800 focus:border-cyan-500 pb-2 text-center"
              />
            </div>
          )}
        </div>

        {/* HDMI CEC */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50">
          <div className="flex justify-between items-center">
            <div>
              <p className="text-white font-medium">HDMI-CEC</p>
              <p className="text-zinc-500 text-sm mt-1">
                Controle dispositivos conectados
              </p>
            </div>
            <div
              onClick={() => setHdmiCec(!hdmiCec)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${hdmiCec ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${hdmiCec ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="w-full py-4 rounded-full bg-cyan-500 text-white font-medium hover:bg-cyan-600 transition-colors active:scale-[0.98] shadow-lg shadow-cyan-500/20"
        >
          Salvar Configurações
        </button>
      </div>
    </div>
  );
}

function DeviceConfigAcView({
  devices,
  setActiveTab,
}: {
  devices: any[];
  setActiveTab: (tab: string) => void;
}) {
  const device = devices.find((d) => d.id === "5");
  const [defaultTemp, setDefaultTemp] = useState(23);
  const [defaultMode, setDefaultMode] = useState("resfriar");
  const [fanSpeed, setFanSpeed] = useState("auto");
  const [ecoMode, setEcoMode] = useState(true);
  const [turboMode, setTurboMode] = useState(false);
  const [sleepMode, setSleepMode] = useState(false);

  const handleSave = () => {
    toast.success("Configurações do Ar Condicionado salvas!");
  };

  if (!device) return null;

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex flex-col items-center mb-6">
        <div className="w-24 h-24 rounded-full bg-blue-500/20 flex items-center justify-center mb-3">
          <Thermometer className="w-12 h-12 text-blue-400" />
        </div>
        <h3 className="text-xl font-bold text-white">
          {device.name}
        </h3>
        <p className="text-zinc-400">{device.room}</p>
      </div>

      <div className="space-y-4">
        {/* Temperatura Padrão */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <div className="flex justify-between items-center">
            <span className="text-white font-medium">
              Temperatura Padrão
            </span>
            <span className="text-cyan-400 text-2xl font-bold">
              {defaultTemp}°C
            </span>
          </div>
          <div className="flex items-center justify-center gap-6">
            <button
              onClick={() =>
                setDefaultTemp(Math.max(16, defaultTemp - 1))
              }
              className="w-12 h-12 rounded-full bg-zinc-800 text-blue-400 flex items-center justify-center active:scale-90 transition-transform"
            >
              <Minus className="w-6 h-6" />
            </button>
            <input
              type="range"
              min="16"
              max="30"
              value={defaultTemp}
              onChange={(e) =>
                setDefaultTemp(parseInt(e.target.value))
              }
              className="flex-1 h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-blue-500"
            />
            <button
              onClick={() =>
                setDefaultTemp(Math.min(30, defaultTemp + 1))
              }
              className="w-12 h-12 rounded-full bg-zinc-800 text-red-400 flex items-center justify-center active:scale-90 transition-transform"
            >
              <Plus className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Modo Padrão */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-3">
          <p className="text-white font-medium">Modo Padrão</p>
          <div className="grid grid-cols-3 gap-2">
            {["resfriar", "ventilar", "auto"].map((mode) => (
              <button
                key={mode}
                onClick={() => setDefaultMode(mode)}
                className={`py-2.5 rounded-xl text-sm font-medium transition-all ${
                  defaultMode === mode
                    ? "bg-blue-500 text-white"
                    : "bg-zinc-800 text-zinc-400 hover:bg-zinc-700"
                }`}
              >
                {mode.charAt(0).toUpperCase() + mode.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Velocidade do Ventilador */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-3">
          <p className="text-white font-medium">
            Velocidade do Ventilador
          </p>
          <div className="grid grid-cols-4 gap-2">
            {["baixa", "média", "alta", "auto"].map((speed) => (
              <button
                key={speed}
                onClick={() => setFanSpeed(speed)}
                className={`py-2.5 rounded-xl text-xs font-medium transition-all ${
                  fanSpeed === speed
                    ? "bg-blue-500 text-white"
                    : "bg-zinc-800 text-zinc-400 hover:bg-zinc-700"
                }`}
              >
                {speed.charAt(0).toUpperCase() + speed.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Modos Especiais */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <p className="text-white font-medium mb-2">
            Modos Especiais
          </p>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Modo Eco</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Economiza energia
              </p>
            </div>
            <div
              onClick={() => setEcoMode(!ecoMode)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${ecoMode ? "bg-green-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${ecoMode ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Modo Turbo</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Resfriamento rápido
              </p>
            </div>
            <div
              onClick={() => setTurboMode(!turboMode)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${turboMode ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${turboMode ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Modo Sono</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Ajuste gradual de temperatura
              </p>
            </div>
            <div
              onClick={() => setSleepMode(!sleepMode)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${sleepMode ? "bg-purple-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${sleepMode ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="w-full py-4 rounded-full bg-cyan-500 text-white font-medium hover:bg-cyan-600 transition-colors active:scale-[0.98] shadow-lg shadow-cyan-500/20"
        >
          Salvar Configurações
        </button>
      </div>
    </div>
  );
}

function DeviceConfigEchoView({
  devices,
  setActiveTab,
}: {
  devices: any[];
  setActiveTab: (tab: string) => void;
}) {
  const device = devices.find((d) => d.id === "4");
  const [volume, setVolume] = useState(50);
  const [bass, setBass] = useState(50);
  const [treble, setTreble] = useState(50);
  const [dolbyAtmos, setDolbyAtmos] = useState(true);
  const [roomAdaptation, setRoomAdaptation] = useState(true);
  const [dropIn, setDropIn] = useState(true);
  const [doNotDisturb, setDoNotDisturb] = useState(false);

  const handleSave = () => {
    toast.success("Configurações do Aura Echo salvas!");
  };

  if (!device) return null;

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex flex-col items-center mb-6">
        <div className="w-24 h-24 rounded-full bg-cyan-500/20 flex items-center justify-center mb-3">
          <Speaker className="w-12 h-12 text-cyan-400" />
        </div>
        <h3 className="text-xl font-bold text-white">
          {device.name}
        </h3>
        <p className="text-zinc-400">{device.room}</p>
      </div>

      <div className="space-y-4">
        {/* Volume */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <div className="flex justify-between items-center">
            <span className="text-white font-medium">
              Volume Padrão
            </span>
            <span className="text-cyan-400 font-bold">
              {volume}%
            </span>
          </div>
          <input
            type="range"
            min="0"
            max="100"
            value={volume}
            onChange={(e) =>
              setVolume(parseInt(e.target.value))
            }
            className="w-full h-3 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-cyan-500"
          />
        </div>

        {/* Equalização */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-5">
          <p className="text-white font-medium">Equalização</p>

          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-zinc-400 text-sm">
                Graves (Bass)
              </span>
              <span className="text-cyan-400 font-medium">
                {bass - 50 > 0 ? "+" : ""}
                {bass - 50}
              </span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value={bass}
              onChange={(e) =>
                setBass(parseInt(e.target.value))
              }
              className="w-full h-2 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-cyan-500"
            />
          </div>

          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <span className="text-zinc-400 text-sm">
                Agudos (Treble)
              </span>
              <span className="text-cyan-400 font-medium">
                {treble - 50 > 0 ? "+" : ""}
                {treble - 50}
              </span>
            </div>
            <input
              type="range"
              min="0"
              max="100"
              value={treble}
              onChange={(e) =>
                setTreble(parseInt(e.target.value))
              }
              className="w-full h-2 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-cyan-500"
            />
          </div>
        </div>

        {/* Recursos de Áudio */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <p className="text-white font-medium mb-2">
            Recursos de Áudio
          </p>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Dolby Atmos</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Áudio espacial imersivo
              </p>
            </div>
            <div
              onClick={() => setDolbyAtmos(!dolbyAtmos)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${dolbyAtmos ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${dolbyAtmos ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">
                Adaptação de Ambiente
              </p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Ajusta som ao espaço
              </p>
            </div>
            <div
              onClick={() => setRoomAdaptation(!roomAdaptation)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${roomAdaptation ? "bg-cyan-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${roomAdaptation ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>
        </div>

        {/* Comunicação */}
        <div className="bg-zinc-900/80 p-5 rounded-3xl border border-zinc-800/50 space-y-4">
          <p className="text-white font-medium mb-2">
            Comunicação
          </p>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Drop In</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Chamadas instantâneas
              </p>
            </div>
            <div
              onClick={() => setDropIn(!dropIn)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${dropIn ? "bg-green-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${dropIn ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>

          <div className="flex justify-between items-center">
            <div>
              <p className="text-white text-sm">Não Perturbe</p>
              <p className="text-zinc-500 text-xs mt-0.5">
                Silencia chamadas e notificações
              </p>
            </div>
            <div
              onClick={() => setDoNotDisturb(!doNotDisturb)}
              className={`w-14 h-8 rounded-full cursor-pointer relative transition-colors ${doNotDisturb ? "bg-red-500" : "bg-zinc-700"}`}
            >
              <div
                className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${doNotDisturb ? "right-1" : "left-1"}`}
              ></div>
            </div>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="w-full py-4 rounded-full bg-cyan-500 text-white font-medium hover:bg-cyan-600 transition-colors active:scale-[0.98] shadow-lg shadow-cyan-500/20"
        >
          Salvar Configurações
        </button>
      </div>
    </div>
  );
}

function MoreConfigWifiView() {
  const [searching, setSearching] = useState(false);
  const [connected, setConnected] = useState("Casa_5G");

  const handleConnect = (net: string) => {
    setSearching(true);
    setTimeout(() => {
      setConnected(net);
      setSearching(false);
      toast.success(`Conectado à rede ${net}`);
    }, 1500);
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex justify-between items-center">
        <p className="text-zinc-400">Redes disponíveis</p>
        <button
          onClick={() => {
            setSearching(true);
            setTimeout(() => setSearching(false), 2000);
          }}
          className="text-cyan-400 text-sm hover:text-cyan-300"
        >
          {searching ? "Buscando..." : "Atualizar"}
        </button>
      </div>

      <div className="space-y-2">
        {[
          "Casa_5G",
          "Visitantes",
          "Vivo_Fibra_9A",
          "Rede_Publica",
        ].map((net) => (
          <div
            key={net}
            onClick={() => handleConnect(net)}
            className={`p-4 rounded-2xl border flex justify-between items-center cursor-pointer active:scale-[0.98] transition-all ${connected === net ? "bg-cyan-900/20 border-cyan-500/50" : "bg-zinc-900/60 border-zinc-800/50 hover:bg-zinc-800/50"}`}
          >
            <span
              className={
                connected === net
                  ? "text-cyan-400 font-medium"
                  : "text-zinc-200"
              }
            >
              {net}
            </span>
            {connected === net && (
              <span className="text-cyan-400 text-xs font-medium">
                Conectado
              </span>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function MoreConfigBluetoothView() {
  const [searching, setSearching] = useState(false);
  const [connected, setConnected] = useState("");

  const handleConnect = (device: string) => {
    setSearching(true);
    setTimeout(() => {
      setConnected(device === connected ? "" : device);
      setSearching(false);
      toast.success(
        device === connected
          ? `Desconectado de ${device}`
          : `Pareado com ${device}`,
      );
    }, 1500);
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="bg-zinc-900/60 p-4 rounded-2xl border border-zinc-800/50">
        <p className="text-white font-medium mb-1">
          Seu Dispositivo
        </p>
        <p className="text-zinc-400 text-sm">
          Visível aos outros como "Aura Leonardo".
        </p>
      </div>

      <div className="flex justify-between items-center mt-6">
        <p className="text-zinc-400">Meus Dispositivos</p>
        <button
          onClick={() => {
            setSearching(true);
            setTimeout(() => setSearching(false), 2000);
          }}
          className="text-cyan-400 text-sm hover:text-cyan-300"
        >
          {searching ? "Buscando..." : "Procurar"}
        </button>
      </div>

      <div className="space-y-2">
        {[
          "Fone Bluetooth Sony",
          "Caixa de Som JBL",
          "Carro_BT",
        ].map((device) => (
          <div
            key={device}
            onClick={() => handleConnect(device)}
            className={`p-4 rounded-2xl border flex justify-between items-center cursor-pointer active:scale-[0.98] transition-all ${connected === device ? "bg-cyan-900/20 border-cyan-500/50" : "bg-zinc-900/60 border-zinc-800/50 hover:bg-zinc-800/50"}`}
          >
            <span
              className={
                connected === device
                  ? "text-cyan-400 font-medium"
                  : "text-zinc-200"
              }
            >
              {device}
            </span>
            <span className="text-zinc-500 text-xs">
              {connected === device
                ? "Conectado"
                : "Não conectado"}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

function MoreConfigLanguageView() {
  const { lang, setLang, t } = useLang();
  const languages = [
    { code: "pt", name: "Português (Brasil)", icon: "🇧🇷" },
    { code: "en", name: "English (US)", icon: "🇺🇸" },
    {
      code: "es",
      name: "Español (América Latina)",
      icon: "🇲🇽",
    },
  ];

  return (
    <div className="px-4 py-6 space-y-4">
      <div className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 mb-6">
        <div className="flex items-center gap-3 mb-2">
          <Globe className="w-6 h-6 text-cyan-500" />
          <p className="text-white font-medium">
            {t("Idioma da Aura")}
          </p>
        </div>
        <p className="text-zinc-400 text-sm">
          Este idioma será aplicado a toda a interface e
          comandos de voz da Aura.
        </p>
      </div>

      <div className="space-y-3">
        {languages.map((l) => (
          <div
            key={l.code}
            onClick={() => {
              setLang(l.code);
              toast.success(`Idioma alterado para ${l.name}`);
            }}
            className={`p-4 rounded-2xl flex items-center justify-between cursor-pointer transition-all active:scale-[0.98] ${lang === l.code ? "bg-cyan-900/20 border border-cyan-500/50" : "bg-zinc-900/60 border border-zinc-800/50 hover:bg-zinc-800/50"}`}
          >
            <div className="flex items-center gap-4">
              <span className="text-2xl">{l.icon}</span>
              <span
                className={`font-medium ${lang === l.code ? "text-cyan-400" : "text-zinc-200"}`}
              >
                {l.name}
              </span>
            </div>
            <div
              className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${lang === l.code ? "border-cyan-500 bg-cyan-500" : "border-zinc-600"}`}
            >
              {lang === l.code && (
                <div className="w-2.5 h-2.5 bg-white rounded-full"></div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MoreConfigDisplayView({
  themeMode,
  setThemeMode,
}: any) {
  const [brightness, setBrightness] = useState(70);

  return (
    <div className="px-4 py-8 space-y-10">
      <div className="space-y-6">
        <div className="flex justify-between items-center px-2">
          <label className="text-white font-medium">
            Brilho da Tela
          </label>
          <span className="text-cyan-400 text-sm">
            {brightness}%
          </span>
        </div>
        <div className="flex items-center gap-4">
          <Sun className="w-5 h-5 text-zinc-500" />
          <input
            type="range"
            min="0"
            max="100"
            value={brightness}
            onChange={(e) =>
              setBrightness(parseInt(e.target.value))
            }
            className="w-full h-2 bg-zinc-800 rounded-lg appearance-none cursor-pointer accent-cyan-500"
          />
          <Sun className="w-7 h-7 text-white" />
        </div>
      </div>

      <div className="space-y-4">
        <label className="text-white font-medium px-2">
          Aparência do Aplicativo
        </label>
        <div className="flex flex-col gap-3">
          <div
            onClick={() => setThemeMode("dark")}
            className={`p-4 rounded-2xl border text-center cursor-pointer transition-all active:scale-[0.98] ${themeMode === "dark" ? "bg-zinc-900 border-cyan-500" : "bg-zinc-900/40 border-zinc-800"}`}
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-zinc-950 rounded-full border border-zinc-800 shrink-0"></div>
              <div className="text-left flex-1">
                <p
                  className={
                    themeMode === "dark"
                      ? "text-white font-medium"
                      : "text-zinc-400"
                  }
                >
                  Modo Escuro
                </p>
                <p className="text-zinc-500 text-xs">
                  Tema escuro para todas as telas
                </p>
              </div>
            </div>
          </div>

          <div
            onClick={() => setThemeMode("light")}
            className={`p-4 rounded-2xl border text-center cursor-pointer transition-all active:scale-[0.98] ${themeMode === "light" ? "bg-white border-cyan-500" : "bg-zinc-900/40 border-zinc-800"}`}
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-zinc-100 rounded-full border border-zinc-300 shrink-0"></div>
              <div className="text-left flex-1">
                <p
                  className={
                    themeMode === "light"
                      ? "text-black font-medium"
                      : "text-zinc-400"
                  }
                >
                  Modo Claro
                </p>
                <p
                  className={
                    themeMode === "light"
                      ? "text-zinc-600 text-xs"
                      : "text-zinc-500 text-xs"
                  }
                >
                  Tema claro para todas as telas
                </p>
              </div>
            </div>
          </div>

          <div
            onClick={() => setThemeMode("system")}
            className={`p-4 rounded-2xl border text-center cursor-pointer transition-all active:scale-[0.98] ${themeMode === "system" ? "bg-zinc-900 border-cyan-500" : "bg-zinc-900/40 border-zinc-800"}`}
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-zinc-950 to-zinc-100 rounded-full border border-zinc-700 shrink-0"></div>
              <div className="text-left flex-1">
                <p
                  className={
                    themeMode === "system"
                      ? "text-white font-medium"
                      : "text-zinc-400"
                  }
                >
                  Padrão do Sistema
                </p>
                <p className="text-zinc-500 text-xs">
                  Usar configuração do dispositivo
                </p>
              </div>
            </div>
          </div>
        </div>
        <p className="text-zinc-500 text-xs px-2 mt-2">
          O tema será aplicado imediatamente a todas as telas do
          aplicativo.
        </p>
      </div>
    </div>
  );
}

function MoreConfigNotificationsView({ setActiveTab }: any) {
  const [dnd, setDnd] = useState(false);
  const [delivery, setDelivery] = useState(true);

  return (
    <div className="px-4 py-6 space-y-3">
      <div
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
        onClick={() => setDnd(!dnd)}
      >
        <div>
          <p className="text-white font-medium">Não Perturbe</p>
          <p
            className={
              dnd
                ? "text-cyan-400 text-sm mt-0.5"
                : "text-zinc-400 text-sm mt-0.5"
            }
          >
            {dnd ? "Ativado" : "Desativado"}
          </p>
        </div>
        <div
          className={`w-12 h-6 rounded-full relative transition-colors ${dnd ? "bg-cyan-500" : "bg-zinc-700"}`}
        >
          <div
            className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${dnd ? "right-1" : "left-1 bg-zinc-400"}`}
          ></div>
        </div>
      </div>
      <div
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
        onClick={() => setDelivery(!delivery)}
      >
        <div>
          <p className="text-white font-medium">
            Alertas de Entrega
          </p>
          <p
            className={
              delivery
                ? "text-cyan-400 text-sm mt-0.5"
                : "text-zinc-400 text-sm mt-0.5"
            }
          >
            {delivery ? "Ativado" : "Desativado"}
          </p>
        </div>
        <div
          className={`w-12 h-6 rounded-full relative transition-colors ${delivery ? "bg-cyan-500" : "bg-zinc-700"}`}
        >
          <div
            className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${delivery ? "right-1" : "left-1 bg-zinc-400"}`}
          ></div>
        </div>
      </div>
      <div
        className="bg-zinc-900/60 p-5 rounded-3xl border border-zinc-800/50 flex justify-between items-center cursor-pointer hover:bg-zinc-800/50 transition-colors active:scale-[0.98]"
        onClick={() =>
          setActiveTab("more_config_notifications_ringtone")
        }
      >
        <div>
          <p className="text-white font-medium">
            Toque de Notificação
          </p>
          <p className="text-zinc-400 text-sm mt-0.5">Radar</p>
        </div>
        <ChevronRight className="w-5 h-5 text-zinc-600" />
      </div>
    </div>
  );
}

function MoreConfigNotificationsRingtoneView({
  ringtone,
  setRingtone,
}: any) {
  const ringtones = [
    "Radar",
    "Apex",
    "Beacon",
    "Bulletin",
    "By The Seaside",
    "Chimes",
    "Circuit",
    "Constellation",
    "Cosmic",
    "Crystals",
    "Illuminate",
    "Night Owl",
    "Playtime",
    "Presto",
    "Radiate",
  ];

  return (
    <div className="px-4 py-6 space-y-2 pb-24">
      {ringtones.map((r) => (
        <div
          key={r}
          onClick={() => {
            setRingtone(r);
            toast(`Toque ${r} selecionado`);
          }}
          className={`p-4 rounded-2xl flex items-center justify-between cursor-pointer transition-colors active:scale-[0.98] ${ringtone === r ? "bg-cyan-900/20 border border-cyan-900/50" : "bg-transparent border border-transparent hover:bg-zinc-900/50"}`}
        >
          <span
            className={`font-medium ${ringtone === r ? "text-cyan-400" : "text-zinc-300"}`}
          >
            {r}
          </span>
          <div
            className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${ringtone === r ? "border-cyan-500 bg-cyan-500" : "border-zinc-600"}`}
          >
            {ringtone === r && (
              <div className="w-2.5 h-2.5 bg-white rounded-full"></div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

function MoreConfigAccountsView({
  accounts,
  setActiveTab,
}: any) {
  return (
    <div className="px-4 py-6 space-y-4">
      <p className="text-zinc-400 px-2">
        Perfis vinculados à esta Aura
      </p>
      {accounts.map((acc: any) => (
        <div
          key={acc.id}
          className="bg-zinc-900/60 p-4 rounded-3xl border border-cyan-900/30 flex items-center gap-4 cursor-pointer active:scale-95"
          onClick={() => setActiveTab("profile")}
        >
          <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-cyan-500 p-0.5 bg-zinc-800 flex items-center justify-center">
            {acc.image ? (
              <img
                src={acc.image}
                alt={acc.name}
                className="w-full h-full rounded-full object-cover"
              />
            ) : (
              <User className="w-6 h-6 text-zinc-500" />
            )}
          </div>
          <div className="flex-1">
            <p className="text-white font-semibold">
              {acc.name}
            </p>
            <p className="text-cyan-400 text-xs">{acc.role}</p>
          </div>
          <Settings className="w-5 h-5 text-zinc-500" />
        </div>
      ))}
      <button
        onClick={() => setActiveTab("more_config_accounts_add")}
        className="w-full py-4 border border-zinc-800 border-dashed rounded-full text-zinc-400 hover:text-white flex items-center justify-center gap-2 transition-colors active:scale-95"
      >
        <Plus className="w-5 h-5" /> Adicionar Perfil
      </button>
    </div>
  );
}

function MoreConfigAccountsAddView({
  accounts,
  setAccounts,
  setActiveTab,
}: any) {
  const [name, setName] = useState("");

  const handleSave = () => {
    if (!name) return toast.error("Insira um nome");
    setAccounts([
      ...accounts,
      {
        id: Date.now().toString(),
        name,
        role: "Membro",
        image: null,
      },
    ]);
    toast.success("Perfil adicionado com sucesso!");
    setActiveTab("more_config_accounts");
  };

  return (
    <div className="px-4 py-8 flex flex-col h-[70vh]">
      <div className="flex flex-col items-center mb-8">
        <div className="w-24 h-24 rounded-full bg-zinc-800 border-4 border-zinc-900 flex items-center justify-center text-zinc-500 mb-4">
          <User className="w-10 h-10" />
        </div>
        <p className="text-zinc-400 text-center text-sm">
          Adicione um novo membro para usar a Aura com
          configurações personalizadas
        </p>
      </div>

      <input
        type="text"
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Nome do Membro"
        className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500 mb-4"
      />

      <button
        onClick={handleSave}
        className="w-full bg-cyan-500 text-black font-bold text-lg py-4 rounded-full mt-auto active:scale-95 transition-all"
      >
        Concluir Adição
      </button>
    </div>
  );
}

function MoreAtividadesView() {
  const [atividades, setAtividades] = useState([
    {
      id: 1,
      time: "Hoje, 09:41",
      text: '"Aura, ligar luz principal"',
    },
    {
      id: 2,
      time: "Ontem, 20:15",
      text: '"Aura, tocar Jazz Focus"',
    },
    {
      id: 3,
      time: "Ontem, 18:30",
      text: '"Aura, qual a previsão do tempo para amanhã?"',
    },
  ]);

  const handleDelete = (id: number) => {
    setAtividades(atividades.filter((a) => a.id !== id));
    toast.success("Atividade removida");
  };

  return (
    <div className="px-4 py-6 space-y-4 overflow-hidden">
      <h3 className="text-zinc-400 font-medium px-1 mb-2">
        Histórico Recente
      </h3>
      <AnimatePresence>
        {atividades.map((a: any) => (
          <motion.div
            key={a.id}
            layout
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0, scale: 0.8 }}
            drag="x"
            dragConstraints={{ left: -100, right: 0 }}
            onDragEnd={(e, { offset }) => {
              if (offset.x < -80) handleDelete(a.id);
            }}
            className="relative"
          >
            <div className="absolute right-0 top-0 bottom-0 w-20 bg-red-500 rounded-3xl flex items-center justify-center text-white z-0 mb-4">
              <Trash className="w-6 h-6" />
            </div>
            <div className="bg-zinc-900 border border-zinc-800/50 p-5 rounded-3xl relative z-10 mb-4">
              <p className="text-zinc-500 text-xs font-medium mb-2 uppercase tracking-wider">
                {a.time}
              </p>
              <p className="text-white text-lg">{a.text}</p>
            </div>
          </motion.div>
        ))}
      </AnimatePresence>
      {atividades.length === 0 && (
        <p className="text-center text-zinc-500 py-8">
          Nenhuma atividade recente.
        </p>
      )}
    </div>
  );
}

// ==========================================
// AUXILIARY UI COMPONENTS
// ==========================================

function NavItem({
  icon,
  label,
  isActive,
  onClick,
}: {
  icon: React.ReactNode;
  label: string;
  isActive: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`flex flex-col items-center justify-center w-16 gap-1 transition-colors ${
        isActive
          ? "text-cyan-400"
          : "text-zinc-500 hover:text-zinc-300"
      }`}
    >
      <div
        className={`${isActive ? "scale-110" : "scale-100"} transition-transform duration-200`}
      >
        {React.cloneElement(icon as React.ReactElement, {
          className: `w-6 h-6 ${isActive ? "fill-cyan-400/20" : ""}`,
        })}
      </div>
      <span className="text-[10px] font-medium tracking-wide">
        {label}
      </span>
    </button>
  );
}

function ActionIcon({
  icon,
  label,
  color,
  bg,
  onClick,
}: {
  icon: React.ReactNode;
  label: string;
  color: string;
  bg: string;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className="flex flex-col items-center gap-2 cursor-pointer group active:scale-95 transition-transform"
    >
      <div
        className={`w-14 h-14 rounded-full ${bg} ${color} flex items-center justify-center transition-transform group-hover:scale-105 border border-${color.split("-")[1]}-500/20`}
      >
        {icon}
      </div>
      <span className="text-xs text-zinc-300 font-medium">
        {label}
      </span>
    </div>
  );
}

function CommunicateAddContactView({
  setContacts,
  setActiveTab,
}: any) {
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [deviceType, setDeviceType] = useState("Celular");

  const handleSave = () => {
    if (!name || !phone)
      return toast.error("Preencha os campos obrigatórios");
    setContacts((prev: any) => [
      ...prev,
      {
        id: Date.now().toString(),
        name,
        time: deviceType,
        type: "Membro Aura",
      },
    ]);
    toast.success("Contato adicionado!");
    setActiveTab("communicate");
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="space-y-4">
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Nome do Contato
          </label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-white outline-none focus:border-cyan-500"
            placeholder="Ex: João"
          />
        </div>
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Número de Telefone
          </label>
          <input
            type="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-white outline-none focus:border-cyan-500"
            placeholder="(11) 99999-9999"
          />
        </div>
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Tipo de Dispositivo
          </label>
          <div className="flex gap-2">
            <button
              onClick={() => setDeviceType("Celular")}
              className={`flex-1 py-3 rounded-xl border ${deviceType === "Celular" ? "border-cyan-500 bg-cyan-900/30 text-cyan-400" : "border-zinc-800 bg-zinc-900 text-zinc-400"}`}
            >
              Celular
            </button>
            <button
              onClick={() => setDeviceType("Aura Echo")}
              className={`flex-1 py-3 rounded-xl border ${deviceType === "Aura Echo" ? "border-cyan-500 bg-cyan-900/30 text-cyan-400" : "border-zinc-800 bg-zinc-900 text-zinc-400"}`}
            >
              Aura Echo
            </button>
          </div>
        </div>
      </div>
      <button
        onClick={handleSave}
        className="w-full bg-cyan-500 text-black font-semibold rounded-xl py-4 mt-8 active:scale-95 transition-transform"
      >
        Adicionar Contato
      </button>
    </div>
  );
}

function CommunicateEditContactView({
  contactId,
  contacts,
  setContacts,
  setActiveTab,
}: any) {
  const contact = contacts.find((c: any) => c.id === contactId);
  const [name, setName] = useState(contact?.name || "");
  const [phone, setPhone] = useState(
    contact?.phone || "(11) 99999-9999",
  );
  const [deviceType, setDeviceType] = useState(
    contact?.time || "Celular",
  );

  const handleSave = () => {
    if (!name || !phone)
      return toast.error("Nome e telefone são obrigatórios");
    setContacts(
      contacts.map((c: any) =>
        c.id === contactId
          ? { ...c, name, phone, time: deviceType }
          : c,
      ),
    );
    toast.success("Contato atualizado!");
    setActiveTab("communicate");
  };

  const handleDelete = () => {
    setContacts(
      contacts.filter((c: any) => c.id !== contactId),
    );
    toast.success("Contato apagado!");
    setActiveTab("communicate");
  };

  if (!contact) return null;

  return (
    <div className="px-4 py-6 space-y-6">
      <div className="flex flex-col items-center justify-center mb-8 mt-4">
        <div className="w-24 h-24 rounded-full bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center text-white text-3xl font-bold mb-4">
          {name.charAt(0) || "U"}
        </div>
      </div>
      <div className="space-y-4">
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Nome do Contato
          </label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-white outline-none focus:border-cyan-500"
          />
        </div>
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Número de Telefone
          </label>
          <input
            type="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-white outline-none focus:border-cyan-500"
          />
        </div>
        <div>
          <label className="text-zinc-400 text-sm mb-1 block">
            Tipo de Dispositivo
          </label>
          <div className="flex gap-2">
            <button
              onClick={() => setDeviceType("Celular")}
              className={`flex-1 py-3 rounded-xl border ${deviceType === "Celular" || deviceType === "Casa" ? "border-cyan-500 bg-cyan-900/30 text-cyan-400" : "border-zinc-800 bg-zinc-900 text-zinc-400"}`}
            >
              Celular
            </button>
            <button
              onClick={() => setDeviceType("Aura Echo")}
              className={`flex-1 py-3 rounded-xl border ${deviceType === "Aura Echo" ? "border-cyan-500 bg-cyan-900/30 text-cyan-400" : "border-zinc-800 bg-zinc-900 text-zinc-400"}`}
            >
              Aura Echo
            </button>
          </div>
        </div>
      </div>
      <div className="pt-4 space-y-3">
        <button
          onClick={handleSave}
          className="w-full bg-cyan-500 text-black font-semibold rounded-xl py-4 active:scale-95 transition-transform"
        >
          Salvar Alterações
        </button>
        <button
          onClick={handleDelete}
          className="w-full bg-transparent border border-red-500/50 text-red-500 font-semibold rounded-xl py-4 active:scale-95 transition-transform"
        >
          Apagar Contato
        </button>
      </div>
    </div>
  );
}

function CommunicateAddGroupView({
  contacts,
  setContacts,
  setActiveTab,
}: any) {
  const [groupName, setGroupName] = useState("");
  const [selectedMembers, setSelectedMembers] = useState<
    string[]
  >([]);

  const handleToggleMember = (id: string) => {
    setSelectedMembers((prev) =>
      prev.includes(id)
        ? prev.filter((m) => m !== id)
        : [...prev, id],
    );
  };

  const handleSave = () => {
    if (!groupName) return toast.error("Dê um nome ao grupo");
    if (selectedMembers.length === 0)
      return toast.error("Selecione pelo menos um membro");
    toast.success(`Grupo "${groupName}" criado com sucesso!`);
    setActiveTab("communicate");
  };

  return (
    <div className="px-4 py-6 space-y-6">
      <div>
        <label className="text-zinc-400 text-sm mb-1 block">
          Nome do Grupo
        </label>
        <input
          type="text"
          value={groupName}
          onChange={(e) => setGroupName(e.target.value)}
          className="w-full bg-zinc-900 border border-zinc-800 rounded-xl px-4 py-3 text-white outline-none focus:border-cyan-500"
          placeholder="Ex: Família"
        />
      </div>
      <div>
        <label className="text-zinc-400 text-sm mb-3 block">
          Adicionar Membros
        </label>
        <div className="space-y-2 max-h-[40vh] overflow-y-auto no-scrollbar">
          {contacts.map((c: any) => (
            <div
              key={c.id}
              onClick={() => handleToggleMember(c.id)}
              className={`flex items-center gap-3 p-3 rounded-xl border cursor-pointer active:scale-[0.98] transition-all ${selectedMembers.includes(c.id) ? "bg-cyan-900/20 border-cyan-500" : "bg-zinc-900 border-zinc-800"}`}
            >
              <div
                className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${selectedMembers.includes(c.id) ? "border-cyan-500 bg-cyan-500" : "border-zinc-500"}`}
              >
                {selectedMembers.includes(c.id) && (
                  <div className="w-2 h-2 bg-white rounded-full"></div>
                )}
              </div>
              <div className="w-10 h-10 rounded-full bg-zinc-800 flex items-center justify-center text-white font-bold">
                {c.name.charAt(0)}
              </div>
              <div className="flex-1">
                <p className="text-white font-medium">
                  {c.name}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
      <button
        onClick={handleSave}
        className="w-full bg-cyan-500 text-black font-semibold rounded-xl py-4 active:scale-95 transition-transform mt-4"
      >
        Criar Grupo
      </button>
    </div>
  );
}

function ContactCard({
  name,
  time,
  type,
  onClick,
}: {
  name: string;
  time: string;
  type: string;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className="flex items-center gap-4 bg-zinc-900/50 p-4 rounded-2xl border border-zinc-800/50 hover:bg-zinc-800/80 transition-colors cursor-pointer active:scale-[0.98]"
    >
      <div className="w-12 h-12 rounded-full bg-zinc-800 flex items-center justify-center text-zinc-400 font-bold text-lg">
        {name.charAt(0)}
      </div>
      <div className="flex-1">
        <h3 className="text-white font-medium">{name}</h3>
        <p className="text-xs text-zinc-400">
          {type} • {time}
        </p>
      </div>
      <Phone className="w-5 h-5 text-cyan-500" />
    </div>
  );
}

function MediaCard({
  img,
  title,
  subtitle,
  onClick,
}: {
  img: string;
  title: string;
  subtitle: string;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className="flex flex-col gap-2 cursor-pointer group active:scale-[0.98] transition-transform w-32 shrink-0"
    >
      <div className="rounded-2xl overflow-hidden bg-zinc-800 relative w-32 h-32">
        <img
          src={img}
          alt={title}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
        />
        <div className="absolute inset-0 bg-black/20 group-hover:bg-transparent transition-colors" />
        <div className="absolute bottom-2 right-2 w-8 h-8 rounded-full bg-black/50 backdrop-blur-md flex items-center justify-center text-white opacity-0 group-hover:opacity-100 transition-opacity">
          <PlayCircle className="w-5 h-5" />
        </div>
      </div>
      <div>
        <h3 className="text-white font-medium text-sm truncate">
          {title}
        </h3>
        <p className="text-zinc-400 text-xs truncate">
          {subtitle}
        </p>
      </div>
    </div>
  );
}

function DeviceCard({
  icon,
  name,
  room,
  status,
  active,
  onClick,
  onToggle,
  onSettings,
}: {
  icon: React.ReactNode;
  name: string;
  room: string;
  status: string;
  active: boolean;
  onClick?: () => void;
  onToggle?: () => void;
  onSettings?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className={`rounded-3xl p-4 transition-transform active:scale-[0.98] cursor-pointer border relative ${active ? "bg-zinc-900/80 border-cyan-900/30" : "bg-zinc-900/40 border-zinc-800/50 hover:bg-zinc-800/50"}`}
    >
      {onSettings && (
        <button
          onClick={(e) => {
            e.stopPropagation();
            onSettings();
          }}
          className="absolute bottom-3 right-3 w-8 h-8 rounded-full bg-zinc-800/80 border border-zinc-700/50 flex items-center justify-center text-zinc-400 hover:text-cyan-400 hover:bg-zinc-700/80 transition-all active:scale-95 z-10"
        >
          <Settings className="w-4 h-4" />
        </button>
      )}
      <div className="flex justify-between items-start mb-6">
        <div
          className={`w-10 h-10 rounded-full flex items-center justify-center ${active ? "bg-cyan-500/20 text-cyan-400" : "bg-zinc-800 text-zinc-400"}`}
        >
          {React.cloneElement(icon as React.ReactElement, {
            className: "w-5 h-5",
          })}
        </div>
        <div
          onClick={(e) => {
            e.stopPropagation();
            if (onToggle) onToggle();
            else if (onClick) onClick();
          }}
          className={`w-10 h-6 rounded-full relative transition-colors ${active ? "bg-cyan-500" : "bg-zinc-700"}`}
        >
          <div
            className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-all ${active ? "right-1" : "left-1 bg-zinc-400"}`}
          ></div>
        </div>
      </div>
      <div>
        <h3 className="font-medium text-zinc-100 truncate">
          {name}
        </h3>
        <p className="text-xs text-zinc-400 mt-0.5">{room}</p>
        <p
          className={`text-xs mt-2 font-medium ${active ? "text-cyan-400" : "text-zinc-500"}`}
        >
          {status}
        </p>
      </div>
    </div>
  );
}

function ListItem({
  icon,
  title,
  onClick,
}: {
  icon: React.ReactNode;
  title: string;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className="flex items-center justify-between p-4 bg-zinc-900/40 hover:bg-zinc-800/60 rounded-2xl border border-transparent hover:border-zinc-800 transition-all cursor-pointer active:scale-[0.98]"
    >
      <div className="flex items-center gap-4">
        <div className="text-zinc-400">
          {React.cloneElement(icon as React.ReactElement, {
            className: "w-6 h-6",
          })}
        </div>
        <span className="text-zinc-200 font-medium">
          {title}
        </span>
      </div>
      <ChevronRight className="w-5 h-5 text-zinc-600" />
    </div>
  );
}

function ProfileItem({
  icon,
  title,
  color = "text-zinc-200",
  noBorder = false,
  onClick,
}: {
  icon: React.ReactNode;
  title: string;
  color?: string;
  noBorder?: boolean;
  onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className={`flex items-center justify-between p-5 hover:bg-zinc-800/50 transition-all cursor-pointer active:bg-zinc-800 ${!noBorder ? "border-b border-zinc-800/50" : ""}`}
    >
      <div className="flex items-center gap-4">
        <div
          className={
            color === "text-red-400"
              ? "text-red-400"
              : "text-cyan-500"
          }
        >
          {React.cloneElement(icon as React.ReactElement, {
            className: "w-6 h-6",
          })}
        </div>
        <span className={`font-medium ${color}`}>{title}</span>
      </div>
      <ChevronRight
        className={`w-5 h-5 ${color === "text-red-400" ? "text-red-400/50" : "text-zinc-600"}`}
      />
    </div>
  );
}

function LoginView({ onLogin }: { onLogin: () => void }) {
  return (
    <div className="flex justify-center bg-black min-h-screen">
      <div className="w-full max-w-md bg-zinc-950 min-h-screen text-zinc-100 flex flex-col relative overflow-hidden shadow-2xl sm:border-x sm:border-zinc-800 p-8 justify-center items-center">
        {/* Logo */}
        <div className="mb-12 relative">
          <div className="absolute inset-0 blur-2xl bg-cyan-500/20 animate-pulse" />
          <img
            src="/src/imports/logo-light.png"
            alt="Aura Logo"
            className="w-40 h-40 object-contain relative z-10 drop-shadow-[0_0_30px_rgba(6,182,212,0.4)]"
          />
        </div>
        <h1 className="text-3xl font-bold text-white mb-2">
          Bem-vindo(a)
        </h1>
        <p className="text-zinc-400 mb-10 text-center">
          Faça login na sua conta Aura para continuar
        </p>

        <div className="w-full space-y-4">
          <div className="space-y-1">
            <label className="text-sm font-medium text-zinc-400 px-2">
              E-mail
            </label>
            <input
              type="email"
              placeholder="Seu e-mail"
              defaultValue="leonardo.carvalho@exemplo.com"
              className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500 transition-colors"
            />
          </div>
          <div className="space-y-1">
            <label className="text-sm font-medium text-zinc-400 px-2">
              Senha
            </label>
            <input
              type="password"
              placeholder="Sua senha"
              defaultValue="12345678"
              className="w-full bg-zinc-900 border border-zinc-800 rounded-2xl p-4 text-white outline-none focus:border-cyan-500 transition-colors"
            />
          </div>
        </div>

        <button
          onClick={onLogin}
          className="w-full bg-cyan-500 hover:bg-cyan-400 text-black font-bold text-lg py-4 rounded-full mt-10 active:scale-95 transition-all shadow-lg shadow-cyan-500/20"
        >
          Entrar
        </button>
      </div>
    </div>
  );
}