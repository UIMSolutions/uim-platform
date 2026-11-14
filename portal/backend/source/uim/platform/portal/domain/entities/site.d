/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.site;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A portal site — the launchpad that end users open. Owns pages and the
/// navigation menu; refers to a theme; can be restricted to roles.
struct PortalSite {
  mixin TenantEntity!SiteId;

  string name;
  string description;
  /// URL slug, unique per tenant ("/sites/<alias>").
  string alias_;
  SiteStatus status = SiteStatus.draft;
  ThemeId themeId;

  // Branding & shell settings
  string logoUrl;
  string faviconUrl;
  string footerText;
  string copyrightText;
  string defaultLanguage = "en";
  string[] supportedLanguages;
  bool showPersonalization = true;
  bool showNotifications = true;
  bool showSearch = true;
  bool showUserActions = true;

  /// Empty = every authenticated user may open the site.
  PortalRoleId[] allowedRoleIds;

  /// Incremented on every publish.
  int publishedVersion;
  long publishedAt;

  bool isPublished() const {
    return status == SiteStatus.published;
  }

  /// Relative runtime URL of the site.
  string runtimeUrl() const {
    return "/sites/" ~ alias_;
  }
}
