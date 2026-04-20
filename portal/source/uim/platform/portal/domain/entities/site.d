/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.site;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Portal site — the top-level container for pages, navigation, and content.
struct Site {
  mixin TenantEntity!(SiteId);

  string name;
  string description;
  string alias_; // URL-friendly slug
  SiteStatus status = SiteStatus.draft;
  ThemeId themeId;
  string[] pageIds;
  MenuItemId[] menuItemIds;
  RoleId[] allowedRoleIds;
  SiteSettings settings;

  bool isPublished() const {
    return status == SiteStatus.published;
  }

  Json toJson() const {
    auto j = entityToJson
      .set("name", name)
      .set("description", description)
      .set("alias", alias_)
      .set("status", status.toString())
      .set("themeId", themeId.value)
      .set("pageIds", pageIds)
      .set("menuItemIds", menuItemIds.map!(id => id.value).array)
      .set("allowedRoleIds", allowedRoleIds.map!(id => id.value).array)
      .set("settings", settings.toJson());

    return j;
  }
}

/// Site-level settings.
struct SiteSettings {
  string logoUrl;
  string faviconUrl;
  string footerText;
  string copyrightText;
  string defaultLanguage;
  string[] supportedLanguages;
  bool showPersonalization;
  bool showNotifications;
  bool showSearch;
  bool showUserActions;
}
