enum AppEnvironment { development, production }

class AppEnv {
  static AppEnvironment current = AppEnvironment.development;
  static bool get isDev => current == AppEnvironment.development;
  static bool get isProd => current == AppEnvironment.production;

  // Toggle fake (simulated) device mode for UI testing without hardware
  static bool fakeModeEnabled = false;
}
