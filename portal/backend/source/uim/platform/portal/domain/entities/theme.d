/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.theme;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A theme for portal sites, derived from an SAP base theme.
struct PortalTheme {
  mixin TenantEntity!ThemeId;

  string name;
  string description;
  ThemeMode mode = ThemeMode.light;
  BaseTheme baseTheme = BaseTheme.sapHorizon;

  // Colour palette (CSS hex colours, empty = base theme default)
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

  // Fonts
  string fontFamily;
  string headerFontFamily;
  string fontSize;
  string headerFontSize;

  string customCss;
  /// The tenant's default theme (at most one).
  bool isDefault;
}
