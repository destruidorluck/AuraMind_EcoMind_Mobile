class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rsdxtvhhtarkesuvvesj.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ImJcUIWHG-9uy2_UpkfuVQ_PvoVfMLF',
  );

  static const String webRedirectUrl = String.fromEnvironment(
    'AURA_WEB_REDIRECT_URL',
    defaultValue: 'https://aura-mind-eco-mind.vercel.app/',
  );

  static const String oracleApiBaseUrl = String.fromEnvironment(
    'ORACLE_API_BASE_URL',
    defaultValue: 'https://unlimited-sharpness-fondue.ngrok-free.dev',
  );

  static const String supportEmail = String.fromEnvironment(
    'AURA_SUPPORT_EMAIL',
    defaultValue: 'suporte@auramind.app',
  );

  static const Duration requestTimeout = Duration(seconds: 20);
  static const Duration uploadTimeout = Duration(seconds: 60);
}
