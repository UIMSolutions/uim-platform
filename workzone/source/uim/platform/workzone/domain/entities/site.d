/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.site;

import uim.platform.workzone.domain.types;

/// A site — the top-level portal / launchpad that users access.
struct Site {
  SiteId id;
  TenantId tenantId;
  string name;
  string description;
  string alias_; // URL-friendly slug
  SiteStatus status = SiteStatus.draft;
  ThemeId themeId;
  NavigationItemId[] navigationIds;
  WorkpageId[] defaultPageIds;
  RoleId[] allowedRoleIds;
  SiteSettings settings;
  long createdAt;
  long updatedAt;
  string createdBy;
}

/// Site-level settings.
struct SiteSettings {
  string logoUrl;
  string faviconUrl;
  string footerText;
  string defaultLanguage;
  bool enableSearch;
  bool enableNotifications;
  bool enableUserMenu;
  bool enableFeedback;
}
