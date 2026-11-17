/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.theme;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A custom theme on top of an SAP base theme.
struct Theme {
  mixin TenantEntity!ThemeId;

  string name; /// unique per tenant
  string description;
  BaseTheme baseTheme = BaseTheme.sapHorizon;
  string primaryColor;
  string secondaryColor;
  string backgroundColor;
  string headerColor;
  string textColor;
  string linkColor;
  string accentColor;
  string logoUrl;
  string faviconUrl;
  string customCss;
  bool isDefault; /// at most one default theme per tenant
  bool predefined;
}
