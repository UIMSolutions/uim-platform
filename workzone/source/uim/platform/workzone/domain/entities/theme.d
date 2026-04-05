/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.theme;

import uim.platform.workzone.domain.types;

/// A theme / branding configuration for a site.
struct Theme {
  ThemeId id;
  TenantId tenantId;
  string name;
  string description;
  string baseTheme; // e.g., "sap_horizon", "sap_fiori_3"
  ThemeColors colors;
  string logoUrl;
  string faviconUrl;
  string customCss;
  bool isDefault;
  long createdAt;
  long updatedAt;
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
}
