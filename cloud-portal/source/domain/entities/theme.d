module domain.entities.theme;

import domain.types;

/// Theme definition for portal sites.
struct Theme
{
    ThemeId id;
    TenantId tenantId;
    string name;
    string description;
    ThemeMode mode = ThemeMode.light;
    string baseTheme;         // e.g., "sap_fiori_3", "sap_horizon"
    ThemeColors colors;
    ThemeFonts fonts;
    string customCss;
    bool isDefault;
    long createdAt;
    long updatedAt;
}

/// Theme color palette.
struct ThemeColors
{
    string primaryColor;
    string secondaryColor;
    string accentColor;
    string backgroundColor;
    string shellColor;
    string textColor;
    string linkColor;
    string headerColor;
    string footerColor;
    string tileBackgroundColor;
}

/// Theme font configuration.
struct ThemeFonts
{
    string fontFamily;
    string headerFontFamily;
    string fontSize;
    string headerFontSize;
}
