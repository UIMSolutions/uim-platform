/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.site;

import uim.platform.workzone.domain.types;

/// A site — the top-level portal / launchpad that users access.
struct Site {
  mixin TenantEntity!(SiteId);

  string name;
  string description;
  string alias_; // URL-friendly slug
  SiteStatus status = SiteStatus.draft;
  ThemeId themeId;
  NavigationItemId[] navigationIds;
  WorkpageId[] defaultPageIds;
  RoleId[] allowedRoleIds;
  SiteSettings settings;

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("alias", alias_)
      .set("status", status.toString())
      .set("themeId", themeId.value)
      .set("navigationIds", navigationIds.map!(n => n.value).array)
      .set("defaultPageIds", defaultPageIds.map!(p => p.value).array)
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array)
      .set("settings", settings.toJson());
  }
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

  Json toJson() const {
    return Json.emptyObject
      .set("logoUrl", logoUrl)
      .set("faviconUrl", faviconUrl)
      .set("footerText", footerText)
      .set("defaultLanguage", defaultLanguage)
      .set("enableSearch", enableSearch)
      .set("enableNotifications", enableNotifications)
      .set("enableUserMenu", enableUserMenu)
      .set("enableFeedback", enableFeedback);
  }
}
