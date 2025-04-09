class ThemeManager {
  private HashMap<Integer, ColorScheme> themes;
  private ColorScheme currentTheme;
  private int currentThemeType;

  ThemeManager() {
    themes = new HashMap<>();
    initializeThemes();
    setTheme(Constants.THEME_DARK);
  }

  private void initializeThemes() {
    // Dark Theme
    themes.put(Constants.THEME_DARK, new ColorScheme(
      0xFF121212, // Background
      0xFF2C2C2C, // Grid
      0xFFE8E8E8, // Node
      0xFFC0C0C0, // Data Node
      0x84404040, // Connection
      0xFFFFFF00, // Flow
      0xFFFFFFFF, // Text GUI
      0xFF000000, // Text Entity
      0xFFFFEB3B, // Highlight
      0xE6000000, // Panel
      0xFF00E5FF  // Accent
      ));

    // Light Theme
    themes.put(Constants.THEME_LIGHT, new ColorScheme(
      0xFFFAFAFA, // Background
      0xFFE8E8E8, // Grid
      0xFF2C2C2C, // Node
      0xFF424242, // Data Node
      0x84787878, // Connection
      0xFFFF6D00, // Flow
      0xFF000000, // Text GUI
      0xFFFFFFFF, // Text Entity
      0xFF1976D2, // Highlight
      0xE6FFFFFF, // Panel
      0xFF0D47A1  // Accent
      ));

    // Midnight Blue Theme
    themes.put(Constants.THEME_MIDNIGHT, new ColorScheme(
      0xFF0A192F, // Background
      0xFF1C2E4A, // Grid
      0xFFA8B2D1, // Node
      0xFF64FFDA, // Data Node
      0x84344960, // Connection
      0xFF64FFDA, // Flow
      0xFFE6F1FF, // Text GUI
      0xFF0A192F, // Text Entity
      0xFF64FFDA, // Highlight
      0xE60A192F, // Panel
      0xFF64FFDA  // Accent
      ));

    // Monochrome Theme
    themes.put(Constants.THEME_MONOCHROME, new ColorScheme(
      0xFF000000, // Background
      0xFF1F1F1F, // Grid
      0xFFE0E0E0, // Node
      0xFFB0B0B0, // Data Node
      0x84404040, // Connection
      0xFFFFFFFF, // Flow
      0xFFFFFFFF, // Text GUI
      0xFF000000, // Text Entity
      0xFFE0E0E0, // Highlight
      0xE6000000, // Panel
      0xFFFFFFFF  // Accent
      ));

    // Nordic Theme
    themes.put(Constants.THEME_NORDIC, new ColorScheme(
      0xFF2E3440, // Background
      0xFF3B4252, // Grid
      0xFFE5E9F0, // Node
      0xFF88C0D0, // Data Node
      0x844C566A, // Connection
      0xFF8FBCBB, // Flow
      0xFFECEFF4, // Text GUI
      0xFF2E3440, // Text Entity
      0xFF88C0D0, // Highlight
      0xE62E3440, // Panel
      0xFF81A1C1  // Accent
      ));

    // Solarized Theme
    themes.put(Constants.THEME_SOLARIZED, new ColorScheme(
      0xFF002B36, // Background
      0xFF073642, // Grid
      0xFFB58900, // Node
      0xFF2AA198, // Data Node
      0x84465A61, // Connection
      0xFFCB4B16, // Flow
      0xFFFDF6E3, // Text GUI
      0xFF002B36, // Text Entity
      0xFF2AA198, // Highlight
      0xE6002B36, // Panel
      0xFF268BD2  // Accent
      ));

    // Minimal Green Theme
    themes.put(Constants.THEME_MINIMAL_GREEN, new ColorScheme(
      0xFF1C1C1C, // Background
      0xFF2A2A2A, // Grid
      0xFFB8E6A4, // Node
      0xFF98C379, // Data Node
      0x84303030, // Connection
      0xFFD5E8B9, // Flow
      0xFFF8FFF2, // Text GUI
      0xFF1C1C1C, // Text Entity
      0xFFA8C686, // Highlight
      0xE61C1C1C, // Panel
      0xFF7CAC5C  // Accent
      ));
  }

  void setTheme(int themeType) {
    currentTheme = themes.get(themeType);
    currentThemeType = themeType;
  }

  ColorScheme getCurrentTheme() {
    return currentTheme;
  }

  int getCurrentThemeType() {
    return currentThemeType;
  }
}
