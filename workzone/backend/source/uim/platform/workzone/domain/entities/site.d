/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.site;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A launchpad site with navigation, theme and settings.
struct Site {
  mixin TenantEntity!SiteId;

  string name; /// unique per tenant
  string description;
  string alias_; /// "alias": URL slug, unique per tenant
  SiteStatus status = SiteStatus.draft;
  ThemeId themeId;
  string themeName;
  string[] allowedRoles;

  string logoUrl;
  string faviconUrl;
  string footerText;
  string defaultLanguage = "en";
  bool enableSearch = true;
  bool enableNotifications = true;
  bool enableUserMenu = true;
  bool enableFeedback;
  long publishedAt;
}
