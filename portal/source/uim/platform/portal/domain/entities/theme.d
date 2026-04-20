/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.theme;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Theme definition for portal sites.
struct Theme {
  mixin TenantEntity!(ThemeId);

  string name;
  string description;
  ThemeMode mode = ThemeMode.light;
  string baseTheme; // e.g., "sap_fiori_3", "sap_horizon"
  ThemeColors colors;
  ThemeFonts fonts;
  string customCss;
  bool isDefault;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("mode", mode.toString)
      .set("baseTheme", baseTheme)
      .set("colors", colors.toJson())
      .set("fonts", fonts.toJson())
      .set("customCss", customCss)
      .set("isDefault", isDefault);
  }
}

/// Theme color palette.
struct ThemeColors {
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

  Json toJson() const {
    return Json.emptyObject
      .set("primaryColor", primaryColor)
      .set("secondaryColor", secondaryColor)
      .set("accentColor", accentColor)
      .set("backgroundColor", backgroundColor)
      .set("shellColor", shellColor)
      .set("textColor", textColor)
      .set("linkColor", linkColor)
      .set("headerColor", headerColor)
      .set("footerColor", footerColor)
      .set("tileBackgroundColor", tileBackgroundColor);
  }
}

/// Theme font configuration.
struct ThemeFonts {
  string fontFamily;
  string headerFontFamily;
  string fontSize;
  string headerFontSize;

  Json toJson() const {
    return Json.emptyObject
      .set("fontFamily", fontFamily)
      .set("headerFontFamily", headerFontFamily)
      .set("fontSize", fontSize)
      .set("headerFontSize", headerFontSize);
  }
}
