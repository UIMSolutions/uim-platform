/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.theme;

import uim.platform.workzone.domain.types;

/// A theme / branding configuration for a site.
struct Theme {
  mixin TenantEntity!(ThemeId);

  string name;
  string description;
  string baseTheme; // e.g., "sap_horizon", "sap_fiori_3"
  ThemeColors colors;
  string logoUrl;
  string faviconUrl;
  string customCss;
  bool isDefault;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("baseTheme", baseTheme)
      .set("colors", colors.toJson())
      .set("logoUrl", logoUrl)
      .set("faviconUrl", faviconUrl)
      .set("customCss", customCss)
      .set("isDefault", isDefault);
  }
}

/// Color palette for a theme.
struct ThemeColors {
  string primaryColor;
  string secondaryColor;
  string backgroundColor;
  string headerColor;
  string textColor;
  string linkColor;
  string accentColor;

  Json toJson() const {
    return Json()
      .set("primaryColor", primaryColor)
      .set("secondaryColor", secondaryColor)
      .set("backgroundColor", backgroundColor)
      .set("headerColor", headerColor)
      .set("textColor", textColor)
      .set("linkColor", linkColor)
      .set("accentColor", accentColor);
  }
}
